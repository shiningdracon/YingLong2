import Foundation

public class ForumSessionInfo: SessionInfo {
    var userID: UInt32
    var passwordHash: String
    var expirationTime: Double
    var sessionHash: String

    init(remoteAddress: String, locale: i18nLocale, userID: UInt32, passwordHash: String, expirationTime: Double, sessionHash: String) {
        self.userID = userID
        self.passwordHash = passwordHash
        self.expirationTime = expirationTime
        self.sessionHash = sessionHash
        super.init(remoteAddress: remoteAddress, locale: locale)
    }
}

extension SiteController {
    enum TopicType: Int32 {
        case Normal = 0
        case Poll = 1
        case Text = 2
        case Painting = 3
        case Comic = 4
    }

    func hashEquals(a: String, b: String) -> Bool {
        var bufA = [UInt8](a.utf8)
        var bufB = [UInt8](b.utf8)
        if bufA.count == bufB.count {
            var result: UInt8 = 0
            var i = 0
            while i < bufA.count {
                result |= bufA[i] ^ bufB[i]
                i = i + 1
            }
            if result == 0 {
                return true
            }
        }

        return false;
    }

    func generateSessionPasswordHash(passwordHash: String) -> String? {
        guard let cookieSeed = siteConfig["cookieSeed"] else {
            fatalError("cookieSeed not set")
        }
        return utilities.forumHMAC(data: passwordHash, key: "\(cookieSeed)_cookie_hash")
    }

    func getDefaultUser(remoteAddress: String) throws -> YLDBusers? {
        return try dataManager.getDefaultUser(remoteAddress: remoteAddress)
    }

    func getLoginUser(username: String, password: String) throws -> YLDBusers? {
        if let user = try dataManager.getUser(userName: username) {
            if authenticateUser(localPasswordHash: user.password, password: password) {
                return user
            }
        }
        return nil
    }

    func getLoginUser(session: ForumSessionInfo) -> YLDBusers? {
        if let user = dataManager.getUser(userID: session.userID) {
            let now = utilities.getNow()
            if session.userID > 1 && Double(session.expirationTime) > now {
                if authenticateUser(localPasswordHash: user.password, sessionPasswordHash: session.passwordHash) {
                    return user
                }
            }
        }
        return nil
    }

    func getCurrentUser(session: ForumSessionInfo) throws -> YLDBusers? {
        if let user = getLoginUser(session: session) {
            return user
        } else {
            return try getDefaultUser(remoteAddress: session.remoteAddress)
        }
    }

    func authenticateUser(localPasswordHash: String, password: String) -> Bool {
        guard let passwordHash = utilities.sha1(string: password) else {
            return false
        }
        return hashEquals(a: localPasswordHash, b: passwordHash)
    }

    func authenticateUser(localPasswordHash: String, sessionPasswordHash: String) -> Bool {
        guard let localSessionPasswordHash = generateSessionPasswordHash(passwordHash: localPasswordHash) else {
            return false
        }
        return hashEquals(a: localSessionPasswordHash, b: sessionPasswordHash)
    }

    func getPaginate(total: UInt32, startFrom: UInt32, display: UInt32) -> [[String: Any]] {
        var paginate: [[String: Any]] = []
        let pages: UInt32 = total / display + 1
        let cur: UInt32 = startFrom / display + 1
        for p in 1...pages {
            var item: [String: Any] = [:]
            item["page"] = p
            if p == 1 {
                item["first_item?"] = true
            }
            if p == cur {
                item["current_page?"] = true
            }
            paginate.append(item)
        }
        return paginate
    }

    func getTopicList(forums: [UInt32], startFrom: UInt32, limit: UInt32, curUser: YLDBusers, locale: i18nLocale) throws -> [[String: Any]]? {
        if let topics = try dataManager.getTopics(from: forums, startFrom: startFrom, limit: limit) {
            var topicList: [[String: Any]] = []
            for onetopic in topics {
                var topic: [String: Any] = [:]
                topic["id"] = onetopic.id
                topic["subject"] = i18n(onetopic.subject, locale: locale)
                topic["poster"] = onetopic.poster
                topic["last_poster"] = onetopic.last_poster ?? ""
                topic["num_replies"] = onetopic.num_replies
                topic["last_post_time"] = formatTime(time: Double(onetopic.last_post), timezone: Int(curUser.timezone), daySavingTime: Int(curUser.dst))
                topic["is_painting"] = (onetopic.special == TopicType.Painting.rawValue)
                topic["forum_name"] = i18n(dataManager.getForumName(id: onetopic.forum_id), locale: locale)
                topic["forum_id"] = onetopic.forum_id
                topicList.append(topic)
            }
            return topicList
        } else {
            return nil
        }
    }

