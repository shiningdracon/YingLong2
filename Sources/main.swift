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
    struct DBConfig {
        var host: String
        var user: String
        var password: String
        var dbname: String
        var tablePrefix: String
    }

    typealias PageHandler = (SessionInfo?, HTTPRequest, HTTPResponse) -> SiteResponse

    struct CommonHandler: MustachePageHandler {
        var pageHandler: PageHandler

        init(pageHandler: @escaping PageHandler) {
            self.pageHandler = pageHandler
        }

        func extendValuesForResponse(context contxt: MustacheWebEvaluationContext, collector: MustacheEvaluationOutputCollector) {

            let request = contxt.webRequest
            let response = contxt.webResponse
            let templatesDir = "./views"
            let session = SessionInfo(remoteAddress: request.remoteAddress.host)

            let result = self.pageHandler(session, request, response)

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

    var dbconfig: DBConfig
    var routes: Routes
    var controller: SiteController

    init() {
        LogFile.location = "./server.log"
        self.routes = Routes()

        do {
            let config = try String(contentsOfFile: "./db.conf.json", encoding: String.Encoding.utf8)
            if let jsonData = config.data(using: String.Encoding.utf8) {
                if let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                    let host = json["host"] as? String,
                    let user = json["user"] as? String,
                    let password = json["password"] as? String,
                    let dbname = json["dbname"] as? String,
                    let tablePrefix = json["tablePrefix"] as? String {
                    dbconfig = DBConfig(host: host, user: user, password: password, dbname: dbname, tablePrefix: tablePrefix)
                } else {
                    fatalError("Load config failed")
                }
            } else {
                fatalError("Load config failed")
            }
        } catch {
            fatalError("Load config failed")
        }

        guard let mysql = MySQLPerfect(host: dbconfig.host, user: dbconfig.user, passwd: dbconfig.password, dbname: dbconfig.dbname) else {
            fatalError("Database init failed")
        }
        let dbStorage = DatabaseStorage(database: mysql, prefix: dbconfig.tablePrefix)
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
            let description = request.param(name: "description") ?? ""
            return self.controller.postAddComic(session: session, title: title, description: description)
        })

        addRoute(method: .get, uri: "/comic/{cid}/page/{pidx}", handler: { (session: SessionInfo?, request: HTTPRequest, response: HTTPResponse) in

            if let cid = UInt32(request.urlVariables["cid"] ?? "0"), cid > 0 {
                if let pidx = UInt32(request.urlVariables["pidx"] ?? "0"), pidx > 0 {
                    return self.controller.viewPage(session: session, comicId: cid, pageIndex: pidx)
                } else if request.urlVariables["pidx"] == "add" {
                    return self.controller.addPage(session: session, comicId: cid)
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
                            //TODO: make size limit configurable
                            guard upload.fileSize > 0 && upload.fileSize < (1024 * 1024 * 10) else {
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
        server.serverAddress = "localhost"
        server.serverPort = 8080
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
