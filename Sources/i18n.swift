import Foundation

public enum i18nLocale{
    case zh_CN
    case zh_TW
}

public class SiteI18n {
    var zh_cn: [String: Any] { return [:] }
    var zh_tw: [String: Any] { return [:] }

    public func getI18n(_ locale: i18nLocale?) -> [String: Any] {
        switch locale ?? .zh_CN {
        case .zh_CN:
            return zh_cn
        case .zh_TW:
            return zh_tw
        }
    }

    public func getI18n(_ locale: i18nLocale?, key: String) -> String {
        switch locale ?? .zh_CN {
        case .zh_CN:
            return zh_cn[key] as? String ?? key
        case .zh_TW:
            return zh_tw[key] as? String ?? key
        }
    }
}