    func getPostList(topicId: UInt32, startFrom: UInt32, limit: UInt32, curUser: YLDBusers, locale: i18nLocale) throws -> [[String: Any]]? {
        if let posts = try dataManager.getPosts(topicId: topicId, startFrom: startFrom, limit: limit) {
            var postList: [[String: Any]] = []
            var postCount: UInt32 = startFrom
            for onepost in posts {
                if let user = dataManager.getUser(userID: onepost.poster_id) {
                    if let group = dataManager.getGroup(id: user.group_id) {
                        var post: [String: Any] = [:]
                        postCount += 1
                        if postCount == 1 {
                            post["firstpost"] = true
                        }
                        post["id"] = onepost.id
                        post["poster"] = onepost.poster
                        post["poster_id"] = onepost.poster_id
                        post["posted"] = formatTime(time: Double(onepost.posted), timezone: Int(curUser.timezone), daySavingTime: Int(curUser.dst))
                        post["message"] = i18n(try utilities.BBCode2HTML(bbcode: onepost.message ?? "", local: locale), locale: locale)
                        post["post_index"] = startFrom + postCount
                        if onepost.edited != nil {
                            post["edited"] = [
                                "edited": formatTime(time: Double(onepost.edited!), timezone: Int(curUser.timezone), daySavingTime: Int(curUser.dst)),
                                "edited_by": onepost.edited_by ?? ""
                                ] as [String: Any]
                        }
                        post["user_info"] = [
                            "user_title": user.title ?? group.g_title,
                            "registed": formatTime(time: Double(user.registered), timezone: Int(curUser.timezone), daySavingTime: Int(curUser.dst)),
                            "post_count": user.num_posts
                            ] as [String: Any]
                        postList.append(post)
                    }
                } else {
                    //TODO deleted user
                }
            }
            return postList
        } else {
            return nil
        }
    }

    func commonData(locale: i18nLocale) -> [String: Any] {
        let config = dataManager.getConfig()
        let forumInfo = dataManager.getForumInfo()
        return [
            "o_board_title": i18n(config["o_board_title"] ?? "", locale: locale),
            "lang": ForumI18n.instance.getI18n(locale),
            "newest_user": forumInfo.newestUserName,
            "total_users": forumInfo.totalUsers,
            "num_of_topics": forumInfo.totalTopics,
            "total_posts": forumInfo.totalPosts,
        ]
    }

    //该表格允许您为不同的用户组设置在该版块的不同权限。如果您未在此作任何变动，下表所列出的权限是用户组中相关设置的默认值。管理员组(Administrators)总是对所有版块拥有全权，因此无须设置。当某用户组的权限设置结果与其默认值不一致时，将会标示为红色。如果某用户组被拒绝“阅读论坛”，此处的“阅读版块”权限设置将不可用。转向出去的版块仅可编辑“阅读版块”的权限。
    func canPostTopic(group: YLDBgroups, permission: YLDBforum_perms?) -> Bool {
        if permission != nil {
            return (permission!.post_topics)
        } else {
            return group.g_post_topics
        }
    }

    func canPostReply(topic: YLDBtopics, group: YLDBgroups, permission: YLDBforum_perms?) -> Bool {
        if topic.closed {
            return false
        }
        if permission != nil {
            return (permission!.post_replies)
        } else {
            return group.g_post_replies
        }
    }

