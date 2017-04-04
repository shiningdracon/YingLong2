import Foundation

protocol UtilitiesProtocol {
    func ChineseConvertS2T(s: String) -> String
    func ChineseConvertT2S(t: String) -> String
}

public struct SessionInfo {
    var remoteAddress: String
}

public enum SiteResponseStatus {
    case Error(message: String)
    case OK(view: String, data: [String: Any])
    case Redirect(location: String)
    case NotFound
}

public enum WebFrameworkError: Error {
    case RuntimeError(String)
}

public struct SiteResponse {
    var status: SiteResponseStatus
    var session: SessionInfo?
}

public final class SiteController {
    let utilities: UtilitiesProtocol
    let dataManager: DataManager

    init(util: UtilitiesProtocol, data: DataManager) {
        self.utilities = util
        self.dataManager = data
    }

    func formatTime(time: Double, timezone: Int, daySavingTime: Int) -> String {
        let date: Date = Date(timeIntervalSince1970: time)
        let diff = Double((timezone + daySavingTime) * 3600)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: Int(diff))

        return dateFormatter.string(from: date)
    }

    // handlers
    public func main(session: SessionInfo?, page: UInt32) -> SiteResponse {
        let data: [String: Any] = ["lang": SiteI18n.getI18n()]
        return SiteResponse(status: .OK(view: "main.mustache", data: data), session: session)
    }

    public func viewPage(session: SessionInfo?, comicId: UInt32, pageIndex: UInt32) -> SiteResponse {
        do {
            if let comic = try self.dataManager.getComic(id: comicId) {
                var data: [String: Any] = ["lang": SiteI18n.getI18n()]
                data["comic_id"] = comicId
                if pageIndex <= comic.pageCount {
                    if let page = try self.dataManager.getPage(comicId: comicId, pageIndex: pageIndex) {
                        data["page_index"] = pageIndex
                        if pageIndex > 1 {
                            data["previous_page_index"] = ["index": pageIndex - 1]
                        }
                        data["next_page_index"] = ["index": pageIndex + 1]
                        data["title"] = page.title
                        data["description"] = page.description
                        data["content"] = page.content
                        return SiteResponse(status: .OK(view: "viewpage.mustache", data: data), session: session)
                    }
                } else if pageIndex == comic.pageCount + 1 {
                    return SiteResponse(status: .OK(view: "viewlastpage.mustache", data: [:]), session: session)
                }
            }
            return SiteResponse(status: .NotFound, session: session)
        } catch {
            return SiteResponse(status: .Error(message: error.localizedDescription), session: session)
        }
    }

    public func editPage(session: SessionInfo?, comicId: UInt32, pageIndex: UInt32) -> SiteResponse {
        do {
            if let page = try self.dataManager.getPage(comicId: comicId, pageIndex: pageIndex) {
                var data: [String: Any] = ["lang": SiteI18n.getI18n()]
                data["comic_id"] = comicId
                data["page_index"] = pageIndex
                data["title"] = page.title
                data["description"] = page.description
                data["content"] = page.content
                return SiteResponse(status: .OK(view: "editpage.mustache", data: data), session: session)
            }
            return SiteResponse(status: .NotFound, session: session)
        } catch {
            return SiteResponse(status: .Error(message: error.localizedDescription), session: session)
        }
    }

    private func reGenerateJSON(jsonString: String) -> String? {
        do {
            if let jsonData = jsonString.data(using: .utf8, allowLossyConversion: false) {
                if let jsonDict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {

                    let jsonDataValidated = try JSONSerialization.data(withJSONObject: jsonDict)

                    if let jsonString = String(data: jsonDataValidated, encoding: .utf8) {
                        return jsonString
                    }
                }
            }
            return nil
        } catch {
            return nil
        }
    }

    public func addPage(session: SessionInfo?, comicId: UInt32) -> SiteResponse {
        do {
            guard let _ = try self.dataManager.getComic(id: comicId) else {
                return SiteResponse(status: .NotFound, session: session)
            }
            var data: [String: Any] = ["lang": SiteI18n.getI18n()]
            data["comic_id"] = comicId
            return SiteResponse(status: .OK(view: "addpage.mustache", data: data), session: session)
        } catch {
            return SiteResponse(status: .Error(message: "DB failed"), session: session)
        }
    }

    public func postAddPage(session: SessionInfo?, comicId: UInt32, title: String, description: String, imgWebURL: String, onSeccuss: ((_ pageId: UInt32) throws -> Void)) -> SiteResponse {
        do {
            guard let comic = try self.dataManager.getComic(id: comicId) else {
                return SiteResponse(status: .NotFound, session: session)
            }
            let pageIndex = comic.pageCount + 1
            let pageId = try self.dataManager.addPage(comicId: comicId, pageIndex: pageIndex, title: title, poster: "guest", description: description, content: "{\"backgroundImage\":{\"type\":\"image\",\"originX\":\"left\",\"originY\":\"top\",\"left\":0,\"top\":0,\"fill\":\"rgb(0,0,0)\",\"stroke\":null,\"strokeWidth\":0,\"strokeDashArray\":null,\"strokeLineCap\":\"butt\",\"strokeLineJoin\":\"miter\",\"strokeMiterLimit\":10,\"scaleX\":1,\"scaleY\":1,\"angle\":0,\"flipX\":false,\"flipY\":false,\"opacity\":1,\"shadow\":null,\"visible\":true,\"clipTo\":null,\"backgroundColor\":\"\",\"fillRule\":\"nonzero\",\"globalCompositeOperation\":\"source-over\",\"transformMatrix\":null,\"skewX\":0,\"skewY\":0,\"crossOrigin\":\"\",\"alignX\":\"none\",\"alignY\":\"none\",\"meetOrSlice\":\"meet\",\"src\":\"\(imgWebURL)\",\"filters\":[]}}")

            guard self.dataManager.updateComic(id: comicId, title: comic.title, pageCount: pageIndex, description: comic.description) else {
                return SiteResponse(status: .Error(message: "DB failed"), session: session)
            }

            try onSeccuss(pageId)

            return SiteResponse(status: .Redirect(location: "/comic/\(comicId)/page/\(pageIndex)/edit"), session: session)
        } catch WebFrameworkError.RuntimeError(let msg) {
            return SiteResponse(status: .Error(message: msg), session: session)
        } catch {
            return SiteResponse(status: .Error(message: "DB failed"), session: session)
        }
    }

    public func postUpdatePage(session: SessionInfo?, comicId: UInt32, pageIndex: UInt32, title: String, description: String, content: String) -> SiteResponse {
        if let jsonString = reGenerateJSON(jsonString: content) {
            if self.dataManager.updatePage(comicId: comicId, pageIndex: pageIndex, title: title, description: description, content: jsonString) {
                return SiteResponse(status: .Redirect(location: "/comic/\(comicId)/page/\(pageIndex)"), session: session)
            } else {
                return SiteResponse(status: .Error(message: "update failed"), session: session)
            }
        } else {
            return SiteResponse(status: .Error(message: "Invalid JSON"), session: session)
        }
    }

    public func viewComicList(session: SessionInfo?, page: UInt32) -> SiteResponse {
        let display: UInt32 = 25 //TODO: make display configurable
        let offset: UInt32 = (page <= 1 ? 0 : page - 1) * display

        do {
            var data: [String: Any] = ["lang": SiteI18n.getI18n()]
            if let comicList = try self.dataManager.getComicList(offset: offset, limit: display) {
                var dataComicList: [[String: Any]] = []
                for comic in comicList {
                    var dataComic: [String: Any] = [:]
                    dataComic["id"] = comic.id
                    dataComic["title"] = comic.title
                    dataComic["poster"] = comic.poster
                    dataComic["description"] = comic.description
                    dataComic["page_count"] = comic.pageCount
                    dataComicList.append(dataComic)
                }
                data["comic_list"] = dataComicList
            }
            // if comic_list is not set, means no comic right now
            return SiteResponse(status: .OK(view: "viewcomiclist.mustache", data: data), session: session)
        } catch {
            return SiteResponse(status: .Error(message: "DB error"), session: session)
        }
    }

    public func viewComic(session: SessionInfo?, comicId: UInt32) -> SiteResponse {
        do {
            if let comic = try self.dataManager.getComic(id: comicId) {
                var data: [String: Any] = ["lang": SiteI18n.getI18n()]
                data["comic_id"] = comic.id
                data["title"] = comic.title
                data["poster"] = comic.poster
                data["description"] = comic.description
                data["page_count"] = comic.pageCount
                return SiteResponse(status: .OK(view: "viewcomic.mustache", data: data), session: session)
            }
            return SiteResponse(status: .NotFound, session: session)
        } catch {
            return SiteResponse(status: .Error(message: "DB error"), session: session)
        }
    }

    public func addComic(session: SessionInfo?) -> SiteResponse {
        let data: [String: Any] = ["lang": SiteI18n.getI18n()]
        return SiteResponse(status: .OK(view: "addcomic.mustache", data: data), session: session)
    }

    public func postAddComic(session: SessionInfo?, title: String, description: String) -> SiteResponse {
        do {
            let comicId = try self.dataManager.addComic(title: title, poster: "guest", description: description)
            return SiteResponse(status: .Redirect(location: "/comic/\(comicId)"), session: session)
        } catch {
            return SiteResponse(status: .Error(message: "DB failed"), session: session)
        }
    }

    public func toolAddFile(pageId: UInt32, filename: String, localname: String, mimetype: String, size: UInt32) throws {
        try self.dataManager.addFile(pageId: pageId, filename: filename, localname: localname, mimetype: mimetype, size: size)
    }

    public func error(session: SessionInfo?, message: String) -> SiteResponse {
        return SiteResponse(status: .OK(view: "error.mustache", data: ["message": message]), session: session)
    }
}

extension Dictionary {
    mutating func update(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}
