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

enum ForumError: Error {
    case GenerateCSRFError
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

    func CSRFToken(session: ForumSessionInfo) throws -> String {
        guard let cookieSeed = siteConfig["cookieSeed"] else {
            fatalError("cookieSeed not set")
        }
        if let token = utilities.forumHMAC(data: "\(session.userID)\(session.passwordHash)", key: "\(cookieSeed)_cookie_hash") {
            return token
        } else {
            throw ForumError.GenerateCSRFError
        }
    }

    func checkCSRF(session: ForumSessionInfo, token: String) throws -> Bool {
        return hashEquals(a: token, b: try CSRFToken(session: session))
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

    // Caller should make sure "total" is greater than "startFrom"
    func getPaginate(total: UInt32, startFrom: UInt32, display: UInt32) -> [[String: Any]] {
        var paginate: [[String: Any]] = []
        let totalPages: UInt32 = total / display + 1
        let curPage: UInt32 = startFrom / display + 1

        var pages: Array<UInt32> = []
        if totalPages <= 7 {
            pages.append(contentsOf: 1...totalPages)
        } else {
            var curBlockEdgeLeft: UInt32
            var curBlockEdgeRight: UInt32

            if curPage >= 3 {
                curBlockEdgeLeft = curPage - 2
            } else {
                curBlockEdgeLeft = 1
            }

            if curBlockEdgeLeft <= 2 {
                curBlockEdgeRight = 7
            } else {
                curBlockEdgeRight = curBlockEdgeLeft + 4
            }
            if curBlockEdgeRight + 2 > totalPages {
                let overflowRight = curBlockEdgeRight + 2 - totalPages
                if curBlockEdgeLeft > overflowRight {
                    curBlockEdgeLeft = curBlockEdgeLeft - overflowRight
                } else {
                    curBlockEdgeLeft = 1
                }
                curBlockEdgeRight = totalPages
            }

            if curBlockEdgeLeft == 2 {
                pages.append(1)
            } else if curBlockEdgeLeft == 3 {
                pages.append(1)
                pages.append(2)
            } else if curBlockEdgeLeft > 3 {
                pages.append(1)
                pages.append(0)
            }

            pages.append(contentsOf: curBlockEdgeLeft...curBlockEdgeRight)

            if curBlockEdgeRight + 2 < totalPages {
                pages.append(0)
                pages.append(totalPages)
            } else if curBlockEdgeRight + 2 == totalPages {
                pages.append(totalPages - 1)
                pages.append(totalPages)
            } else if curBlockEdgeRight + 1 == totalPages {
                pages.append(totalPages)
            }
        }

        for p in pages {
            var item: [String: Any] = [:]
            if p == 0 {
                item["suspension?"] = true
            } else {
                item["page"] = p
                if p == 1 {
                    item["first_item?"] = true
                }
                if p == curPage {
                    item["current_page?"] = true
                }
            }
            paginate.append(item)
        }
        return paginate
    }

    func getTopicList(forumIds: [UInt32], startFrom: UInt32, limit: UInt32, curUser: YLDBusers, locale: i18nLocale) throws -> [[String: Any]]? {
        if let topics = try dataManager.getTopics(forumIds: forumIds, startFrom: startFrom, limit: limit) {
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
                topic["last_post_id"] = onetopic.last_post_id
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
                var post: [String: Any] = [:]
                postCount += 1
                if postCount == 1 {
                    post["firstpost"] = true
                }
                post["id"] = onepost.id
                post["poster"] = onepost.poster
                post["poster_id"] = onepost.poster_id
                post["posted"] = formatTime(time: Double(onepost.posted), timezone: Int(curUser.timezone), daySavingTime: Int(curUser.dst))
                post["message"] = i18n(try utilities.BBCode2HTML(bbcode: onepost.message ?? "", local: locale, configuration: ["post number": Int(curUser.num_posts)]), locale: locale)
                post["post_index"] = startFrom + postCount
                if onepost.edited != nil {
                    post["edited"] = [
                        "edited": formatTime(time: Double(onepost.edited!), timezone: Int(curUser.timezone), daySavingTime: Int(curUser.dst)),
                        "edited_by": onepost.edited_by ?? ""
                        ] as [String: Any]
                }

                if let user = dataManager.getUser(userID: onepost.poster_id) {
                    if let group = dataManager.getGroup(id: user.group_id) {
                        post["user_info"] = [
                            "title": user.title ?? group.g_title,
                            //"registed": formatTime(time: Double(user.registered), timezone: Int(curUser.timezone), daySavingTime: Int(curUser.dst)),
                            //"avatar_url": "", //TODO
                            ] as [String: Any]
                        postList.append(post)
                    } else {
                        // Unexpected
                    }
                } else {
                    // Deleted user
                    post["user_info"] = [
                        "user_title": ForumI18n.instance.getI18n(locale, key: "[Deleted User]"),
                        ] as [String: Any]
                    postList.append(post)
                }
            }
            return postList
        } else {
            return nil
        }
    }