    // POST handlers
    public func loginHandler(session: SessionInfo, username: String, password: String, savepass: Bool, redirectURL: String) -> SiteResponse {
        let config = dataManager.getConfig()
        do {
            if username.characters.count > 0 && password.characters.count > 0 {
                if let user = try getLoginUser(username: username, password: password) {
                    let expire = savepass ? utilities.getNow() + 1209600 : utilities.getNow() + Double.init(config["o_timeout_visit"]!)!
                    let sessionPasswordHash = generateSessionPasswordHash(passwordHash: user.password)
                    guard let cookieSeed = siteConfig["cookieSeed"] else {
                        fatalError("cookieSeed not set")
                    }
                    let sessionHash = self.utilities.forumHMAC(data: "\(user.id)|\(expire)", key: "\(cookieSeed)_cookie_hash")
                    if sessionPasswordHash != nil && sessionHash != nil {
                        let forumSession = ForumSessionInfo(remoteAddress: session.remoteAddress, locale: session.locale, userID: user.id, passwordHash: sessionPasswordHash!, expirationTime: expire, sessionHash: sessionHash!)
                        return SiteResponse(status: .Redirect(location: redirectURL), session: forumSession)
                    }
                }
            }
            var data = commonData(locale: session.locale)
            data["page_title"] = ForumI18n.instance.getI18n(session.locale, key: "Login")
            let errors: [String: String] = ["description": ForumI18n.instance.getI18n(session.locale, key: "Wrong user/pass")]
            data["errors"] = errors
            return SiteResponse(status: .OK(view: "login.mustache", data: data), session: nil)
        } catch is DataError {
            return SiteResponse(status: .Error(message: "DB failed"), session: session)
        } catch {
            return SiteResponse(status: .Error(message: "Unknow error"), session: session)
        }
    }

    public func postTopicHandler(session: ForumSessionInfo, subject: String, message: String, forumId: UInt32) -> SiteResponse {

        var success = false
        dataManager.transactionStart()

        defer {
            if success {
                dataManager.transactionCommit()
            } else {
                dataManager.transactionRollback()
            }
        }

        do {
            if let user = try getCurrentUser(session: session) {
                if let group = dataManager.getGroup(id: user.group_id) {
                    let permission = dataManager.getPermission(forumId: forumId, groupId: user.group_id)
                    if canPostTopic(group: group, permission: permission) {

                        _ = try self.utilities.BBCode2HTML(bbcode: message, local: session.locale)

                        let now = UInt32(self.utilities.getNow())
                        if let insertTopicId = dataManager.insertTopic(forumId: forumId, subject: subject, user: user, postTime: now, type: 0, sticky: false) {
                            if let _ = dataManager.insertPost(topicId: insertTopicId, message: message, user: user, remoteAddress: session.remoteAddress, postTime: now) {
                                if dataManager.updateTopic(id: insertTopicId, lastPostId: insertTopicId, lastPoster: user, lastPostTime: UInt32(now)) {
                                    success = true
                                    return SiteResponse(status: .Redirect(location: "/topic/\(insertTopicId)"), session: session)
                                }
                            }
                        }
                    } else {
                        return errorNotifyPage(session: session, message: "No permission")
                    }
                }
            }
            return SiteResponse(status: .NotFound, session: session)
        } catch WebFrameworkError.BBCodeError(let detail) {
            return SiteResponse(status: .Error(message: detail), session: session)
        } catch is DataError {
            return SiteResponse(status: .Error(message: "DB failed"), session: session)
        } catch {
            return SiteResponse(status: .Error(message: "Unknow error"), session: session)
        }
    }

