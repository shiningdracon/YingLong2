import Foundation
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectMustache
import PerfectLogger
import MySQL
import OpenCC
import SwiftGD

class SiteMain {
    struct DatabaseConfig {
        var host: String
        var user: String
        var password: String
        var dbname: String
        var tablePrefix: String
    }

    struct ServerConfig {
        var address: String
        var port: UInt16
        var sslCertificatePath: String
        var sslKeyPath: String
    }

    struct SiteConfig {
        var uploadSizeLimit: Int
        var cookieName: String
        var cookieDomain: String
        var cookiePath: String
        var cookieSecure: Bool
        var cookieSeed: String
    }

    typealias PageHandler = (SiteController, SessionInfo, HTTPRequest, HTTPResponse) -> SiteResponse

    static func parseAcceptLanguage(_ value: String) -> i18nLocale {
        let components = value.components(separatedBy: ",")
        for language in components {
            let params = language.components(separatedBy: CharacterSet(charactersIn: "-_"))
            if params.count == 1 {
                if params[0].caseInsensitiveCompare("zh") == .orderedSame {
                    return .zh_CN
                }
            } else if params.count > 1 {
                if params[0].caseInsensitiveCompare("zh") == .orderedSame {
                    if params[1].caseInsensitiveCompare("tw") == .orderedSame ||
                        params[1].caseInsensitiveCompare("hk") == .orderedSame ||
                        params[1].caseInsensitiveCompare("mo") == .orderedSame {
                        return .zh_TW
                    } else {
                        return .zh_CN
                    }
                }
            }
        }
        return .zh_CN
    }

    struct CommonHandler: MustachePageHandler {
        var pageHandler: PageHandler
        var databaseConfig: DatabaseConfig
        var siteConfig: SiteConfig
        var utilities: UtilitiesPerfect
        var memoryStorage: MemoryStorage

        init(pageHandler: @escaping PageHandler, util: UtilitiesPerfect, databaseConfig: DatabaseConfig, siteConfig: SiteConfig, memoryStorage: MemoryStorage) {
            self.pageHandler = pageHandler
            self.databaseConfig = databaseConfig
            self.siteConfig = siteConfig
            self.utilities = util
            self.memoryStorage = memoryStorage
        }

        func extendValuesForResponse(context contxt: MustacheWebEvaluationContext, collector: MustacheEvaluationOutputCollector) {

            let request = contxt.webRequest
            let response = contxt.webResponse
            let templatesDir = "./views"
            let locale: i18nLocale = SiteMain.parseAcceptLanguage(request.header(.acceptLanguage) ?? "")

            let session: ForumSessionInfo = ForumSessionInfo(remoteAddress: request.remoteAddress.host, locale: locale, userID: 0, passwordHash: "", expirationTime: 0, sessionHash: "")

            let cookies = request.cookies
            for cookie in cookies {
                if cookie.0 == siteConfig.cookieName {
                    let value = cookie.1
                    let properties = value.characters.split(separator: "|").map(String.init)
                    if properties.count == 4 {
                        if let userId = UInt32.init(properties[0]), let expirationTime = Double.init(properties[2]) {
                            session.userID = userId
                            session.passwordHash = properties[1]
                            session.expirationTime = expirationTime
                            session.sessionHash = properties[3]
                        }
                    }
                }
            }

            guard let mysql = MySQLPerfect(host: databaseConfig.host, user: databaseConfig.user, passwd: databaseConfig.password, dbname: databaseConfig.dbname) else {
                LogFile.error("Database init failed")
                return
            }
            let dbStorage = DatabaseStorage(database: mysql, prefix: databaseConfig.tablePrefix)
            let data = DataManager(dbStorage: dbStorage, memoryStorage: self.memoryStorage)
            let controller = SiteController(util: utilities, data: data)
            controller.siteConfig["cookieSeed"] = siteConfig.cookieSeed

            let result = self.pageHandler(controller, session, request, response)

            if let responseSession = result.session as? ForumSessionInfo {
                let value = "\(responseSession.userID)|\(responseSession.passwordHash)|\(responseSession.expirationTime)|\(responseSession.sessionHash))"
                response.addCookie(HTTPCookie(name: siteConfig.cookieName, value: value, domain: siteConfig.cookieDomain, expires: HTTPCookie.Expiration.relativeSeconds(Int(responseSession.expirationTime)), path: nil, secure: siteConfig.cookieSecure, httpOnly: true))
            } else {
                response.addCookie(HTTPCookie(name: siteConfig.cookieName, value: "", domain: siteConfig.cookieDomain, expires: HTTPCookie.Expiration.absoluteSeconds(0), path: nil, secure: siteConfig.cookieSecure, httpOnly: true))
            }

            response.addHeader(.contentSecurityPolicy, value: "default-src 'self'; img-src * data: blob:; script-src 'self' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; connect-src * wss:;")
            switch result.status {
            case .OK(view: let view, data: let data):
                contxt.templatePath = "\(templatesDir)/\(view)"
                contxt.extendValues(with: data)
                do {
                    try contxt.requestCompleted(withCollector: collector)
                    LogFile.info("[\(request.remoteAddress.host)] URI: \(request.uri)")
                } catch {
                    response.status = .internalServerError
                    response.appendBody(string: "Service error")
                    response.completed()
                    LogFile.error("[\(request.remoteAddress.host)] \(error)")
                }
            case .Redirect(location: let location):
                response.status = .found
                response.setHeader(HTTPResponseHeader.Name.location, value: location)
                response.completed()
            case .NotFound:
                response.status = .notFound
                response.appendBody(string: "Not found")
                response.completed()
                LogFile.warning("[\(request.remoteAddress.host)] Not found: \(request.uri)")
            case .Error(message: let message):
                response.status = .internalServerError
                response.appendBody(string: "Service error")
                response.completed()
                LogFile.error("[\(request.remoteAddress.host)] URI: \(request.uri), error: \(message)")
            }
        }
    }

