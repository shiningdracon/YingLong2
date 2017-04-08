import Foundation

public struct SiteI18n {
    public enum Locale{
        case zh_CN
        case zh_TW
    }

    static let zh_cn: [String: String] = [
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
        "title_placeholder": "添加标题",
        "optional_title_placeholder": "（可选）添加标题",
        "author_placeholder": "添加作者",
        "description_placeholder": "添加描述",
        "optional_description_placeholder": "（可选）添加描述"
    ]

    static let zh_tw: [String: String] = [
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
        "title_placeholder": "添加標題",
        "optional_title_placeholder": "（可選）添加標題",
        "author_placeholder": "添加作者",
        "description_placeholder": "添加描述",
        "optional_description_placeholder": "（可選）添加描述"
    ]

    static func getI18n(_ locale: Locale?) -> [String: String] {
        switch locale ?? .zh_CN {
        case .zh_CN:
            return zh_cn
        case .zh_TW:
            return zh_tw
        }
    }
}
