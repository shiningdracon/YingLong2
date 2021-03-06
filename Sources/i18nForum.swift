import Foundation

public class ForumI18n : SiteI18n {
    static var _instance: ForumI18n? = nil
    public static var instance: ForumI18n {
        if _instance == nil {
            _instance = ForumI18n()
        }
        return _instance!
    }

    override var zh_cn: [String : Any] {
        return [
            // Notices
            "Bad request" : "错误。您使用的连接有误或已失效。",
            "No view" : "您没有权限浏览该版块。",
            "No permission" : "您没有权限浏览该页面。",
            "Bad referrer" : "HTTP_REFERER 错误。您从未授权的地方连入本页。",
            "No cookie" : "登录成功，但cookies设置失败。请检查您的浏览器选项，打开cookies",

            // Miscellaneous
            "Announcement" : "公告",
            "Options" : "选项",
            "Submit" : "提交",    // "name" of submit buttons
            "Ban message" : "您已被停权。",
            "Ban message 2" : "停权时效至",
            "Ban message 3" : "将您停权的管理员或版主给您的留言：",
            "Ban message 4" : "有任何疑问请与论坛管理员联系：",
            "Never" : "无",
            "Today" : "今天",
            "Yesterday" : "昨天",
            "Info" : "信息",        // a common table header
            "Go back" : "返回前页",
            "Maintenance" : "维护",
            "Redirecting" : "跳转中",
            "Click redirect" : "如果您不想再等，或是您的浏览器没有自动跳转到新页面，请单击此处。",
            "on" : "启用",        // as in "BBCode is on"
            "off" : "关闭",
            "Invalid email" : "您输入的电子邮件地址无效。",
            "Required" : "(必填)",
            "required field" : "为必填栏目。",    // for javascript form validation
            "Last post" : "最后回复来自",
            "by" : "作者",    // as in last post by someuser
            "New posts" : "新帖",    // the link that leads to the first new post (use &nbsp; for spaces)
            "New posts info" : "跳转到本主题第一篇新帖。",    // the popup text for new posts links
            "Username" : "用户名",
            "Password" : "密码",
            "Email" : "电子邮件",
            "Send email" : "发送电子邮件",
            "Moderated by" : "版主",
            "Registered" : "注册日期",
            "Subject" : "标题",
            "Message" : "内容",
            "Topic" : "主题",
            "Forum" : "版面",
            "Posts" : "帖数",
            "Replies" : "回复",
            "Pages" : "页次",
            "BBCode" : "BBCode:",
            "url tag" : "[url] 标签:",
            "img tag" : "[img] 标签:",
            "Smilies" : "表情符号:",
            "and" : "及",
            "or" : "或",
            "Image link" : "图片",    // This is displayed (i.e. <image>) instead of images when "Show images" is disabled in the profile
            "wrote" : "写道:",    // For [quote]"s
            "Important information" : "重要信息",
            "Write message legend" : "写下您要回复的消息然后发送",
            "Previous" : "上一页",
            "Next" : "下一页",
            "Spacer" : "…", // Ellipsis for paginate

            // Title
            "Title" : "头衔",
            "Member" : "会员",    // Default title
            "Moderator" : "版主",
            "Administrator" : "论坛管理员",
            "Banned" : "停权",
            "Guest" : "访客",
            "[Deleted User]" : "[用户已删除]",

            // Stuff for the navigator (top of every page)
            "Gallery" : "画廊",
            "Library" : "图书馆",
            "Add image" : "上传图像",
            "Wiki" : "龙百科",
            "Main page" : "首页",
            "Index" : "论坛",
            "User list" : "用户列表",
            "Rules" : "站规",
            "Search" : "搜索",
            "Register" : "注册",
            "Login" : "登录",
            "Not logged in" : "您尚未登录。",
            "Profile" : "设置",
            "Logout" : "注销",
            "Logged in as" : "欢迎再度访问本论坛,",
            "Admin" : "管理",
            "Last visit" : "您上次来访时间是: ",
            "Topic searches" : "帖子:",
            "New posts header" : "新帖",
            "Active topics" : "最近的",
            "Unanswered topics" : "无回复的",
            "Posted topics" : "参与过的",
            "Show new posts" : "列出所有新帖",
            "Show active topics" : "查找最近有回复的帖子",
            "Show unanswered topics" : "查找未被回复过的帖子",
            "Show posted topics" : "查找参与过的主题",
            "Mark all as read" : "把所有帖子标记为已读",
            "Mark forum read" : "把此版面标记为已读",
            "Title separator" : " / ",

            // Stuff for the page footer
            "Board footer" : "论坛页尾",
            "Jump to" : "快速跳转",
            "Go" : "进入版面",        // submit button in forum jump
            "Moderate topic" : "管理主题",
            "All" : "全部",
            "Move topic" : "移动主题",
            "Open topic" : "开启主题",
            "Close topic" : "关闭主题",
            "Unstick topic" : "取消主题置顶",
            "Stick topic" : "设定主题置顶",
            "Moderate forum" : "管理版面",
            "Powered by" : "Powered by",

            // Units for file sizes
            "Size unit B" : "B",
            "Size unit KiB" : "KiB",
            "Size unit MiB" : "MiB",
            "Size unit GiB" : "GiB",
            "Size unit TiB" : "TiB",
            "Size unit PiB" : "PiB",
            "Size unit EiB" : "EiB",


            // View recent posts
            "Recent posts" : "最新帖",
            "Empty" : "没有符合条件的帖子",
            "First page" : "第一页",

            // Easy bbcode
            "Normal editor" : "切换到普通编辑器",
            "Rich editor" : "切换到图文编辑器",

            // Registor
            "Username space" : "用户名不能含有空格，请重新选择。",

            // Anit-bot
            "Humantest failed" : "您输入的验证答案有误，请再修改。",
            "Human Test" : "验证",
            "Humantest info" : "请回答下面的问题，谢谢。",
            "Question" : "问题：",
            "Answer" : "回答：",

            // forum.php
            "All topics" : "所有主题",
            "Not labeled topics" : "无分类主题",

            // index.php
            "Summary" : "摘要",
            "Newest topic" : "最新主题",
            "Newest reply" : "最新回复",
            "Newest Wiki" : "最新百科更新",
            "Newest RSS" : "最新博客更新",
            "Show all RSS" : "查看所有更新",
            "Add my blog" : "我想让自己的博客显示在这里",
            "New" : "新",
            "Newest image" : "最新图画",
            "Random image" : "随机图画",
            "View Latest Comments" : "观看最新回应",
            "Add gallery item" : "发表作品",
            "More" : "查看更多...",

            // post.php
            "Topic type" : "主题类型",
            "Not a valid topictype" : "无效的主题类型",
            "Preview" : "预览",

            // profile.php
            "Section otherform" : "个龙设定",

            // topic.php
            "Show author posts" : "只看该作者",
            "Show all posts" : "显示全部楼层",
            "Reader mod" : "使用小说阅读模式",
            "Quote reply" : "引用",

            // notify
            "Notifies" : "通知",

            "Topics" : "主题",
            "Empty board" : "本版面目前没有帖子。",
            "Newest user" : "最新注册用户",
            "Users online" : "在线注册用户",
            "Guests online" : "在线访客",
            "No of users" : "总注册用户数",
            "No of topics" : "总主题数",
            "No of posts" : "总文章数",
            "Online" : "在线用户列表",    // As in "Online: User A, User B etc."
            "Board info" : "版面信息",
            "Board stats" : "版面状态",
            "User info" : "用户信息",

            // Miscellaneous
            "Wrong user/pass" : "用户名或者密码不正确。",
            "Forgotten pass" : "忘记密码？",
            "Login redirect" : "登录成功，跳转中 &hellip;",
            "Logout redirect" : "注销成功，跳转中 &hellip;",
            "No email match" : "输入的电子邮件地址不符合任何会员资料",
            "Request pass" : "申请新密码",
            "Request pass legend" : "请输入您注册时用的电子邮件地址。",
            "Request pass info" : "一封包含新密码以及激活新密码用的链接将寄到您指定的电子邮件地址。",
            "Not registered" : "还没注册？",
            "Login legend" : "请在下面输入您的用户名与密码",
            "Remember me" : "下次来访时自动登录。",
            "Login info" : "假如您尚未注册或者是忘记登录密码，请点击下面的链接。",
            "New password errors" : "新密码请求错误",
            "New passworderrors info" : "请更正一下错误：",
            
            // Forget password mail stuff
            "Forget mail" : "系统已发送电子邮件至您输入的地址，请按照邮件内容的提示激活您的新密码。如果您没有收到邮件，请联系论坛管理员："

        ]
    }

