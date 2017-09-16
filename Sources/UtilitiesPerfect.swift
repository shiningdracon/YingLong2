import OpenCC
import BBCode
import PerfectLib
import Cryptor

class UtilitiesPerfect: UtilitiesProtocol {
    let openccS2T: OpenCC
    let openccT2S: OpenCC
    let bbcode: BBCode

    init?() {
        guard let s2t = OpenCC(configFile: "s2t.json") else {
            return nil
        }
        guard let t2s = OpenCC(configFile: "t2s.json") else {
            return nil
        }
        self.openccS2T = s2t
        self.openccT2S = t2s

        self.bbcode = BBCode()
    }

    func ChineseConvertS2T(_ s: String) -> String {
        if let t = self.openccS2T.convert(s) {
            return t
        } else {
            return ""
        }
    }

    func ChineseConvertT2S(_ t: String) -> String {
        if let s = self.openccT2S.convert(t) {
            return s
        } else {
            return ""
        }
    }

    func BBCode2HTML(bbcode: String, local: i18nLocale, configuration: [String: Any]?) throws -> String {
        do {
            return try self.bbcode.parse(bbcode: bbcode, args: configuration)
        } catch let error as BBCodeError {
            let i18nData = BBCodeI18n.instance.getI18n(local)
            switch error {
            case .internalError(let detail):
                throw WebFrameworkError.BBCodeError(detail)
            case .unclosedTag(let detail):
                throw WebFrameworkError.BBCodeError(i18nData["Unclosed tag"] as! String + ": " + detail)
            case .unfinishedAttr(let detail):
                throw WebFrameworkError.BBCodeError(i18nData["Unfinished attr"] as! String + ": " + detail)
            case .unfinishedClosingTag(let detail):
                throw WebFrameworkError.BBCodeError(i18nData["Unfinished closing tag"] as! String + ": " + detail)
            case .unfinishedOpeningTag(let detail):
                throw WebFrameworkError.BBCodeError(i18nData["Unfinished opening tag"] as! String + ": " + detail)
            case .unpairedTag(let detail):
                throw WebFrameworkError.BBCodeError(i18nData["Unparied tag"] as! String + ": " + detail)
            }
        }
    }

    func BBCodeValidate(bbcode: String, local: i18nLocale) throws {
        do {
            try self.bbcode.validate(bbcode: bbcode)
        } catch let error as BBCodeError {
            let i18nData = BBCodeI18n.instance.getI18n(local)
            switch error {
            case .internalError(let detail):
                throw WebFrameworkError.BBCodeError(detail)
            case .unclosedTag(let detail):
                throw WebFrameworkError.BBCodeError(i18nData["Unclosed tag"] as! String + ": " + detail)
            case .unfinishedAttr(let detail):
                throw WebFrameworkError.BBCodeError(i18nData["Unfinished attr"] as! String + ": " + detail)
            case .unfinishedClosingTag(let detail):
                throw WebFrameworkError.BBCodeError(i18nData["Unfinished closing tag"] as! String + ": " + detail)
            case .unfinishedOpeningTag(let detail):
                throw WebFrameworkError.BBCodeError(i18nData["Unfinished opening tag"] as! String + ": " + detail)
            case .unpairedTag(let detail):
                throw WebFrameworkError.BBCodeError(i18nData["Unparied tag"] as! String + ": " + detail)
            }
        }
    }

    func getNow() -> Double {
        return PerfectLib.getNow() / 1000
    }

    func md5(string: String) -> String? {
        if let digest = Digest(using:.md5).update(string: string)?.final() {
            return CryptoUtils.hexString(from: digest)
        } else {
            return nil
        }
    }

    func sha1(string: String) -> String? {
        if let digest = Digest(using:.sha1).update(string: string)?.final() {
            return CryptoUtils.hexString(from: digest)
        } else {
            return nil
        }
    }

    func sha256(string: String) -> String? {
        if let digest = Digest(using:.sha256).update(string: string)?.final() {
            return CryptoUtils.hexString(from: digest)
        } else {
            return nil
        }
    }

    func forumHMAC(data: String, key: String) -> String? {
        if let hmac = HMAC(using: HMAC.Algorithm.sha1, key: key).update(string: data)?.final() {
            return CryptoUtils.hexString(from: hmac)
        } else {
            return nil
        }
    }

    func UUID() -> String {
        return PerfectLib.UUID().string
    }

}
