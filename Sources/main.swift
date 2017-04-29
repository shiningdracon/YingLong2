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
    }

    struct SiteConfig {
        var uploadSizeLimit: Int
    }

    typealias PageHandler = (SessionInfo?, HTTPRequest, HTTPResponse) -> SiteResponse

    static func parseAcceptLanguage(_ value: String) -> SiteI18n.Locale {
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

        init(pageHandler: @escaping PageHandler) {
            self.pageHandler = pageHandler
        }

        func extendValuesForResponse(context contxt: MustacheWebEvaluationContext, collector: MustacheEvaluationOutputCollector) {

            let request = contxt.webRequest
            let response = contxt.webResponse
            let templatesDir = "./views"
            let locale: SiteI18n.Locale = SiteMain.parseAcceptLanguage(request.header(.acceptLanguage) ?? "")

            let session = SessionInfo(remoteAddress: request.remoteAddress.host, locale: locale)

            let result = self.pageHandler(session, request, response)

            response.addHeader(.contentSecurityPolicy, value: "default-src 'self'; img-src * data: blob:; script-src 'self' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; connect-src * wss:;")
            switch result.status {
            case .OK(view: let view, data: let data):
                contxt.templatePath = "\(templatesDir)/\(view)"
                contxt.extendValues(with: data)
                do {
                    try contxt.requestCompleted(withCollector: collector)
                } catch {
                    response.status = .internalServerError
                    response.appendBody(string: "\(error)")
                    response.completed()
                }
            case .Redirect(location: let location):
                response.status = .found
                response.setHeader(HTTPResponseHeader.Name.location, value: location)
                response.completed()
            case .NotFound:
                response.status = .notFound
                response.appendBody(string: "Not found")
                response.completed()
                LogFile.warning("Not found: \(request.uri)")
            case .Error(message: let message):
                response.status = .internalServerError
                response.appendBody(string: "Service error")
                response.completed()
                LogFile.error("URI: \(request.uri), error: \(message)")
            }
        }
    }

    var databaseConfig: DatabaseConfig
    var serverConfig: ServerConfig
    var siteConfig: SiteConfig
    var routes: Routes
    var controller: SiteController

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

                    let siteConfigJSON = json["siteConfig"] as? [String: Any],
                    let uploadSizeLimitString = siteConfigJSON["uploadSizeLimit"] as? String,
                    let uploadSizeLimit = Int(uploadSizeLimitString)
                {
                    self.databaseConfig = DatabaseConfig(host: host, user: user, password: password, dbname: dbname, tablePrefix: tablePrefix)
                    self.serverConfig = ServerConfig(address: address, port: port)
                    self.siteConfig = SiteConfig(uploadSizeLimit: uploadSizeLimit)
                } else {
                    fatalError("Load config failed")
                }
            } else {
                fatalError("Load config failed")
            }
        } catch {
            fatalError("Load config failed")
        }

        guard let mysql = MySQLPerfect(host: databaseConfig.host, user: databaseConfig.user, passwd: databaseConfig.password, dbname: databaseConfig.dbname) else {
            fatalError("Database init failed")
        }
        let dbStorage = DatabaseStorage(database: mysql, prefix: databaseConfig.tablePrefix)
        let data = DataManager(dbStorage: dbStorage, memoryStorage: MemoryStorage())
        guard let utilities = UtilitiesPerfect() else {
            fatalError("Utilities init failed")
        }
        self.controller = SiteController(util: utilities, data: data)
    }

    func addRoute(method: HTTPMethod, uri: String, handler: @escaping PageHandler) {
        routes.add(method: method, uri: uri, handler: { request, response in
            mustacheRequest(request: request, response: response, handler: CommonHandler(pageHandler: handler), templatePath: "")
        })
    }

    func start() {
        addRoute(method: .get, uri: "/", handler: { (session: SessionInfo?, request: HTTPRequest, response: HTTPResponse) in
            return self.controller.main(session: session, page: 1)
        })

        addRoute(method: .get, uri: "/comic/{cid}", handler: { (session: SessionInfo?, request: HTTPRequest, response: HTTPResponse) in

            if let cid = UInt32(request.urlVariables["cid"] ?? "0"), cid > 0 {
                return self.controller.viewComic(session: session, comicId: cid)
            } else if request.urlVariables["cid"] == "add" {
                return self.controller.addComic(session: session)
            }
            return SiteResponse(status: .NotFound, session: session)
        })

        addRoute(method: .post, uri: "/comic/add", handler: { (session: SessionInfo?, request: HTTPRequest, response: HTTPResponse) in

            let title = request.param(name: "title") ?? ""
            let author = request.param(name: "author") ?? ""
            let description = request.param(name: "description") ?? ""
            return self.controller.postAddComic(session: session, title: title, author: author, description: description)
        })

        addRoute(method: .get, uri: "/comic/{cid}/edit", handler: { (session: SessionInfo?, request: HTTPRequest, response: HTTPResponse) in
            if let cid = UInt32(request.urlVariables["cid"] ?? "0"), cid > 0 {
                return self.controller.editComic(session: session, comicId: cid)
            }
            return SiteResponse(status: .NotFound, session: session)
        })

        addRoute(method: .post, uri: "/comic/{cid}/edit", handler: { (session: SessionInfo?, request: HTTPRequest, response: HTTPResponse) in
            if let cid = UInt32(request.urlVariables["cid"] ?? "0"), cid > 0 {
                let title = request.param(name: "title") ?? ""
                let author = request.param(name: "author") ?? ""
                let description = request.param(name: "description") ?? ""
                return self.controller.postUpdateComic(session: session, comicId: cid, title: title, author: author, description: description)
            }
            return SiteResponse(status: .NotFound, session: session)
        })

        addRoute(method: .get, uri: "/comic/{cid}/page/{pidx}", handler: { (session: SessionInfo?, request: HTTPRequest, response: HTTPResponse) in

            if let cid = UInt32(request.urlVariables["cid"] ?? "0"), cid > 0 {
                if let pidx = UInt32(request.urlVariables["pidx"] ?? "0"), pidx > 0 {
                    return self.controller.viewPage(session: session, comicId: cid, pageIndex: pidx)
                } else if request.urlVariables["pidx"] == "add" {
                    return self.controller.addPage(session: session, comicId: cid)
                } else if request.urlVariables["pidx"] == "end" {
                    return self.controller.viewLastPage(session: session, comicId: cid)
                }
            }
            return SiteResponse(status: .NotFound, session: session)
        })

        addRoute(method: .post, uri: "/comic/{cid}/page/add", handler: { (session: SessionInfo?, request: HTTPRequest, response: HTTPResponse) in

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
                                return self.controller.error(session: session, message: "File type")
                            }

                            // Validate file size
                            guard upload.fileSize > 0 && upload.fileSize < self.siteConfig.uploadSizeLimit else {
                                return self.controller.error(session: session, message: "File size")
                            }

                            // Validate image
                            guard let image = Image(url: URL(fileURLWithPath: upload.tmpFileName)) else {
                                return self.controller.error(session: session, message: "Not valid file")
                            }

                            let localname = "\(UUID().string).\(fileExtension)"
                            return self.controller.postAddPage(session: session, comicId: cid, title: title, description: description, imgWebURL: "/images/"+localname, onSeccuss: { (pageId: UInt32) in

                                try self.controller.toolAddFile(pageId: pageId, filename: upload.fileName, localname: localname, mimetype: upload.contentType, size: UInt32(upload.fileSize))
                                guard image.write(to: URL(fileURLWithPath: "webroot/images/"+localname), quality: 75) else {
                                    throw WebFrameworkError.RuntimeError("Failed write image file")
                                }
                            })
                        }
                    }
                }
                return self.controller.error(session: session, message: "No file uploaded")
            }
            return SiteResponse(status: .NotFound, session: session)
        })

        addRoute(method: .get, uri: "/comic/{cid}/page/{pidx}/edit", handler: { (session: SessionInfo?, request: HTTPRequest, response: HTTPResponse) in

            if let cid = UInt32(request.urlVariables["cid"] ?? "0"), cid > 0 {
                if let pidx = UInt32(request.urlVariables["pidx"] ?? "0"), pidx > 0 {
                    return self.controller.editPage(session: session, comicId: cid, pageIndex: pidx)
                }
            }
            return SiteResponse(status: .NotFound, session: session)
        })

        addRoute(method: .post, uri: "/comic/{cid}/page/{pidx}/update", handler: { (session: SessionInfo?, request: HTTPRequest, response: HTTPResponse) in

            if let cid = UInt32(request.urlVariables["cid"] ?? "0"), cid > 0 {
                if let pidx = UInt32(request.urlVariables["pidx"] ?? "0"), pidx > 0 {
                    if let content = request.param(name: "content") {
                        let title = request.param(name: "title") ?? ""
                        let description = request.param(name: "description") ?? ""
                        return self.controller.postUpdatePage(session: session, comicId: cid, pageIndex: pidx, title: title, description: description, content: content)
                    } else {
                        return self.controller.error(session: session, message: "Empty content")
                    }
                }
            }
            return SiteResponse(status: .NotFound, session: session)
        })


        let server = HTTPServer()
        server.serverAddress = serverConfig.address
        server.serverPort = serverConfig.port
        server.addRoutes(routes)
        server.documentRoot = "./webroot" // Setting the document root will add a default URL route which permits static files to be served from within.

        do {
            try server.start()
        } catch {
            fatalError("\(error)")
        }
    }
}

let main = SiteMain()
main.start()