    override var zh_tw: [String : Any] {
        return [
            // Notices
            "Bad request" : "错误。您使用的连接有误或已失效。",
            "No view" : "您没有权限浏览该版块。",
            "No permission" : "您没有权限浏览该页面。",
            "Bad referrer" : "HTTP_REFERER 错误。您从未授权的地方连入本页。",
            "No cookie" : "登录成功，但cookies设置失败。请检查您的浏览器选项，打开cookies",

            // Miscellaneous
            "Announcement" : "公告",
            "Options" : "选项",
            "Submit" : "提交",    // "name" of submit buttons
            "Ban message" : "您已被停权。",
            "Ban message 2" : "停权时效至",
            "Ban message 3" : "将您停权的管理员或版主给您的留言：",
            "Ban message 4" : "有任何疑问请与论坛管理员联系：",
            "Never" : "无",
            "Today" : "今天",
            "Yesterday" : "昨天",
            "Info" : "信息",        // a common table header
            "Go back" : "返回前页",
            "Maintenance" : "维护",
            "Redirecting" : "跳转中",
            "Click redirect" : "如果您不想再等，或是您的浏览器没有自动跳转到新页面，请单击此处。",
            "on" : "启用",        // as in "BBCode is on"
            "off" : "关闭",
            "Invalid email" : "您输入的电子邮件地址无效。",
            "Required" : "(必填)",
            "required field" : "为必填栏目。",    // for javascript form validation
            "Last post" : "最后回复来自",
            "by" : "作者",    // as in last post by someuser
            "New posts" : "新帖",    // the link that leads to the first new post (use &nbsp; for spaces)
            "New posts info" : "跳转到本主题第一篇新帖。",    // the popup text for new posts links
            "Username" : "用户名",
            "Password" : "密码",
            "Email" : "电子邮件",
            "Send email" : "发送电子邮件",
            "Moderated by" : "版主",
            "Registered" : "注册日期",
            "Subject" : "标题",
            "Message" : "内容",
            "Topic" : "主题",
            "Forum" : "版面",
            "Posts" : "帖数",
            "Replies" : "回复",
            "Pages" : "页次",
            "BBCode" : "BBCode:",
            "url tag" : "[url] 标签:",
            "img tag" : "[img] 标签:",
            "Smilies" : "表情符号:",
            "and" : "及",
            "or" : "或",
            "Image link" : "图片",    // This is displayed (i.e. <image>) instead of images when "Show images" is disabled in the profile
            "wrote" : "写道:",    // For [quote]"s
            "Important information" : "重要信息",
            "Write message legend" : "写下您要回复的消息然后发送",
            "Previous" : "上一页",
            "Next" : "下一页",
            "Spacer" : "…", // Ellipsis for paginate

            // Title
            "Title" : "头衔",
            "Member" : "会员",    // Default title
            "Moderator" : "版主",
            "Administrator" : "论坛管理员",
            "Banned" : "停权",
            "Guest" : "访客",
            "[Deleted User]" : "[用户已删除]",

            // Stuff for the navigator (top of every page)
            "Gallery" : "画廊",
            "Library" : "图书馆",
            "Add image" : "上传图像",
            "Wiki" : "龙百科",
            "Main page" : "首页",
            "Index" : "论坛",
            "User list" : "用户列表",
            "Rules" : "站规",
            "Search" : "搜索",
            "Register" : "注册",
            "Login" : "登录",
            "Not logged in" : "您尚未登录。",
            "Profile" : "设置",
            "Logout" : "注销",
            "Logged in as" : "欢迎再度访问本论坛,",
            "Admin" : "管理",
            "Last visit" : "您上次来访时间是: ",
            "Topic searches" : "帖子:",
            "New posts header" : "新帖",
            "Active topics" : "最近的",
            "Unanswered topics" : "无回复的",
            "Posted topics" : "参与过的",
            "Show new posts" : "列出所有新帖",
            "Show active topics" : "查找最近有回复的帖子",
            "Show unanswered topics" : "查找未被回复过的帖子",
            "Show posted topics" : "查找参与过的主题",
            "Mark all as read" : "把所有帖子标记为已读",
            "Mark forum read" : "把此版面标记为已读",
            "Title separator" : " / ",

            // Stuff for the page footer
            "Board footer" : "论坛页尾",
            "Jump to" : "快速跳转",
            "Go" : "进入版面",        // submit button in forum jump
            "Moderate topic" : "管理主题",
            "All" : "全部",
            "Move topic" : "移动主题",
            "Open topic" : "开启主题",
            "Close topic" : "关闭主题",
            "Unstick topic" : "取消主题置顶",
            "Stick topic" : "设定主题置顶",
            "Moderate forum" : "管理版面",
            "Powered by" : "Powered by",

            // Units for file sizes
            "Size unit B" : "B",
            "Size unit KiB" : "KiB",
            "Size unit MiB" : "MiB",
            "Size unit GiB" : "GiB",
            "Size unit TiB" : "TiB",
            "Size unit PiB" : "PiB",
            "Size unit EiB" : "EiB",


            // View recent posts
            "Recent posts" : "最新帖",
            "Empty" : "没有符合条件的帖子",
            "First page" : "第一页",

            // Easy bbcode
            "Normal editor" : "切换到普通编辑器",
            "Rich editor" : "切换到图文编辑器",

            // Registor
            "Username space" : "用户名不能含有空格，请重新选择。",

            // Anit-bot
            "Humantest failed" : "您输入的验证答案有误，请再修改。",
            "Human Test" : "验证",
            "Humantest info" : "请回答下面的问题，谢谢。",
            "Question" : "问题：",
            "Answer" : "回答：",

            // forum.php
            "All topics" : "所有主题",
            "Not labeled topics" : "无分类主题",

            // index.php
            "Summary" : "摘要",
            "Newest topic" : "最新主题",
            "Newest reply" : "最新回复",
            "Newest Wiki" : "最新百科更新",
            "Newest RSS" : "最新博客更新",
            "Show all RSS" : "查看所有更新",
            "Add my blog" : "我想让自己的博客显示在这里",
            "New" : "新",
            "Newest image" : "最新图画",
            "Random image" : "随机图画",
            "View Latest Comments" : "观看最新回应",
            "Add gallery item" : "发表作品",
            "More" : "查看更多...",

            // post.php
            "Topic type" : "主题类型",
            "Not a valid topictype" : "无效的主题类型",
            "Preview" : "预览",

            // profile.php
            "Section otherform" : "个龙设定",

            // topic.php
            "Show author posts" : "只看该作者",
            "Show all posts" : "显示全部楼层",
            "Reader mod" : "使用小说阅读模式",
            "Quote reply" : "引用",

            // notify
            "Notifies" : "通知",

            "Topics" : "主题",
            "Empty board" : "本版面目前没有帖子。",
            "Newest user" : "最新注册用户",
            "Users online" : "在线注册用户",
            "Guests online" : "在线访客",
            "No of users" : "总注册用户数",
            "No of topics" : "总主题数",
            "No of posts" : "总文章数",
            "Online" : "在线用户列表",    // As in "Online: User A, User B etc."
            "Board info" : "版面信息",
            "Board stats" : "版面状态",
            "User info" : "用户信息",

            // Miscellaneous
            "Wrong user/pass" : "用户名或者密码不正确。",
            "Forgotten pass" : "忘记密码？",
            "Login redirect" : "登录成功，跳转中 &hellip;",
            "Logout redirect" : "注销成功，跳转中 &hellip;",
            "No email match" : "输入的电子邮件地址不符合任何会员资料",
            "Request pass" : "申请新密码",
            "Request pass legend" : "请输入您注册时用的电子邮件地址。",
            "Request pass info" : "一封包含新密码以及激活新密码用的链接将寄到您指定的电子邮件地址。",
            "Not registered" : "还没注册？",
            "Login legend" : "请在下面输入您的用户名与密码",
            "Remember me" : "下次来访时自动登录。",
            "Login info" : "假如您尚未注册或者是忘记登录密码，请点击下面的链接。",
            "New password errors" : "新密码请求错误",
            "New passworderrors info" : "请更正一下错误：",
            
            // Forget password mail stuff
            "Forget mail" : "系统已发送电子邮件至您输入的地址，请按照邮件内容的提示激活您的新密码。如果您没有收到邮件，请联系论坛管理员："

        ]
    }
}
