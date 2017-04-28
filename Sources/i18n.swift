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
        "optional_description_placeholder": "（可选）添加描述"
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
        "optional_description_placeholder": "（可選）添加描述"
    ]

    static func getI18n(_ locale: Locale?) -> [String: Any] {
        switch locale ?? .zh_CN {
        case .zh_CN:
            return zh_cn
        case .zh_TW:
            return zh_tw
        }
    }
}