    var databaseConfig: DatabaseConfig
    var serverConfig: ServerConfig
    var siteConfig: SiteConfig
    var routes: Routes
    var utilities: UtilitiesPerfect
    var memoryStorage: MemoryStorage

    init() {
        LogFile.location = "./server.log"
        self.routes = Routes()

        do {
            let config = try String(contentsOfFile: "./config.json", encoding: String.Encoding.utf8)
            if let jsonData = config.data(using: String.Encoding.utf8) {
                if let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any],

                    let databaseConfigJSON = json["databaseConfig"] as? [String: Any],
                    let host = databaseConfigJSON["host"] as? String,
                    let user = databaseConfigJSON["user"] as? String,
                    let password = databaseConfigJSON["password"] as? String,
                    let dbname = databaseConfigJSON["dbname"] as? String,
                    let tablePrefix = databaseConfigJSON["tablePrefix"] as? String,

                    let serverConfigJSON = json["serverConfig"] as? [String: Any],
                    let address = serverConfigJSON["address"] as? String,
                    let portString = serverConfigJSON["port"] as? String,
                    let port = UInt16(portString),
                    let sslCertificatePath = serverConfigJSON["sslCertificatePath"] as? String,
                    let sslKeyPath = serverConfigJSON["sslKeyPath"] as? String,

                    let siteConfigJSON = json["siteConfig"] as? [String: Any],
                    let uploadSizeLimitString = siteConfigJSON["uploadSizeLimit"] as? String,
                    let uploadSizeLimit = Int(uploadSizeLimitString),

                    let cookieName = siteConfigJSON["cookieName"] as? String,
                    let cookieDomain = siteConfigJSON["cookieDomain"] as? String,
                    let cookiePath = siteConfigJSON["cookiePath"] as? String,
                    let cookieSecureString = siteConfigJSON["cookieSecure"] as? String,
                    let cookieSecure = Bool(cookieSecureString),
                    let cookieSeed = siteConfigJSON["cookieSeed"] as? String
                {
                    self.databaseConfig = DatabaseConfig(host: host, user: user, password: password, dbname: dbname, tablePrefix: tablePrefix)
                    self.serverConfig = ServerConfig(address: address, port: port, sslCertificatePath: sslCertificatePath, sslKeyPath: sslKeyPath)
                    self.siteConfig = SiteConfig(uploadSizeLimit: uploadSizeLimit, cookieName: cookieName, cookieDomain: cookieDomain, cookiePath: cookiePath, cookieSecure: cookieSecure, cookieSeed: cookieSeed)
                } else {
                    fatalError("Load config failed")
                }
            } else {
                fatalError("Load config failed")
            }
        } catch {
            fatalError("Load config failed")
        }