    func commonData(locale: i18nLocale) -> [String: Any] {
        let config = dataManager.getConfig()
        let siteInfo = dataManager.getSiteInfo()
        return [
            "o_board_title": i18n(config["o_board_title"] ?? "", locale: locale),
            "lang": ForumI18n.instance.getI18n(locale),
            "newest_user": siteInfo.newestUserName,
            "total_users": siteInfo.totalUsers,
            "num_of_topics": siteInfo.totalTopics,
            "total_posts": siteInfo.totalPosts,
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

    public func insertUploadedFile(fileName: String, localName: String, localDirectory: String, mimeType: String, size: UInt32, hash: String, userId: UInt32) throws -> UInt32 {
        let now = UInt32(self.utilities.getNow())
        return try self.dataManager.insertUpload(fileName: fileName, localName: localName, localDirectory: localDirectory, mimeType: mimeType, size: size, hash: hash, userId: userId, createTime: now)
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

    public func postTopicHandler(session: ForumSessionInfo, subject: String, message: String, forumId: UInt32, attachedFile: String? = nil) -> SiteResponse {

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

                        _ = try self.utilities.BBCode2HTML(bbcode: message, local: session.locale, configuration: nil)

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

                                _ = try self.utilities.BBCode2HTML(bbcode: message, local: session.locale, configuration: nil)

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

    public func postFileHandler(session: ForumSessionInfo, files: Array<(path: String, fileName: String, contentType: String)>) -> SiteResponse {
        var success = false
        dataManager.transactionStart()

        defer {
            if success {
                dataManager.transactionCommit()
            } else {
                dataManager.transactionRollback()
            }
        }

        //TODO: upload dir
        //TODO: upload type (topic, post, pm, chat)

        let imageVersions = [
            ImageUploader.ImageOptions(uploadDir: "", nameSufix: "", maxWidth: 2048, maxHeight: 2048, quality: 100, rotateByExif: true, crop: false),
            ImageUploader.ImageOptions(uploadDir: "", nameSufix: "thumbnail", maxWidth: 300, maxHeight: 300, quality: 77, rotateByExif: true, crop: true)
        ]
        let uploader = ImageUploader(imageVersions: imageVersions)

        var results: Array<Dictionary<String, Any>> = []
        for file in files {
            do {
                var contentType = file.contentType
                if contentType == "" {
                    let ext = file.fileName.filePathExtension
                    if ext == "jpg" || ext == "jpeg" {
                        contentType = "image/jpeg"
                    } else if ext == "png" {
                        contentType = "image/png"
                    }
                }
                let newNamePrefix = self.utilities.UUID()
                let images = try uploader.uploadByFile(path: file.path, contentType: file.contentType, localNamePrefix: newNamePrefix)
                for image in images {
                    let fileId = try insertUploadedFile(fileName: file.fileName, localName: image.name, localDirectory: "", mimeType: contentType, size: UInt32(image.size), hash: image.hash, userId: session.userID)
                    results.append([
                        "id": fileId,
                        "name": file.fileName,
                        "path": image.path,
                        "width": image.width,
                        "height": image.height
                        ])
                }
            } catch ImageUploader.ImageUploadError.IOError(let detail) {
                return SiteResponse(status: .Error(message: detail), session: session)
            } catch ImageUploader.ImageUploadError.OperationError(let detail) {
                return SiteResponse(status: .Error(message: detail), session: session)
            } catch ImageUploader.ImageUploadError.TypeError {
                return SiteResponse(status: .Error(message: "File type not supported"), session: session)
            } catch ImageUploader.ImageUploadError.ValidationError {
                return SiteResponse(status: .Error(message: "Invalid file"), session: session)
            } catch {
                return SiteResponse(status: .Error(message: "Unknow error"), session: session)
            }
        }
        success = true
        return SiteResponse(status: .OK(view: "uploaded.json", data: results), session: session)
    }

    // GET handlers
    public func mainPage(session: ForumSessionInfo, tab: UInt32, page: UInt32) -> SiteResponse {

        let config = dataManager.getConfig()
        do {
            let p = page <= 1 ? 0 : page - 1
            if let user = try getCurrentUser(session: session) {
                var data = commonData(locale: session.locale)
                data["page_title"] = i18n(config["o_board_title"] ?? "", locale: session.locale)
                if user.isGuest() == false {
                    data["user"] = [
                        "username": user.username,
                        "userID": user.id,
                        "csrf_token": try CSRFToken(session: session)
                    ]
                } else {
                    return SiteResponse(status: .Redirect(location: "/login"), session: nil)
                }

                var newestTopics: [[String: Any]] = []
                let topicArray = dataManager.getNewestTopics()
                for t in topicArray {
                    newestTopics.append(["subject": i18n(t.subject, locale: session.locale), "id": t.id])
                }
                data.update(other: [//TODO
                    "collection_list": [["name": "All", "url": "#", "current": true]] as [[String: Any]],
                    "newest_topic_list": newestTopics
                    ] as [String : Any])
                //TODO: forumIds
                let totalTopics = dataManager.getTotalTopics(forumIds: [1, 5, 7, 11])
                let display: UInt32 = UInt32(user.disp_topics ?? (UInt8.init(config["o_disp_topics_default"] ?? "50") ?? 50))
                let startFrom: UInt32 = p * display
                if totalTopics >= startFrom {
                    data["paginate"] = getPaginate(total: totalTopics, startFrom: startFrom, display: display)

                    if let topics = try getTopicList(forumIds: [1, 5, 7, 11], startFrom: startFrom, limit: display, curUser: user, locale: session.locale) {
                        if topics.count > 0 {
                            data["topic_list"] = topics
                        }
                        return SiteResponse(status: .OK(view: "main.mustache", data: data), session: session)
                    }
                }
            }
            return SiteResponse(status: .NotFound, session: session)
        } catch is DataError {
            return SiteResponse(status: .Error(message: "DB failed"), session: session)
        } catch ForumError.GenerateCSRFError {
            return SiteResponse(status: .Error(message: "Generate CSRF token failed"), session: session)
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
                        "username": user.username,
                        "userID": user.id,
                        "csrf_token": try CSRFToken(session: session)
                    ]
                } else {
                    return SiteResponse(status: .Redirect(location: "/login"), session: nil)
                }

                let display: UInt32 = UInt32(user.disp_posts ?? (UInt8.init(config["o_disp_posts_default"] ?? "25") ?? 25))
                let startFrom: UInt32 = p * display
                if let topic = try dataManager.getTopic(id: id) {
                    let subject = i18n(topic.subject, locale: session.locale)
                    let forumName = i18n(dataManager.getForumName(id: topic.forum_id), locale: session.locale)
                    data["page_title"] = subject + " / " + forumName + " / " + (i18n(config["o_board_title"] ?? "", locale: session.locale))
                    data["topic_id"] = id
                    data["subject"] = subject
                    data["forum_id"] = topic.forum_id
                    data["forum_name"] = forumName
                    if topic.num_replies > startFrom {
                        data["paginate"] = getPaginate(total: topic.num_replies, startFrom: startFrom, display: display)
                        if let posts = try getPostList(topicId: id, startFrom: startFrom, limit: display, curUser: user, locale: session.locale) {
                            if posts.count > 0 {
                                data["post_list"] = posts
                            }
                            return SiteResponse(status: .OK(view: "viewtopic.mustache", data: data), session: session)
                        }
                    }
                }
            }
            return SiteResponse(status: .NotFound, session: session)
        } catch WebFrameworkError.BBCodeError(let detail) {
            return SiteResponse(status: .Error(message: detail), session: session)
        } catch is DataError {
            return SiteResponse(status: .Error(message: "DB failed"), session: session)
        } catch ForumError.GenerateCSRFError {
            return SiteResponse(status: .Error(message: "Generate CSRF token failed"), session: session)
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
                        if user.isGuest() {
                            return SiteResponse(status: .Redirect(location: "/login"), session: nil)
                        }
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
                        "username": user.username,
                        "userID": user.id,
                        "csrf_token": try CSRFToken(session: session)
                    ]
                } else {
                    return SiteResponse(status: .Redirect(location: "/login"), session: nil)
                }

                var newestTopics: [[String: Any]] = []
                let topicArray = dataManager.getNewestTopics() //TODO: for all forum or for current forum?
                for t in topicArray {
                    newestTopics.append(["subject": i18n(t.subject, locale: session.locale), "id": t.id])
                }
                data.update(other: [
                    "newest_topic_list": newestTopics
                    ] as [String : Any])

                let display: UInt32 = UInt32(user.disp_posts ?? (UInt8.init(config["o_disp_posts_default"] ?? "25") ?? 25))
                let startFrom: UInt32 = p * display
                if let forum = dataManager.getForum(id: id) {
                    let forumName = i18n(forum.forum_name, locale: session.locale)
                    data["page_title"] = forumName + " / " + (i18n(config["o_board_title"] ?? "", locale: session.locale))
                    data["forum_id"] = id
                    if forum.num_topics > startFrom {
                        data["paginate"] = getPaginate(total: forum.num_topics, startFrom: startFrom, display: display)
                        if let topics = try getTopicList(forumIds: [id], startFrom: startFrom, limit: display, curUser: user, locale: session.locale) {
                            if topics.count > 0 {
                                data["topic_list"] = topics
                            }
                            return SiteResponse(status: .OK(view: "viewforum.mustache", data: data), session: session)
                        }
                    }
                }
            }
            return SiteResponse(status: .NotFound, session: session)
        } catch is DataError {
            return SiteResponse(status: .Error(message: "DB failed"), session: session)
        } catch ForumError.GenerateCSRFError {
            return SiteResponse(status: .Error(message: "Generate CSRF token failed"), session: session)
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
        do {
            if try checkCSRF(session: session, token: csrf) {
                return SiteResponse(status: .Redirect(location: "/"), session: nil)
            } else {
                return SiteResponse(status: .Error(message: "CSRF check failed"), session: session)
            }
        } catch ForumError.GenerateCSRFError {
            return SiteResponse(status: .Error(message: "Generate CSRF token failed"), session: session)
        } catch {
            return SiteResponse(status: .Error(message: "Unknow error"), session: session)
        }
    }

    public func draconityPage(session: ForumSessionInfo, userId: UInt32) -> SiteResponse {
        do {
            if let user = try getCurrentUser(session: session) {
                if let group = dataManager.getGroup(id: user.id) {
                    if group.g_view_users {
                        var data = commonData(locale: session.locale)
                        data["page_title"] = ForumI18n.instance.getI18n(session.locale, key: "Draconity")

                        if let userToBeView = dataManager.getUser(userID: userId) {
                            data["viewuser"] = [
                                "username": userToBeView.username,
                                "userID": userToBeView.id
                            ]

                            if let draconity = try dataManager.getDraconity(userId: userId) {
                                data["draconity"] = [
                                    "resume": draconity.resume,
                                    "draconity": draconity.draconity
                                ]
                                return SiteResponse(status: .OK(view: "draconity.mustache", data: data), session: nil)
                            }
                        }
                    } else {
                        return errorNotifyPage(session: session, message: "No permission")
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
}