    public func postReplyHandler(session: ForumSessionInfo, topicId: UInt32, message: String) -> SiteResponse {

        var success = false
        dataManager.transactionStart()

        defer {
            if success {
                dataManager.transactionCommit()
            } else {
                dataManager.transactionRollback()
            }
        }

        do {
            if topicId > 0 {
                if let user = try getCurrentUser(session: session) {
                    if let group = dataManager.getGroup(id: user.group_id) {
                        if let topic = try dataManager.getTopic(id: topicId) {
                            let permission = dataManager.getPermission(forumId: topic.forum_id, groupId: user.group_id)
                            if canPostReply(topic: topic, group: group, permission: permission) {

                                _ = try self.utilities.BBCode2HTML(bbcode: message, local: session.locale)

                                let now = UInt32(self.utilities.getNow())
                                let remoteAddress = session.remoteAddress
                                if let insertPostId = dataManager.insertPost(topicId: topicId, message: message, user: user, remoteAddress: remoteAddress, postTime: now) {
                                    if dataManager.updateTopic(id: topicId, lastPostId: insertPostId, lastPoster: user, lastPostTime: UInt32(now)) {
                                        success = true
                                        return SiteResponse(status: .Redirect(location: "/post/\(insertPostId)"), session: session)
                                    }
                                }
                            } else {
                                return errorNotifyPage(session: session, message: "No permission")
                            }
                        }
                    }
                }
            }
            return SiteResponse(status: .NotFound, session: session)
        } catch WebFrameworkError.BBCodeError(let detail) {
            return SiteResponse(status: .Error(message: detail), session: session)
        } catch is DataError {
            return SiteResponse(status: .Error(message: "DB failed"), session: session)
        } catch {
            return SiteResponse(status: .Error(message: "Unknow error"), session: session)
        }
    }

    // GET handlers
    public func mainPage(session: ForumSessionInfo, page: UInt32) -> SiteResponse {

        let config = dataManager.getConfig()
        do {
            let p = page <= 1 ? 0 : page - 1
            if let user = try getCurrentUser(session: session) {

                var data = commonData(locale: session.locale)
                data["page_title"] = i18n(config["o_board_title"] ?? "", locale: session.locale)
                if user.isGuest() == false {
                    data["user"] = [
                        "username": user.username
                    ]
                }

                let display: UInt32 = UInt32(user.disp_topics ?? (UInt8.init(config["o_disp_topics_default"] ?? "50") ?? 50))
                let startFrom: UInt32 = p * display
                data["paginate"] = getPaginate(total: 100, startFrom: startFrom, display: display)

                var newestTopics: [[String: Any]] = []
                let topicArray = dataManager.getNewestTopics()
                for t in topicArray {
                    newestTopics.append(["subject": i18n(t.subject, locale: session.locale), "topic_id": t.id])
                }
                data.update(other: [//TODO
                    "collection_list": [["name": "All", "url": "#", "current": true]] as [[String: Any]],
                    "newest_topic_list": newestTopics
                    ] as [String : Any])
                //TODO: forums
                if let topics = try getTopicList(forums: [1, 5, 7, 11], startFrom: startFrom, limit: display, curUser: user, locale: session.locale) {
                    if topics.count > 0 {
                        data["topic_list"] = topics
                    }
                    return SiteResponse(status: .OK(view: "main.mustache", data: data), session: session)
                }
            }
            return SiteResponse(status: .NotFound, session: session)
        } catch is DataError {
            return SiteResponse(status: .Error(message: "DB failed"), session: session)
        } catch {
            return SiteResponse(status: .Error(message: "Unknow error"), session: session)
        }
    }

    public func topicPage(session: ForumSessionInfo, id: UInt32, page: UInt32) -> SiteResponse {
        let config = dataManager.getConfig()
        do {
            let p = page <= 1 ? 0 : page - 1
            if let user = try getCurrentUser(session: session) {
                var data = commonData(locale: session.locale)
                if user.isGuest() == false {
                    data["user"] = [
                        "username": user.username
                    ]
                }
                let display: UInt32 = UInt32(user.disp_posts ?? (UInt8.init(config["o_disp_posts_default"] ?? "25") ?? 25))
                let startFrom: UInt32 = p * display
                if let topic = try dataManager.getTopic(id: id) {
                    let subject = i18n(topic.subject, locale: session.locale)
                    let forumName = i18n(dataManager.getForumName(id: topic.forum_id), locale: session.locale)
                    data["page_title"] = subject + " / " + forumName + " / " + (i18n(config["o_board_title"] ?? "", locale: session.locale))
                    data["topic_id"] = id
                    data["subject"] = subject
                    data["paginate"] = getPaginate(total: topic.num_replies, startFrom: startFrom, display: display)
                    data["forum_id"] = topic.forum_id
                    data["forum_name"] = forumName
                    if let posts = try getPostList(topicId: id, startFrom: startFrom, limit: display, curUser: user, locale: session.locale) {
                        if posts.count > 0 {
                            data["post_list"] = posts
                        }
                        return SiteResponse(status: .OK(view: "viewtopic.mustache", data: data), session: session)
                    }
                }
            }
            return SiteResponse(status: .NotFound, session: session)
        } catch WebFrameworkError.BBCodeError(let detail) {
            return SiteResponse(status: .Error(message: detail), session: session)
        } catch is DataError {
            return SiteResponse(status: .Error(message: "DB failed"), session: session)
        } catch {
            return SiteResponse(status: .Error(message: "Unknow error"), session: session)
        }
    }

