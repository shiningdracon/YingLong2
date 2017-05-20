import Foundation

public class BBCodeI18n : SiteI18n {
    static var _instance: BBCodeI18n? = nil
    public static var instance: BBCodeI18n {
        if _instance == nil {
            _instance = BBCodeI18n()
        }
        return _instance!
    }

    override var zh_cn: [String: Any] {
        return [
            // error messages
            "Unclosed tag": "未闭合的标签",
            "Unfinished opening tag": "未完成的起始标签",
            "Unfinished attr": "未完成的标签属性",
            "Unparied tag": "未配对的标签",
            "Unfinished closing tag": "未完成的结尾标签",
        ]
    }

    override var zh_tw: [String: Any] {
        return [
            // error messages
            "Unclosed tag": "未閉合的標籤",
            "Unfinished opening tag": "未完成的起始標籤",
            "Unfinished attr": "未完成的標籤屬性",
            "Unparied tag": "未配對的標籤",
            "Unfinished closing tag": "未完成的結尾標籤",
        ]
    }
}