        guard let utilities = UtilitiesPerfect() else {
            fatalError("Utilities init failed")
        }
        self.utilities = utilities

        self.memoryStorage = MemoryStorage()
        guard let mysql = MySQLPerfect(host: databaseConfig.host, user: databaseConfig.user, passwd: databaseConfig.password, dbname: databaseConfig.dbname) else {
            fatalError("Database init failed")
        }
        let forumdb = DatabaseStorage(database: mysql, prefix: databaseConfig.tablePrefix)
        do {
            try self.memoryStorage.initMemoryStorageForum(forumdb)
        } catch MemoryStorageError.initFailed {
            fatalError("MemoryStorage init failed")
        } catch {
            fatalError("Unknow error")
        }
    }

    func addRoute(method: HTTPMethod, uri: String, handler: @escaping PageHandler) {
        routes.add(method: method, uri: uri, handler: { request, response in
            mustacheRequest(request: request, response: response, handler: CommonHandler(pageHandler: handler, util: self.utilities, databaseConfig: self.databaseConfig, siteConfig: self.siteConfig, memoryStorage: self.memoryStorage), templatePath: "")
        })
    }

    func start() {

        setupForumRoutes()
        setupComicRoutes()

        let server = HTTPServer()
        server.serverAddress = serverConfig.address
        server.serverPort = serverConfig.port
        if !serverConfig.sslCertificatePath.isEmpty && !serverConfig.sslKeyPath.isEmpty {
            server.ssl = (serverConfig.sslCertificatePath, serverConfig.sslKeyPath)
            server.alpnSupport = [.http2, .http11]
        }
        server.addRoutes(routes)
        server.documentRoot = "./webroot" // Setting the document root will add a default URL route which permits static files to be served from within.

        do {
            try server.start()
        } catch {
            fatalError("\(error)")
        }
    }
}

extension SiteMain {
    func setupForumRoutes() {
        addRoute(method: .get, uri: "/", handler: { (controller: SiteController, session: SessionInfo, request: HTTPRequest, response: HTTPResponse) in
            let tab = UInt32.init(request.param(name: "tab") ?? "1") ?? 1
            return controller.mainPage(session: session as! ForumSessionInfo, tab: tab, page: 1)
        })

        addRoute(method: .get, uri: "/page/{page}", handler: { controller, session, request, response in
            let tab = UInt32.init(request.param(name: "tab") ?? "1") ?? 1
            let page = UInt32.init(request.urlVariables["page"] ?? "1") ?? 1
            return controller.mainPage(session: session as! ForumSessionInfo, tab: tab, page: page)
        })
        addRoute(method: .get, uri: "/login", handler: { controller, session, request, response in return controller.loginPage(session: session as! ForumSessionInfo) })
        addRoute(method: .get, uri: "/forget", handler: { controller, session, request, response in return controller.forgetPage(session: session as! ForumSessionInfo) })
        addRoute(method: .post, uri: "/login", handler: { controller, session, request, response in
            let username = request.param(name: "req_username") ?? ""
            let password = request.param(name: "req_password") ?? ""
            let savepass: Bool = (request.param(name: "save_pass") == "1") ? true : false
            let location = request.param(name: "redirect_url") ?? "/" //TODO: validate
            return controller.loginHandler(session: session as! ForumSessionInfo, username: username, password: password, savepass: savepass, redirectURL: "/")
        })
        addRoute(method: .get, uri: "/logout", handler: { (controller: SiteController, session: SessionInfo, request: HTTPRequest, response: HTTPResponse) in
            if let paramID = request.param(name: "id"), UInt32(paramID) != nil {
                let csrf = request.param(name: "csrf_token") ?? ""
                return controller.logoutHandler(session: session as! ForumSessionInfo, csrf: csrf)
            }
            return SiteResponse(status: .NotFound, session: session)
        })
        addRoute(method: .get, uri: "/forum/{id}", handler: { controller, session, request, response in
            if let paramID = request.urlVariables["id"] {
                if let id = UInt32(paramID) {
                    return controller.forumPage(session: session as! ForumSessionInfo, id: id, page: 1)
                }
            }
            return SiteResponse(status: .NotFound, session: session)
        })
        addRoute(method: .get, uri: "/forum/{id}/{page}", handler: { controller, session, request, response in
            if let paramID = request.urlVariables["id"] {
                if let id = UInt32(paramID) {
                    let page = UInt32(request.urlVariables["page"] ?? "1") ?? 1
                    return controller.forumPage(session: session as! ForumSessionInfo, id: id, page: page)
                }
            }
            return SiteResponse(status: .NotFound, session: session)
        })
        addRoute(method: .get, uri: "/topic/{id}", handler: { controller, session, request, response in
            if let paramID = request.urlVariables["id"] {
                if let id = UInt32(paramID) {
                    return controller.topicPage(session: session as! ForumSessionInfo, id: id, page: 1)
                }
            }
            return SiteResponse(status: .NotFound, session: session)
        })
        addRoute(method: .get, uri: "/topic/{id}/{page}", handler: { controller, session, request, response in
            if let paramID = request.urlVariables["id"] {
                if let id = UInt32(paramID) {
                    let page = UInt32(request.urlVariables["page"] ?? "1") ?? 1
                    return controller.topicPage(session: session as! ForumSessionInfo, id: id, page: page)
                }
            }
            return SiteResponse(status: .NotFound, session: session)
        })
        addRoute(method: .get, uri: "/post/{pid}", handler: { controller, session, request, response in
            if let postId = UInt32(request.urlVariables["pid"] ?? "0") {
                return controller.topicPage(session: session as! ForumSessionInfo, postId: postId)
            }
            return SiteResponse(status: .NotFound, session: session)
        })
        addRoute(method: .post, uri: "/postreply/{tid}", handler: { controller, session, request, response in
            if let topicId = UInt32(request.urlVariables["tid"] ?? "0") {
                if let message = request.param(name: "req_message") {
                    return controller.postReplyHandler(session: session as! ForumSessionInfo, topicId: topicId, message: message)
                }
            }
            return SiteResponse(status: .NotFound, session: session)
        })
    }

