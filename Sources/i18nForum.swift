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
            // Text orientation and encoding
            "lang_direction"		:	"ltr",	// ltr (Left-To-Right) or rtl (Right-To-Left)
            "lang_identifier"					:	"zh-CN",
            "lang_encoding"			:	"UTF-8",
            //"lang_multibyte"		:	true,

            // Number formatting
            "lang_decimal_point"				:	".",
            "lang_thousands_sep"				:	",",

            // Notices
            "Bad request"			:	"错误。您使用的连接有误或已失效。",
            "No view"				:	"您没有权限浏览该版块。",
            "No permission"			:	"您没有权限浏览该页面。",
            "Bad referrer"			:	"HTTP_REFERER 错误。您从未授权的地方连入本页。如果一再发生相同问题，请确认 「管理/Options 」 里的 「Base URL」 设定无误，并请通过点击论坛导航链接的方式进入本论坛其他页面。更多关于这项错误的资料请参考 PunBB 官方网站的技术文件。",
            "No cookie"				:	"登录成功，但cookies设置失败。请检查您的浏览器选项，打开cookies",
            "Pun include extension"  			:	"Unable to process user include %s from template %s. \"%s\" files are not allowed",
            "Pun include directory"				:	"Unable to process user include %s from template %s. Directory traversal is not allowed",
            "Pun include error"		:	"Unable to process user include %s from template %s. There is no such file in neither the template directory nor in the user include directory.",

            // Miscellaneous
            "Announcement"			:	"公告",
            "Options"				:	"选项",
            "Submit"				:	"提交",	// "name" of submit buttons
            "Ban message"			:	"您已被停权。",
            "Ban message 2"			:	"停权时效至",
            "Ban message 3"			:	"将您停权的管理员或版主给您的留言：",
            "Ban message 4"			:	"有任何疑问请与论坛管理员联系：",
            "Never"					:	"无",
            "Today"					:	"今天",
            "Yesterday"				:	"昨天",
            "Info"					:	"信息",		// a common table header
            "Go back"				:	"返回前页",
            "Maintenance"			:	"维护",
            "Redirecting"			:	"跳转中",
            "Click redirect"		:	"如果您不想再等，或是您的浏览器没有自动跳转到新页面，请单击此处。",
            "on"					:	"启用",		// as in "BBCode is on"
            "off"					:	"关闭",
            "Invalid email"		:	"您输入的电子邮件地址无效。",
            "Required"				:	"(必填)",
            "required field"		:	"为必填栏目。",	// for javascript form validation
            "Last post"				:	"最后回复来自",
            "by"					:	"作者",	// as in last post by someuser
            "New posts"				:	"新帖",	// the link that leads to the first new post (use &nbsp; for spaces)
            "New posts info"		:	"跳转到本主题第一篇新帖。",	// the popup text for new posts links
            "Username"				:	"用户名",
            "Password"				:	"密码",
            "Email"					:	"电子邮件",
            "Send email"			:	"发送电子邮件",
            "Moderated by"			:	"版主",
            "Registered"			:	"注册日期",
            "Subject"				:	"标题",
            "Message"				:	"内容",
            "Topic"					:	"主题",
            "Forum"					:	"版面",
            "Posts"					:	"帖数",
            "Replies"				:	"回复",
            "Pages"					:	"页次",
            "Page"					:	"第 %s 页",
            "BBCode"				:	"BBCode:",	// You probably shouldn"t change this
            "url tag"							:	"[url] 标签:",
            "img tag"				:	"[img] 标签:",
            "Smilies"				:	"表情符号:",
            "and"					:	"及",
            "Image link"			:	"图片",	// This is displayed (i.e. <image>) instead of images when "Show images" is disabled in the profile
            "wrote"					:	"写道:",	// For [quote]"s
            "Mailer"				:	"%s",	// As in "MyForums Mailer" in the signature of outgoing e-mails
            "Important information"	:	"重要信息",
            "Write message legend"	:	"写下您要回复的消息然后发送",
            "Previous"				:	"上一页",
            "Next"					:	"下一页",
            "Spacer"				:	"…", // Ellipsis for paginate

            // Title
            "Title"					:	"头衔",
            "Member"				:	"会员",	// Default title
            "Moderator"				:	"版主",
            "Administrator"			:	"论坛管理员",
            "Banned"				:	"停权",
            "Guest"					:	"访客",
            "[Deleted User]"        :   "[用户已删除]",

            // Stuff for include/parser.php
            "BBCode error no opening tag"		:	"[/%1$s] 缺少对应的 [%1$s]",
            "BBCode error invalid nesting"		:	"[%1$s] 嵌套在 [%2$s] 之中，这是不允许的",
            "BBCode error invalid self-nesting"	:	"[%s] 自我嵌套，这是不允许的",
            "BBCode error no closing tag"		:	"[%1$s] 缺少对应的 [/%1$s]",
            "BBCode error empty attribute"		:	"[%s] 标签留有空属性",
            "BBCode error tag not allowed"		:	"您所在的用户组不允许使用 [%s] 标签",
            "BBCode error tag url not allowed"	:	"您所在的用户组不允许发表网站链接",
            "BBCode code problem"				:	"你的 [code] 标签不正确",
            "BBCode list size error"			:	"列表过长，系统无法处理，请缩短长度！",

            // Stuff for the navigator (top of every page)
            "Gallery"				:	"画廊",
            "Library"				:	"图书馆",
            "Add image"				:	"上传图像",
            "Wiki"					:	"龙百科",
            "Main page"				:	"首页",
            "Index"					:	"论坛",
            "User list"				:	"用户列表",
            "Rules"					:  "站规",
            "Search"				:  "搜索",
            "Register"				:  "注册",
            "Login"					:  "登录",
            "Not logged in"			:  "您尚未登录。",
            "Profile"				:	"设置",
            "Logout"				:	"注销",
            "Logged in as"			:	"欢迎再度访问本论坛,",
            "Admin"					:	"管理",
            "Last visit"			:	"您上次来访时间是: %s",
            "Topic searches"					:	"帖子:",
            "New posts header"					:	"新帖",
            "Active topics"						:	"最近的",
            "Unanswered topics"					:	"无回复的",
            "Posted topics"						:	"参与过的",
            "Show new posts"		:	"列出所有新帖",
            "Show active topics"				:	"查找最近有回复的帖子",
            "Show unanswered topics"			:	"查找未被回复过的帖子",
            "Show posted topics"				:	"查找参与过的主题",
            "Mark all as read"		:	"把所有帖子标记为已读",
            "Mark forum read"		:	"把此版面标记为已读",
            "Title separator"		:	" / ",

            // Stuff for the page footer
            "Board footer"			:	"论坛页尾",
            "Jump to"				:	"快速跳转",
            "Go"					:	"进入版面",		// submit button in forum jump
            "Moderate topic"		:	"管理主题",
            "All"					:	"全部",
            "Move topic"			:  "移动主题",
            "Open topic"			:  "开启主题",
            "Close topic"			:  "关闭主题",
            "Unstick topic"			:  "取消主题置顶",
            "Stick topic"			:  "设定主题置顶",
            "Moderate forum"		:	"管理版面",
            "Powered by"			:	"Powered by %s",

            // Debug information
            "Debug table"						:	"除錯信息",
            "Querytime"							:	"Generated in %1$s seconds, %2$s queries executed",
            "Memory usage"						:	"Memory usage: %1$s",
            "Peak usage"						:	"(Peak: %1$s)",
            "Query times"						:	"Time (s)",
            "Query"								:	"Query",
            "Total query time"					:	"Total query time: %s",

            // Email related notifications
            "New user notification"				:	"通知 - 新用户注册",
            "New user message"					:	"用户 \"%s\" 于 %s 在论坛注册",
            "Banned email notification"			:	"通知 - 检测到被阻止的email",
            "Banned email register message"		:	"用户 \"%s\" 使用被阻止的email注册： %s",
            "Banned email change message"		:	"用户 \"%s\" 修改email为被阻止的地址： %s",
            "Banned email post message"			:	"用户 \"%s\" 使用被阻止的email发言： %s",
            "Duplicate email notification"		:	"通知 - 检测到重复的email",
            "Duplicate email register message"	:	"用户 \"%s\"  注册使用的email地址同时也属于： %s",
            "Duplicate email change message"	:	"用户 \"%s\" 修改后的email地址同时也属于： %s",
            "Report notification"				:	"报告(%d) - \"%s\"",
            "Report message 1"					:	"用户 \"%s\" 报告了如下资讯： %s",
            "Report message 2"					:	"缘由： %s",

            "User profile"						:	"用户资料： %s",
            "Post URL"							:	"帖子 URL: %s",
            "Email signature"					:	"论坛自动发信\n(请勿回复)",

            // For extern.php RSS feed
            "RSS description"					:	"位于 %s 的最新主题",
            "RSS description topic"				:	"位于 %s 的最新帖子",
            "RSS reply"							:	"回复： ", // The topic subject will be appended to this string (to signify a reply)
            "RSS active topics feed"			:	"RSS active topics feed",
            "Atom active topics feed"			:	"Atom active topics feed",
            "RSS forum feed"					:	"RSS forum feed",
            "Atom forum feed"					:	"Atom forum feed",
            "RSS topic feed"					:	"RSS topic feed",
            "Atom topic feed"					:	"Atom topic feed",

            // Admin related stuff in the header
            "New reports"						:	"There are new reports",
            "Maintenance mode enabled"			:	"Maintenance mode is enabled!",

            // Units for file sizes
            "Size unit B"						:	"%s B",
            "Size unit KiB"						:	"%s KiB",
            "Size unit MiB"						:	"%s MiB",
            "Size unit GiB"						:	"%s GiB",
            "Size unit TiB"						:	"%s TiB",
            "Size unit PiB"						:	"%s PiB",
            "Size unit EiB"						:	"%s EiB",


            // View recent posts
            "Recent posts"	         :  "最新帖",
            "Empty"	                :  "没有符合条件的帖子",
            "First page"	           :  "第一页",

            // Easy bbcode
            "Normal editor"	        :  "切换到普通编辑器",
            "Rich editor"	          :  "切换到图文编辑器",

            // Registor
            "Username space"			: "用户名不能含有空格，请重新选择。",

            // Anit-bot
            "Humantest failed"			: "您输入的验证答案有误，请再修改。",
            "Human Test"				: "验证",
            "Humantest info"			: "请回答下面的问题，谢谢。",
            "Question"					: "问题：",
            "Answer"					: "回答：",

            // forum.php
            "All topics"			: "所有主题",
            "Not labeled topics"	: "无分类主题",

            // index.php
            "Summary"				: "摘要",
            "Newest topic"			: "最新主题",
            "Newest reply"			: "最新回复",
            "Newest Wiki"			: "最新百科更新",
            "Newest RSS"			: "最新博客更新",
            "Show all RSS"			: "查看所有更新",
            "Add my blog"			: "我想让自己的博客显示在这里",
            "New"					: "新",
            "Newest image"			: "最新图画",
            "Random image"			: "随机图画",
            "View Latest Comments"	: "观看最新回应",
            "Add gallery item"		: "发表作品",
            "More"					: "查看更多...",

            // post.php
            "Topic type"			: "主题类型",
            "Not a valid topictype"	: "无效的主题类型",

            // profile.php
            "Section otherform"		: "个龙设定",
            "Post greater than"		: "发帖数大于 %s 可用",

            // topic.php
            "Show author posts"	: "只看该作者",
            "Show all posts"	: "显示全部楼层",
            "Reader mod"		: "使用小说阅读模式",
            "Quote reply"		: "引用",

            // notify
            "Notifies"			: "通知",
            "Notify like"		: "%s 喜欢你在 %s 中的发言",
            "Notify at"			: "%s 在 %s 中提到你",


            "Topics"				:  "主题",
            "Link to"				:	"链接到",	// As in "Link to http://www.punbb.org/"
            "Empty board"			:	"本版面目前没有帖子。",
            "Newest user"			:	"最新注册用户",
            "Users online"			:	"在线注册用户",
            "Guests online"			:	"在线访客",
            "No of users"			:	"总注册用户数",
            "No of topics"			:	"总主题数",
            "No of posts"			:	"总文章数",
            "Online"				:	"在线用户列表",	// As in "Online: User A, User B etc."
            "Board info"			:	"版面信息",
            "Board stats"			:	"版面状态",
            "User info"				:	"用户信息",
            
            // Miscellaneous
            "Wrong user/pass"		:	"用户名或者密码不正确。",
            "Forgotten pass"		:	"忘记密码？",
            "Login redirect"		:	"登录成功，跳转中 &hellip;",
            "Logout redirect"		:	"注销成功，跳转中 &hellip;",
            "No email match"		:	"输入的电子邮件地址不符合任何会员资料",
            "Request pass"			:	"申请新密码",
            "Request pass legend"	:	"请输入您注册时用的电子邮件地址。",
            "Request pass info"		:	"一封包含新密码以及激活新密码用的链接将寄到您指定的电子邮件地址。",
            "Not registered"		:	"还没注册？",
            "Login legend"			:	"请在下面输入您的用户名与密码",
            "Remember me"			:	"下次来访时自动登录。",
            "Login info"			:	"假如您尚未注册或者是忘记登录密码，请点击下面的链接。",
            "New password errors"		:	"新密码请求错误",
            "New passworderrors info"	:	"请更正一下错误：",
            
            // Forget password mail stuff
            "Forget mail"			:	"系统已发送电子邮件至您输入的地址，请按照邮件内容的提示激活您的新密码。如果您没有收到邮件，请联系论坛管理员：",
            "Email flood"			:	"此帳號在在一小時內已經申請過一次密碼重置，請等待 %s 分钟 再來提出重置密碼申請。"
            
        ]
    }

    override var zh_tw: [String : Any] {
        return [
            // Text orientation and encoding
            "lang_direction"		:	"ltr",	// ltr (Left-To-Right) or rtl (Right-To-Left)
            "lang_identifier"					:	"zh-CN",
            "lang_encoding"			:	"UTF-8",
            //"lang_multibyte"		:	true,

            // Number formatting
            "lang_decimal_point"				:	".",
            "lang_thousands_sep"				:	",",

            // Notices
            "Bad request"			:	"错误。您使用的连接有误或已失效。",
            "No view"				:	"您没有权限浏览该版块。",
            "No permission"			:	"您没有权限浏览该页面。",
            "Bad referrer"			:	"HTTP_REFERER 错误。您从未授权的地方连入本页。如果一再发生相同问题，请确认 「管理/Options 」 里的 「Base URL」 设定无误，并请通过点击论坛导航链接的方式进入本论坛其他页面。更多关于这项错误的资料请参考 PunBB 官方网站的技术文件。",
            "No cookie"				:	"登录成功，但cookies设置失败。请检查您的浏览器选项，打开cookies",
            "Pun include extension"  			:	"Unable to process user include %s from template %s. \"%s\" files are not allowed",
            "Pun include directory"				:	"Unable to process user include %s from template %s. Directory traversal is not allowed",
            "Pun include error"		:	"Unable to process user include %s from template %s. There is no such file in neither the template directory nor in the user include directory.",

            // Miscellaneous
            "Announcement"			:	"公告",
            "Options"				:	"选项",
            "Submit"				:	"提交",	// "name" of submit buttons
            "Ban message"			:	"您已被停权。",
            "Ban message 2"			:	"停权时效至",
            "Ban message 3"			:	"将您停权的管理员或版主给您的留言：",
            "Ban message 4"			:	"有任何疑问请与论坛管理员联系：",
            "Never"					:	"无",
            "Today"					:	"今天",
            "Yesterday"				:	"昨天",
            "Info"					:	"信息",		// a common table header
            "Go back"				:	"返回前页",
            "Maintenance"			:	"维护",
            "Redirecting"			:	"跳转中",
            "Click redirect"		:	"如果您不想再等，或是您的浏览器没有自动跳转到新页面，请单击此处。",
            "on"					:	"启用",		// as in "BBCode is on"
            "off"					:	"关闭",
            "Invalid email"		:	"您输入的电子邮件地址无效。",
            "Required"				:	"(必填)",
            "required field"		:	"为必填栏目。",	// for javascript form validation
            "Last post"				:	"最后回复来自",
            "by"					:	"作者",	// as in last post by someuser
            "New posts"				:	"新帖",	// the link that leads to the first new post (use &nbsp; for spaces)
            "New posts info"		:	"跳转到本主题第一篇新帖。",	// the popup text for new posts links
            "Username"				:	"用户名",
            "Password"				:	"密码",
            "Email"					:	"电子邮件",
            "Send email"			:	"发送电子邮件",
            "Moderated by"			:	"版主",
            "Registered"			:	"注册日期",
            "Subject"				:	"标题",
            "Message"				:	"内容",
            "Topic"					:	"主题",
            "Forum"					:	"版面",
            "Posts"					:	"帖数",
            "Replies"				:	"回复",
            "Pages"					:	"页次",
            "Page"					:	"第 %s 页",
            "BBCode"				:	"BBCode:",	// You probably shouldn"t change this
            "url tag"							:	"[url] 标签:",
            "img tag"				:	"[img] 标签:",
            "Smilies"				:	"表情符号:",
            "and"					:	"及",
            "Image link"			:	"图片",	// This is displayed (i.e. <image>) instead of images when "Show images" is disabled in the profile
            "wrote"					:	"写道:",	// For [quote]"s
            "Mailer"				:	"%s",	// As in "MyForums Mailer" in the signature of outgoing e-mails
            "Important information"	:	"重要信息",
            "Write message legend"	:	"写下您要回复的消息然后发送",
            "Previous"				:	"上一页",
            "Next"					:	"下一页",
            "Spacer"				:	"…", // Ellipsis for paginate

            // Title
            "Title"					:	"头衔",
            "Member"				:	"会员",	// Default title
            "Moderator"				:	"版主",
            "Administrator"			:	"论坛管理员",
            "Banned"				:	"停权",
            "Guest"					:	"访客",
            "[Deleted User]"        :   "[用戶已刪除]",

            // Stuff for include/parser.php
            "BBCode error no opening tag"		:	"[/%1$s] 缺少对应的 [%1$s]",
            "BBCode error invalid nesting"		:	"[%1$s] 嵌套在 [%2$s] 之中，这是不允许的",
            "BBCode error invalid self-nesting"	:	"[%s] 自我嵌套，这是不允许的",
            "BBCode error no closing tag"		:	"[%1$s] 缺少对应的 [/%1$s]",
            "BBCode error empty attribute"		:	"[%s] 标签留有空属性",
            "BBCode error tag not allowed"		:	"您所在的用户组不允许使用 [%s] 标签",
            "BBCode error tag url not allowed"	:	"您所在的用户组不允许发表网站链接",
            "BBCode code problem"				:	"你的 [code] 标签不正确",
            "BBCode list size error"			:	"列表过长，系统无法处理，请缩短长度！",

            // Stuff for the navigator (top of every page)
            "Gallery"				:	"画廊",
            "Library"				:	"图书馆",
            "Add image"				:	"上传图像",
            "Wiki"					:	"龙百科",
            "Main page"				:	"首页",
            "Index"					:	"论坛",
            "User list"				:	"用户列表",
            "Rules"					:  "站规",
            "Search"				:  "搜索",
            "Register"				:  "注册",
            "Login"					:  "登录",
            "Not logged in"			:  "您尚未登录。",
            "Profile"				:	"设置",
            "Logout"				:	"注销",
            "Logged in as"			:	"欢迎再度访问本论坛,",
            "Admin"					:	"管理",
            "Last visit"			:	"您上次来访时间是: %s",
            "Topic searches"					:	"帖子:",
            "New posts header"					:	"新帖",
            "Active topics"						:	"最近的",
            "Unanswered topics"					:	"无回复的",
            "Posted topics"						:	"参与过的",
            "Show new posts"		:	"列出所有新帖",
            "Show active topics"				:	"查找最近有回复的帖子",
            "Show unanswered topics"			:	"查找未被回复过的帖子",
            "Show posted topics"				:	"查找参与过的主题",
            "Mark all as read"		:	"把所有帖子标记为已读",
            "Mark forum read"		:	"把此版面标记为已读",
            "Title separator"		:	" / ",

            // Stuff for the page footer
            "Board footer"			:	"论坛页尾",
            "Jump to"				:	"快速跳转",
            "Go"					:	"进入版面",		// submit button in forum jump
            "Moderate topic"		:	"管理主题",
            "All"					:	"全部",
            "Move topic"			:  "移动主题",
            "Open topic"			:  "开启主题",
            "Close topic"			:  "关闭主题",
            "Unstick topic"			:  "取消主题置顶",
            "Stick topic"			:  "设定主题置顶",
            "Moderate forum"		:	"管理版面",
            "Powered by"			:	"Powered by %s",

            // Debug information
            "Debug table"						:	"除錯信息",
            "Querytime"							:	"Generated in %1$s seconds, %2$s queries executed",
            "Memory usage"						:	"Memory usage: %1$s",
            "Peak usage"						:	"(Peak: %1$s)",
            "Query times"						:	"Time (s)",
            "Query"								:	"Query",
            "Total query time"					:	"Total query time: %s",

            // Email related notifications
            "New user notification"				:	"通知 - 新用户注册",
            "New user message"					:	"用户 \"%s\" 于 %s 在论坛注册",
            "Banned email notification"			:	"通知 - 检测到被阻止的email",
            "Banned email register message"		:	"用户 \"%s\" 使用被阻止的email注册： %s",
            "Banned email change message"		:	"用户 \"%s\" 修改email为被阻止的地址： %s",
            "Banned email post message"			:	"用户 \"%s\" 使用被阻止的email发言： %s",
            "Duplicate email notification"		:	"通知 - 检测到重复的email",
            "Duplicate email register message"	:	"用户 \"%s\"  注册使用的email地址同时也属于： %s",
            "Duplicate email change message"	:	"用户 \"%s\" 修改后的email地址同时也属于： %s",
            "Report notification"				:	"报告(%d) - \"%s\"",
            "Report message 1"					:	"用户 \"%s\" 报告了如下资讯： %s",
            "Report message 2"					:	"缘由： %s",

            "User profile"						:	"用户资料： %s",
            "Post URL"							:	"帖子 URL: %s",
            "Email signature"					:	"论坛自动发信\n(请勿回复)",

            // For extern.php RSS feed
            "RSS description"					:	"位于 %s 的最新主题",
            "RSS description topic"				:	"位于 %s 的最新帖子",
            "RSS reply"							:	"回复： ", // The topic subject will be appended to this string (to signify a reply)
            "RSS active topics feed"			:	"RSS active topics feed",
            "Atom active topics feed"			:	"Atom active topics feed",
            "RSS forum feed"					:	"RSS forum feed",
            "Atom forum feed"					:	"Atom forum feed",
            "RSS topic feed"					:	"RSS topic feed",
            "Atom topic feed"					:	"Atom topic feed",

            // Admin related stuff in the header
            "New reports"						:	"There are new reports",
            "Maintenance mode enabled"			:	"Maintenance mode is enabled!",

            // Units for file sizes
            "Size unit B"						:	"%s B",
            "Size unit KiB"						:	"%s KiB",
            "Size unit MiB"						:	"%s MiB",
            "Size unit GiB"						:	"%s GiB",
            "Size unit TiB"						:	"%s TiB",
            "Size unit PiB"						:	"%s PiB",
            "Size unit EiB"						:	"%s EiB",


            // View recent posts
            "Recent posts"	         :  "最新帖",
            "Empty"	                :  "没有符合条件的帖子",
            "First page"	           :  "第一页",

            // Easy bbcode
            "Normal editor"	        :  "切换到普通编辑器",
            "Rich editor"	          :  "切换到图文编辑器",

            // Registor
            "Username space"			: "用户名不能含有空格，请重新选择。",

            // Anit-bot
            "Humantest failed"			: "您输入的验证答案有误，请再修改。",
            "Human Test"				: "验证",
            "Humantest info"			: "请回答下面的问题，谢谢。",
            "Question"					: "问题：",
            "Answer"					: "回答：",

            // forum.php
            "All topics"			: "所有主题",
            "Not labeled topics"	: "无分类主题",

            // index.php
            "Summary"				: "摘要",
            "Newest topic"			: "最新主题",
            "Newest reply"			: "最新回复",
            "Newest Wiki"			: "最新百科更新",
            "Newest RSS"			: "最新博客更新",
            "Show all RSS"			: "查看所有更新",
            "Add my blog"			: "我想让自己的博客显示在这里",
            "New"					: "新",
            "Newest image"			: "最新图画",
            "Random image"			: "随机图画",
            "View Latest Comments"	: "观看最新回应",
            "Add gallery item"		: "发表作品",
            "More"					: "查看更多...",

            // post.php
            "Topic type"			: "主题类型",
            "Not a valid topictype"	: "无效的主题类型",

            // profile.php
            "Section otherform"		: "个龙设定",
            "Post greater than"		: "发帖数大于 %s 可用",

            // topic.php
            "Show author posts"	: "只看该作者",
            "Show all posts"	: "显示全部楼层",
            "Reader mod"		: "使用小说阅读模式",
            "Quote reply"		: "引用",

            // notify
            "Notifies"			: "通知",
            "Notify like"		: "%s 喜欢你在 %s 中的发言",
            "Notify at"			: "%s 在 %s 中提到你",


            "Topics"				:  "主题",
            "Link to"				:	"链接到",	// As in "Link to http://www.punbb.org/"
            "Empty board"			:	"本版面目前没有帖子。",
            "Newest user"			:	"最新注册用户",
            "Users online"			:	"在线注册用户",
            "Guests online"			:	"在线访客",
            "No of users"			:	"总注册用户数",
            "No of topics"			:	"总主题数",
            "No of posts"			:	"总文章数",
            "Online"				:	"在线用户列表",	// As in "Online: User A, User B etc."
            "Board info"			:	"版面信息",
            "Board stats"			:	"版面状态",
            "User info"				:	"用户信息",
            
            // Miscellaneous
            "Wrong user/pass"		:	"用户名或者密码不正确。",
            "Forgotten pass"		:	"忘记密码？",
            "Login redirect"		:	"登录成功，跳转中 &hellip;",
            "Logout redirect"		:	"注销成功，跳转中 &hellip;",
            "No email match"		:	"输入的电子邮件地址不符合任何会员资料",
            "Request pass"			:	"申请新密码",
            "Request pass legend"	:	"请输入您注册时用的电子邮件地址。",
            "Request pass info"		:	"一封包含新密码以及激活新密码用的链接将寄到您指定的电子邮件地址。",
            "Not registered"		:	"还没注册？",
            "Login legend"			:	"请在下面输入您的用户名与密码",
            "Remember me"			:	"下次来访时自动登录。",
            "Login info"			:	"假如您尚未注册或者是忘记登录密码，请点击下面的链接。",
            "New password errors"		:	"新密码请求错误",
            "New passworderrors info"	:	"请更正一下错误：",
            
            // Forget password mail stuff
            "Forget mail"			:	"系统已发送电子邮件至您输入的地址，请按照邮件内容的提示激活您的新密码。如果您没有收到邮件，请联系论坛管理员：",
            "Email flood"			:	"此帳號在在一小時內已經申請過一次密碼重置，請等待 %s 分钟 再來提出重置密碼申請。"
            
        ]
    }
}
