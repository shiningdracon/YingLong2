import Foundation

protocol UtilitiesProtocol {
    func ChineseConvertS2T(_ s: String) -> String
    func ChineseConvertT2S(_ t: String) -> String
    func BBCode2HTML(bbcode: String, local: i18nLocale, configuration: [String: Any]?) throws -> String
    func BBCodeValidate(bbcode: String, local: i18nLocale) throws
    func getNow() -> Double
    func md5(string: String) -> String?
    func sha1(string: String) -> String?
    func sha256(string: String) -> String?
    func forumHMAC(data: String, key: String) -> String?
    func UUID() -> String
}

public enum WebFrameworkError: Error {
    case RuntimeError(String)
    case BBCodeError(String)
}

public class SessionInfo {
    var remoteAddress: String
    var locale: i18nLocale

    init(remoteAddress: String, locale: i18nLocale) {
        self.remoteAddress = remoteAddress
        self.locale = locale
    }
}

public enum SiteResponseStatus {
    case Error(message: String)
    case OK(view: String, data: Any)
    case Redirect(location: String)
    case NotFound
}

public struct SiteResponse {
    var status: SiteResponseStatus
    var session: SessionInfo?
}

public final class SiteController {
    let utilities: UtilitiesProtocol
    let dataManager: DataManager
    var siteConfig: Dictionary<String, String>

    init(util: UtilitiesProtocol, data: DataManager) {
        self.utilities = util
        self.dataManager = data
        self.siteConfig = [:]
    }

    func i18n(_ ori: String, locale: i18nLocale?) -> String {
        if locale != nil {
            switch locale! {
            case .zh_CN:
                return utilities.ChineseConvertT2S(ori)
            case .zh_TW:
                return utilities.ChineseConvertS2T(ori)
            }
        } else {
            return ori
        }
    }

    func formatTime(time: Double, timezone: Int, daySavingTime: Int) -> String {
        let date: Date = Date(timeIntervalSince1970: time)
        let diff = Double((timezone + daySavingTime) * 3600)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: Int(diff))

        return dateFormatter.string(from: date)
    }

    func reGenerateJSON(jsonString: String) -> String? {
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

    public func errorNotifyPage(session: SessionInfo, message: String) -> SiteResponse {
        return SiteResponse(status: .OK(view: "error.mustache", data: ["message": message]), session: session)
    }

    public func validateRedirect(url: String) -> Bool {
        // TODO
        return true
    }
}

extension Dictionary {
    mutating func update(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}

extension String {
    /// Returns the String with all special HTML characters encoded.
    public var stringByEncodingHTML_NoConvertCRLF: String {
        var ret = ""
        var g = self.unicodeScalars.makeIterator()
        while let c = g.next() {
            if c < UnicodeScalar(0x0009) {
                if let scale = UnicodeScalar(0x0030 + UInt32(c)) {
                    ret.append("&#x")
                    ret.append(String(Character(scale)))
                    ret.append(";")
                }
            } else if c == UnicodeScalar(0x0022) {
                ret.append("&quot;")
            } else if c == UnicodeScalar(0x0026) {
                ret.append("&amp;")
            } else if c == UnicodeScalar(0x0027) {
                ret.append("&#39;")
            } else if c == UnicodeScalar(0x003C) {
                ret.append("&lt;")
            } else if c == UnicodeScalar(0x003E) {
                ret.append("&gt;")
            } else if c > UnicodeScalar(126) {
                ret.append("&#\(UInt32(c));")
            } else {
                ret.append(String(Character(c)))
            }
        }
        return ret
    }
}