    func setupComicRoutes() {
        addRoute(method: .get, uri: "/comic/{cid}", handler: { (controller: SiteController, session: SessionInfo, request: HTTPRequest, response: HTTPResponse) in

            if let cid = UInt32(request.urlVariables["cid"] ?? "0"), cid > 0 {
                return controller.viewComic(session: session, comicId: cid)
            } else if request.urlVariables["cid"] == "add" {
                return controller.addComic(session: session)
            }
            return SiteResponse(status: .NotFound, session: session)
        })

        addRoute(method: .post, uri: "/comic/add", handler: { (controller: SiteController, session: SessionInfo, request: HTTPRequest, response: HTTPResponse) in

            let title = request.param(name: "title") ?? ""
            let author = request.param(name: "author") ?? ""
            let description = request.param(name: "description") ?? ""
            return controller.postAddComic(session: session, title: title, author: author, description: description)
        })

        addRoute(method: .get, uri: "/comic/{cid}/edit", handler: { (controller: SiteController, session: SessionInfo, request: HTTPRequest, response: HTTPResponse) in
            if let cid = UInt32(request.urlVariables["cid"] ?? "0"), cid > 0 {
                return controller.editComic(session: session, comicId: cid)
            }
            return SiteResponse(status: .NotFound, session: session)
        })

        addRoute(method: .post, uri: "/comic/{cid}/edit", handler: { (controller: SiteController, session: SessionInfo, request: HTTPRequest, response: HTTPResponse) in
            if let cid = UInt32(request.urlVariables["cid"] ?? "0"), cid > 0 {
                let title = request.param(name: "title") ?? ""
                let author = request.param(name: "author") ?? ""
                let description = request.param(name: "description") ?? ""
                return controller.postUpdateComic(session: session, comicId: cid, title: title, author: author, description: description)
            }
            return SiteResponse(status: .NotFound, session: session)
        })

        addRoute(method: .get, uri: "/comic/{cid}/page/{pidx}", handler: { (controller: SiteController, session: SessionInfo, request: HTTPRequest, response: HTTPResponse) in

            if let cid = UInt32(request.urlVariables["cid"] ?? "0"), cid > 0 {
                if let pidx = UInt32(request.urlVariables["pidx"] ?? "0"), pidx > 0 {
                    return controller.viewPage(session: session, comicId: cid, pageIndex: pidx)
                } else if request.urlVariables["pidx"] == "add" {
                    return controller.addPage(session: session, comicId: cid)
                } else if request.urlVariables["pidx"] == "end" {
                    return controller.viewLastPage(session: session, comicId: cid)
                }
            }
            return SiteResponse(status: .NotFound, session: session)
        })

        addRoute(method: .post, uri: "/comic/{cid}/page/add", handler: { (controller: SiteController, session: SessionInfo, request: HTTPRequest, response: HTTPResponse) in

            if let cid = UInt32(request.urlVariables["cid"] ?? "0"), cid > 0 {
                if let uploads = request.postFileUploads , uploads.count > 0 {
                    for upload in uploads {
                        if upload.file != nil {
                            let title = request.param(name: "title") ?? ""
                            let description = request.param(name: "description") ?? ""

                            LogFile.info("fieldName: \(upload.fieldName), fileName: \(upload.fileName), contentType: \(upload.contentType), fileSize: \(upload.fileSize)")

                            // Validate file type
                            var fileExtension: String
                            if upload.contentType == "image/jpeg" {
                                fileExtension = "jpeg"
                            } else if upload.contentType == "image/png" {
                                fileExtension = "png"
                            } else if upload.contentType == "" {
                                fileExtension = upload.fileName.filePathExtension
                            } else {
                                fileExtension = ""
                            }
                            guard fileExtension == "png" || fileExtension == "jpg" || fileExtension == "jpeg" else {
                                return controller.errorNotifyPage(session: session, message: "File type")
                            }

                            // Validate file size
                            guard upload.fileSize > 0 && upload.fileSize < self.siteConfig.uploadSizeLimit else {
                                return controller.errorNotifyPage(session: session, message: "File size")
                            }

                            // Validate image
                            guard let image = Image(url: URL(fileURLWithPath: upload.tmpFileName)) else {
                                return controller.errorNotifyPage(session: session, message: "Not valid file")
                            }

                            let localname = "\(UUID().string).\(fileExtension)"
                            return controller.postAddPage(session: session, comicId: cid, title: title, description: description, imgWebURL: "/images/"+localname, onSeccuss: { (pageId: UInt32) in
                                
                                try controller.toolAddFile(pageId: pageId, filename: upload.fileName, localname: localname, mimetype: upload.contentType, size: UInt32(upload.fileSize))
                                guard image.write(to: URL(fileURLWithPath: "webroot/images/"+localname), quality: 75) else {
                                    throw WebFrameworkError.RuntimeError("Failed write image file")
                                }
                            })
                        }
                    }
                }
                return controller.errorNotifyPage(session: session, message: "No file uploaded")
            }
            return SiteResponse(status: .NotFound, session: session)
        })
        
        addRoute(method: .get, uri: "/comic/{cid}/page/{pidx}/edit", handler: { (controller: SiteController, session: SessionInfo, request: HTTPRequest, response: HTTPResponse) in
            
            if let cid = UInt32(request.urlVariables["cid"] ?? "0"), cid > 0 {
                if let pidx = UInt32(request.urlVariables["pidx"] ?? "0"), pidx > 0 {
                    return controller.editPage(session: session, comicId: cid, pageIndex: pidx)
                }
            }
            return SiteResponse(status: .NotFound, session: session)
        })
        
        addRoute(method: .post, uri: "/comic/{cid}/page/{pidx}/update", handler: { (controller: SiteController, session: SessionInfo, request: HTTPRequest, response: HTTPResponse) in
            
            if let cid = UInt32(request.urlVariables["cid"] ?? "0"), cid > 0 {
                if let pidx = UInt32(request.urlVariables["pidx"] ?? "0"), pidx > 0 {
                    if let content = request.param(name: "content") {
                        let title = request.param(name: "title") ?? ""
                        let description = request.param(name: "description") ?? ""
                        return controller.postUpdatePage(session: session, comicId: cid, pageIndex: pidx, title: title, description: description, content: content)
                    } else {
                        return controller.errorNotifyPage(session: session, message: "Empty content")
                    }
                }
            }
            return SiteResponse(status: .NotFound, session: session)
        })
    }
}

let main = SiteMain()
main.start()
