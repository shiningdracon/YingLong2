import Foundation

public struct SiteI18n {
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
        "": ""
    ]

    static func getI18n() -> [String: String] {
        return zh_cn
    }
}
