import Foundation

//TODO: Lambdas is unportable for other web frameworks.
import PerfectMustache

public struct SiteI18n {
    public enum Locale{
        case zh_CN
        case zh_TW
    }

    static let zh_cn: [String: Any] = [
        "Title": "标题",
        "Author": "作者",
        "Description": "描述",
        "Add comic": "添加漫画",
        "Add page": "添加页",
        "File": "文件",
        "Submit": "提交",
        "Cancle": "取消",
        "Save": "保存",
        "Previous page": "上一页",
        "Next page": "下一页",
        "Page(index)": { (tag: String, context: MustacheEvaluationContext) in return ("第 \(context.getValue(named: "index") ?? "") 页") },
        "Edit": "编辑",
        "Newest": "最新更新",
        "All": "全部",
        "title_placeholder": "添加标题",
        "optional_title_placeholder": "（可选）添加标题",
        "author_placeholder": "添加作者",
        "description_placeholder": "添加描述",
        "optional_description_placeholder": "（可选）添加描述",

        // error messages
        "Unclosed tag": "未闭合的标签",
        "Unfinished opening tag": "未完成的起始标签",
        "Unfinished attr": "未完成的标签属性",
        "Unparied tag": "未配对的标签",
        "Unfinished closing tag": "未完成的结尾标签",
    ]

    static let zh_tw: [String: Any] = [
        "Title": "標題",
        "Author": "作者",
        "Description": "描述",
        "Add comic": "添加漫畫",
        "Add page": "添加頁",
        "File": "檔案",
        "Submit": "提交",
        "Cancle": "取消",
        "Save": "保存",
        "Previous page": "上一頁",
        "Next page": "下一頁",
        "Page(index)": { (tag: String, context: MustacheEvaluationContext) in return ("第 \(context.getValue(named: "index") ?? "") 頁") },
        "Edit": "編輯",
        "Newest": "最新更新",
        "All": "全部",
        "title_placeholder": "添加標題",
        "optional_title_placeholder": "（可選）添加標題",
        "author_placeholder": "添加作者",
        "description_placeholder": "添加描述",
        "optional_description_placeholder": "（可選）添加描述",

        // error messages
        "Unclosed tag": "未閉合的標籤",
        "Unfinished opening tag": "未完成的起始標籤",
        "Unfinished attr": "未完成的標籤屬性",
        "Unparied tag": "未配對的標籤",
        "Unfinished closing tag": "未完成的結尾標籤",
    ]

    static func getI18n(_ locale: Locale?) -> [String: Any] {
        switch locale ?? .zh_CN {
        case .zh_CN:
            return zh_cn
        case .zh_TW:
            return zh_tw
        }
    }

    static func getI18n(_ locale: Locale?, key: String) -> String? {
        switch locale ?? .zh_CN {
        case .zh_CN:
            return zh_cn[key] as? String
        case .zh_TW:
            return zh_tw[key] as? String
        }
    }
}