    public func topicPage(session: ForumSessionInfo, postId: UInt32) -> SiteResponse {
        let config = dataManager.getConfig()
        do {
            if let post = try dataManager.getPost(id: postId) {
                if let postLocation = dataManager.locatePostInTopic(topicId: post.topic_id, posted: post.posted) {
                    if let user = try getCurrentUser(session: session) {
                        let display: UInt32 = UInt32(user.disp_posts ?? (UInt8(config["o_disp_posts_default"] ?? "25") ?? 25))
                        let page: UInt32 = ((postLocation + 1) / display) + 1
                        //TODO: which one is better? server side or client side?
                        // server side can save time. client side can change url and is one url one resouse
                        //return topicPage(session: session, id: post.topic_id, page: page)
                        return SiteResponse(status: .Redirect(location: "/topic/\(post.topic_id)/\(page)#p\(postId)"), session: session)
                    }
                }
            }
            return SiteResponse(status: .NotFound, session: session)
        } catch is DataError {
            return SiteResponse(status: .Error(message: "DB failed"), session: session)
        } catch {
            return SiteResponse(status: .Error(message: "Unknow error"), session: session)
        }
    }

    public func forumPage(session: ForumSessionInfo, id: UInt32, page: UInt32) -> SiteResponse {
        let config = dataManager.getConfig()
        do {
            let p = page <= 1 ? 0 : page - 1
            if let user = try getCurrentUser(session: session) {
                var data = commonData(locale: session.locale)
                if user.isGuest() == false {
                    data["user"] = [
                        "username": user.username
                    ]
                }
                let display: UInt32 = UInt32(user.disp_posts ?? (UInt8.init(config["o_disp_posts_default"] ?? "25") ?? 25))
                let startFrom: UInt32 = p * display
                if let forum = dataManager.getForum(id: id) {
                    let forumName = i18n(forum.forum_name, locale: session.locale)
                    data["page_title"] = forumName + " / " + (i18n(config["o_board_title"] ?? "", locale: session.locale))
                    data["forum_id"] = id
                    data["paginate"] = getPaginate(total: forum.num_topics, startFrom: startFrom, display: display)
                    if let topics = try getTopicList(forums: [id], startFrom: startFrom, limit: display, curUser: user, locale: session.locale) {
                        if topics.count > 0 {
                            data["topic_list"] = topics
                        }
                        return SiteResponse(status: .OK(view: "viewforum.mustache", data: data), session: session)
                    }
                }
            }
            return SiteResponse(status: .NotFound, session: session)
        } catch is DataError {
            return SiteResponse(status: .Error(message: "DB failed"), session: session)
        } catch {
            return SiteResponse(status: .Error(message: "Unknow error"), session: session)
        }
    }

    public func loginPage(session: ForumSessionInfo) -> SiteResponse {
        var data = commonData(locale: session.locale)
        data["page_title"] = ForumI18n.instance.getI18n(session.locale, key: "Login")
        return SiteResponse(status: .OK(view: "login.mustache", data: data), session: nil)
    }

    public func forgetPage(session: ForumSessionInfo) -> SiteResponse {
        var data = commonData(locale: session.locale)
        data["page_title"] = ForumI18n.instance.getI18n(session.locale, key: "Request pass")
        return SiteResponse(status: .OK(view: "forget.mustache", data: data), session: nil)
    }

    public func logoutHandler(session: ForumSessionInfo, csrf: String) -> SiteResponse {
        // TODO
        return SiteResponse(status: .Redirect(location: "/"), session: nil)
    }

}
