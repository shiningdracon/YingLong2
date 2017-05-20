import Foundation
import PerfectMustache
//TODO: Lambdas is unportable for other web frameworks.

public class ComicI18n : SiteI18n {
    static var _instance: ComicI18n? = nil
    public static var instance: ComicI18n {
        if _instance == nil {
            _instance = ComicI18n()
        }
        return _instance!
    }

    override var zh_cn: [String: Any] {
        return [
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
        ]
    }

    override var zh_tw: [String: Any] {
        return [
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
        ]
    }
}
