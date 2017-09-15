
public struct YLDBbans {
    var id: UInt32
    var username: String?
    var ip: String?
    var email: String?
    var message: String?
    var expire: UInt32?
    var ban_creator: UInt32
    init(_ args: [String: Any]) {
        id = item(from: args["id"])
        username = item(from: args["username"])
        ip = item(from: args["ip"])
        email = item(from: args["email"])
        message = item(from: args["message"])
        expire = item(from: args["expire"])
        ban_creator = item(from: args["ban_creator"])
    }
}
public struct YLDBcategories {
    var id: UInt32
    var cat_name: String
    var disp_position: Int32
    init(_ args: [String: Any]) {
        id = item(from: args["id"])
        cat_name = item(from: args["cat_name"])
        disp_position = item(from: args["disp_position"])
    }
}
public struct YLDBcensoring {
    var id: UInt32
    var search_for: String
    var replace_with: String
    init(_ args: [String: Any]) {
        id = item(from: args["id"])
        search_for = item(from: args["search_for"])
        replace_with = item(from: args["replace_with"])
    }
}
public struct YLDBconfig {
    var conf_name: String
    var conf_value: String?
    init(_ args: [String: Any]) {
        conf_name = item(from: args["conf_name"])
        conf_value = item(from: args["conf_value"])
    }
}
public struct YLDBforum_perms {
    var group_id: Int32
    var forum_id: Int32
    var read_forum: Bool
    var post_replies: Bool
    var post_topics: Bool
    init(_ args: [String: Any]) {
        group_id = item(from: args["group_id"])
        forum_id = item(from: args["forum_id"])
        read_forum = item(from: args["read_forum"]) as Int8 == 0 ? false : true
        post_replies = item(from: args["post_replies"]) as Int8 == 0 ? false : true
        post_topics = item(from: args["post_topics"]) as Int8 == 0 ? false : true
    }
}
public struct YLDBforums {
    var id: UInt32
    var forum_name: String
    var forum_desc: String?
    var redirect_url: String?
    var moderators: String?
    var num_topics: UInt32
    var num_posts: UInt32
    var last_post: UInt32?
    var last_post_id: UInt32?
    var last_poster: String?
    var sort_by: Bool
    var disp_position: Int32
    var cat_id: UInt32
    init(_ args: [String: Any]) {
        id = item(from: args["id"])
        forum_name = item(from: args["forum_name"])
        forum_desc = item(from: args["forum_desc"])
        redirect_url = item(from: args["redirect_url"])
        moderators = item(from: args["moderators"])
        num_topics = item(from: args["num_topics"])
        num_posts = item(from: args["num_posts"])
        last_post = item(from: args["last_post"])
        last_post_id = item(from: args["last_post_id"])
        last_poster = item(from: args["last_poster"])
        sort_by = item(from: args["sort_by"]) as Int8 == 0 ? false : true
        disp_position = item(from: args["disp_position"])
        cat_id = item(from: args["cat_id"])
    }
}
public struct YLDBgroups {
    var g_id: UInt32
    var g_title: String
    var g_user_title: String?
    var g_promote_min_posts: UInt32
    var g_promote_next_group: UInt32
    var g_moderator: Bool
    var g_mod_edit_users: Bool
    var g_mod_rename_users: Bool
    var g_mod_change_passwords: Bool
    var g_mod_ban_users: Bool
    var g_mod_promote_users: Bool
    var g_read_board: Bool
    var g_view_users: Bool
    var g_post_replies: Bool
    var g_post_topics: Bool
    var g_edit_posts: Bool
    var g_delete_posts: Bool
    var g_delete_topics: Bool
    var g_post_links: Bool
    var g_set_title: Bool
    var g_search: Bool
    var g_search_users: Bool
    var g_send_email: Bool
    var g_post_flood: Int16
    var g_search_flood: Int16
    var g_email_flood: Int16
    var g_report_flood: Int16
    init(_ args: [String: Any]) {
        g_id = item(from: args["g_id"])
        g_title = item(from: args["g_title"])
        g_user_title = item(from: args["g_user_title"])
        g_promote_min_posts = item(from: args["g_promote_min_posts"])
        g_promote_next_group = item(from: args["g_promote_next_group"])
        g_moderator = item(from: args["g_moderator"]) as Int8 == 0 ? false : true
        g_mod_edit_users = item(from: args["g_mod_edit_users"]) as Int8 == 0 ? false : true
        g_mod_rename_users = item(from: args["g_mod_rename_users"]) as Int8 == 0 ? false : true
        g_mod_change_passwords = item(from: args["g_mod_change_passwords"]) as Int8 == 0 ? false : true
        g_mod_ban_users = item(from: args["g_mod_ban_users"]) as Int8 == 0 ? false : true
        g_mod_promote_users = item(from: args["g_mod_promote_users"]) as Int8 == 0 ? false : true
        g_read_board = item(from: args["g_read_board"]) as Int8 == 0 ? false : true
        g_view_users = item(from: args["g_view_users"]) as Int8 == 0 ? false : true
        g_post_replies = item(from: args["g_post_replies"]) as Int8 == 0 ? false : true
        g_post_topics = item(from: args["g_post_topics"]) as Int8 == 0 ? false : true
        g_edit_posts = item(from: args["g_edit_posts"]) as Int8 == 0 ? false : true
        g_delete_posts = item(from: args["g_delete_posts"]) as Int8 == 0 ? false : true
        g_delete_topics = item(from: args["g_delete_topics"]) as Int8 == 0 ? false : true
        g_post_links = item(from: args["g_post_links"]) as Int8 == 0 ? false : true
        g_set_title = item(from: args["g_set_title"]) as Int8 == 0 ? false : true
        g_search = item(from: args["g_search"]) as Int8 == 0 ? false : true
        g_search_users = item(from: args["g_search_users"]) as Int8 == 0 ? false : true
        g_send_email = item(from: args["g_send_email"]) as Int8 == 0 ? false : true
        g_post_flood = item(from: args["g_post_flood"])
        g_search_flood = item(from: args["g_search_flood"])
        g_email_flood = item(from: args["g_email_flood"])
        g_report_flood = item(from: args["g_report_flood"])
    }
}
public struct YLDBonline {
    var user_id: UInt32
    var ident: String
    var logged: UInt32
    var idle: Bool
    var last_post: UInt32?
    var last_search: UInt32?
    init(_ args: [String: Any]) {
        user_id = item(from: args["user_id"])
        ident = item(from: args["ident"])
        logged = item(from: args["logged"])
        idle = item(from: args["idle"]) as Int8 == 0 ? false : true
        last_post = item(from: args["last_post"])
        last_search = item(from: args["last_search"])
    }
}
public struct YLDBposts {
    var id: UInt32
    var poster: String
    var poster_id: UInt32
    var poster_ip: String?
    var poster_email: String?
    var message: String?
    var hide_smilies: Bool
    var posted: UInt32
    var edited: UInt32?
    var edited_by: String?
    var topic_id: UInt32
    init(_ args: [String: Any]) {
        id = item(from: args["id"])
        poster = item(from: args["poster"])
        poster_id = item(from: args["poster_id"])
        poster_ip = item(from: args["poster_ip"])
        poster_email = item(from: args["poster_email"])
        message = item(from: args["message"])
        hide_smilies = item(from: args["hide_smilies"]) as Int8 == 0 ? false : true
        posted = item(from: args["posted"])
        edited = item(from: args["edited"])
        edited_by = item(from: args["edited_by"])
        topic_id = item(from: args["topic_id"])
    }
}
public struct YLDBreports {
    var id: UInt32
    var post_id: UInt32
    var topic_id: UInt32
    var forum_id: UInt32
    var reported_by: UInt32
    var created: UInt32
    var message: String?
    var zapped: UInt32?
    var zapped_by: UInt32?
    init(_ args: [String: Any]) {
        id = item(from: args["id"])
        post_id = item(from: args["post_id"])
        topic_id = item(from: args["topic_id"])
        forum_id = item(from: args["forum_id"])
        reported_by = item(from: args["reported_by"])
        created = item(from: args["created"])
        message = item(from: args["message"])
        zapped = item(from: args["zapped"])
        zapped_by = item(from: args["zapped_by"])
    }
}
public struct YLDBsearch_cache {
    var id: UInt32
    var ident: String
    var search_data: String?
    init(_ args: [String: Any]) {
        id = item(from: args["id"])
        ident = item(from: args["ident"])
        search_data = item(from: args["search_data"])
    }
}
public struct YLDBsearch_matches {
    var post_id: UInt32
    var word_id: UInt32
    var subject_match: Bool
    init(_ args: [String: Any]) {
        post_id = item(from: args["post_id"])
        word_id = item(from: args["word_id"])
        subject_match = item(from: args["subject_match"]) as Int8 == 0 ? false : true
    }
}
public struct YLDBsearch_words {
    var id: UInt32
    var word: String
    init(_ args: [String: Any]) {
        id = item(from: args["id"])
        word = item(from: args["word"])
    }
}
public struct YLDBtopic_subscriptions {
    var user_id: UInt32
    var topic_id: UInt32
    init(_ args: [String: Any]) {
        user_id = item(from: args["user_id"])
        topic_id = item(from: args["topic_id"])
    }
}
public struct YLDBforum_subscriptions {
    var user_id: UInt32
    var forum_id: UInt32
    init(_ args: [String: Any]) {
        user_id = item(from: args["user_id"])
        forum_id = item(from: args["forum_id"])
    }
}
public struct YLDBtopics {
    var id: UInt32
    var poster: String
    var subject: String
    var posted: UInt32
    var first_post_id: UInt32
    var last_post: UInt32
    var last_post_id: UInt32
    var last_poster: String?
    var num_views: UInt32
    var num_replies: UInt32
    var closed: Bool
    var sticky: Bool
    var moved_to: UInt32?
    var forum_id: UInt32
    var special: Int32
    init(_ args: [String: Any]) {
        id = item(from: args["id"])
        poster = item(from: args["poster"])
        subject = item(from: args["subject"])
        posted = item(from: args["posted"])
        first_post_id = item(from: args["first_post_id"])
        last_post = item(from: args["last_post"])
        last_post_id = item(from: args["last_post_id"])
        last_poster = item(from: args["last_poster"])
        num_views = item(from: args["num_views"])
        num_replies = item(from: args["num_replies"])
        closed = item(from: args["closed"]) as Int8 == 0 ? false : true
        sticky = item(from: args["sticky"]) as Int8 == 0 ? false : true
        moved_to = item(from: args["moved_to"])
        forum_id = item(from: args["forum_id"])
        special = item(from: args["special"])
    }
}
public struct YLDBusers {
    var id: UInt32
    var group_id: UInt32
    var username: String
    var password: String
    var email: String
    var title: String?
    var realname: String?
    var url: String?
    var jabber: String?
    var icq: String?
    var msn: String?
    var aim: String?
    var yahoo: String?
    var location: String?
    var signature: String?
    var disp_topics: UInt8?
    var disp_posts: UInt8?
    var email_setting: Bool
    var notify_with_post: Bool
    var auto_notify: Bool
    var show_smilies: Bool
    var show_img: Bool
    var show_img_sig: Bool
    var show_avatars: Bool
    var show_sig: Bool
    var timezone: Float
    var dst: Float
    var time_format: Int8
    var date_format: Int8
    var language: String
    var style: String
    var num_posts: UInt32
    var last_post: UInt32?
    var last_search: UInt32?
    var last_email_sent: UInt32?
    var last_report_sent: UInt32?
    var registered: UInt32
    var registration_ip: String
    var last_visit: UInt32
    var admin_note: String?
    var activate_string: String?
    var activate_key: String?
    init(_ args: [String: Any]) {
        id = item(from: args["id"])
        group_id = item(from: args["group_id"])
        username = item(from: args["username"])
        password = item(from: args["password"])
        email = item(from: args["email"])
        title = item(from: args["title"])
        realname = item(from: args["realname"])
        url = item(from: args["url"])
        jabber = item(from: args["jabber"])
        icq = item(from: args["icq"])
        msn = item(from: args["msn"])
        aim = item(from: args["aim"])
        yahoo = item(from: args["yahoo"])
        location = item(from: args["location"])
        signature = item(from: args["signature"])
        disp_topics = item(from: args["disp_topics"])
        disp_posts = item(from: args["disp_posts"])
        email_setting = item(from: args["email_setting"]) as Int8 == 0 ? false : true
        notify_with_post = item(from: args["notify_with_post"]) as Int8 == 0 ? false : true
        auto_notify = item(from: args["auto_notify"]) as Int8 == 0 ? false : true
        show_smilies = item(from: args["show_smilies"]) as Int8 == 0 ? false : true
        show_img = item(from: args["show_img"]) as Int8 == 0 ? false : true
        show_img_sig = item(from: args["show_img_sig"]) as Int8 == 0 ? false : true
        show_avatars = item(from: args["show_avatars"]) as Int8 == 0 ? false : true
        show_sig = item(from: args["show_sig"]) as Int8 == 0 ? false : true
        timezone = item(from: args["timezone"])
        dst = Float(item(from: args["dst"]) as Int8)
        time_format = item(from: args["time_format"])//todo
        date_format = item(from: args["date_format"])//todo
        language = item(from: args["language"])
        style = item(from: args["style"])
        num_posts = item(from: args["num_posts"])
        last_post = item(from: args["last_post"])
        last_search = item(from: args["last_search"])
        last_email_sent = item(from: args["last_email_sent"])
        last_report_sent = item(from: args["last_report_sent"])
        registered = item(from: args["registered"])
        registration_ip = item(from: args["registration_ip"])
        last_visit = item(from: args["last_visit"])
        admin_note = item(from: args["admin_note"])
        activate_string = item(from: args["activate_string"])
        activate_key = item(from: args["activate_key"])
    }

    func isGuest() -> Bool {
        return id == 1
    }
}

public struct YLDBsite_info {
    var newestUserId: UInt32
    var newestUserName: String
    var totalUsers: UInt64
    var totalTopics: UInt64
    var totalPosts: UInt64

    init(_ args: [String: Any]) {
        newestUserId = item(from: args["user_id"])
        newestUserName = item(from: args["username"])
        totalUsers = item(from: args["total_users"])
        totalTopics = item(from: args["total_topics"])
        totalPosts = item(from: args["total_posts"])
    }
}

public struct YLDBdraconity {
    var userId: UInt32
    var useAvatar: Bool
    var resume: String
    var draconity: String
    var draconityOptions: String

    init(_ args: [String: Any]) {
        userId = item(from: args["user_id"])
        useAvatar = item(from: args["use_avatar"]) as Int8 == 0 ? false : true
        resume = item(from: args["resume"])
        draconity = item(from: args["dragoncode"])
        draconityOptions = item(from: args["draconity_ops"])
    }
}

public struct YLDBfolders {
    var id: UInt32
    var name: String
    var description: String
    var userId: UInt32

    init(_ args: [String: Any]) {
        id = item(from: args["id"])
        name = item(from: args["name"])
        description = item(from: args["description"])
        userId = item(from: args["user_id"])
    }
}

extension DataManager {

    public func getConfig() -> [String: String] {
        return memoryStorage.getConfigs()
    }

    public func getSiteInfo() -> YLDBsite_info {
        return memoryStorage.getSiteInfo()
    }

    public func getNewestTopics() -> [YLDBtopics] {
        return memoryStorage.getNewestTopics()
    }

    public func getUser(userID: UInt32) -> YLDBusers? {
        return memoryStorage.getUsers()[userID]
    }

    public func getUser(userName: String) throws -> YLDBusers? {
        guard let args = dbStorage.getUser(userName: userName) else {
            throw DataError.dbError
        }
        if args.count == 0 {
            return nil
        }
        return YLDBusers(args)
    }

    public func getDefaultUser(remoteAddress: String) throws -> YLDBusers? {
        guard let args = dbStorage.getDefaultUser(remoteAddress: remoteAddress) else {
            throw DataError.dbError
        }
        if args.count == 0 {
            return nil
        }
        return YLDBusers(args)
    }

    public func getGroup(id: UInt32) -> YLDBgroups? {
        return memoryStorage.getGroups()[id]
    }

    public func getForum(id: UInt32) -> YLDBforums? {
        return memoryStorage.getForums()[id]
    }

    public func getPermission(forumId: UInt32, groupId: UInt32) -> YLDBforum_perms? {
        for item in self.memoryStorage.getPermissions() {
            if UInt32(item.group_id) == groupId && UInt32(item.forum_id) == forumId {
                return item
            }
        }
        return nil
    }

    public func getTopic(id: UInt32) throws -> YLDBtopics? {
        guard let args = dbStorage.getTopic(id: id) else {
            throw DataError.dbError
        }
        if args.count == 0 {
            return nil
        }
        return YLDBtopics(args)
    }

    public func getTopics(forumIds: [UInt32], startFrom: UInt32, limit: UInt32) throws -> [YLDBtopics]? {
        guard let _topics = dbStorage.getTopics(forumIds: forumIds, startFrom: startFrom, limit: limit) else {
            throw DataError.dbError
        }
        if _topics.count == 0 {
            return nil
        }
        var topics: [YLDBtopics] = []
        for args in _topics {
            topics.append(YLDBtopics(args))
        }
        return topics
    }

    public func getPosts(topicId: UInt32, startFrom: UInt32, limit: UInt32) throws -> [YLDBposts]? {
        guard let _posts = dbStorage.getPosts(topicId: topicId, startFrom: startFrom, limit: limit) else {
            throw DataError.dbError
        }
        if _posts.count == 0 {
            return nil
        }
        var posts: [YLDBposts] = []
        for args in _posts {
            posts.append(YLDBposts(args))
        }
        return posts
    }

    public func getPost(id: UInt32) throws -> YLDBposts? {
        guard let args = dbStorage.getPost(id: id) else {
            throw DataError.dbError
        }
        if args.count == 0 {
            return nil
        }
        return YLDBposts(args)
    }

    public func locatePostInTopic(topicId: UInt32, posted: UInt32) -> UInt32? {
        return dbStorage.locatePostInTopic(topicId: topicId, posted: posted)
    }

    public func getForumName(id: UInt32) -> String {
        return memoryStorage.getForums()[id]?.forum_name ?? "Not Found"
    }

    public func getTotalTopics(forumIds: [UInt32]) -> UInt32 {
        var total: UInt32 = 0
        let forums = memoryStorage.getForums()
        for i in forumIds {
            if let num = forums[i]?.num_topics {
                total = total + num
            }
        }

        return total
    }

    public func updatePost(id: UInt32, message: String) -> Bool {
        return dbStorage.updatePost(id: id, message: message)
    }

    public func insertPost(topicId: UInt32, message: String, user: YLDBusers, remoteAddress: String, postTime: UInt32) throws -> UInt32 {
        guard let insertId = dbStorage.insertPost(topicId: topicId, message: message, user: user, remoteAddress: remoteAddress, postTime: postTime) else {
            throw DataError.dbError
        }

        return insertId
    }

    public func deletePost(id: UInt32) -> Bool {
        return dbStorage.deletePost(id: id)
    }

    public func updateTopicAfterNewPost(id: UInt32, lastPostId: UInt32, lastPoster: YLDBusers, lastPostTime: UInt32) -> Bool {
        return dbStorage.updateTopicAfterNewPost(id: id, lastPostId: lastPostId, lastPosterName: lastPoster.username, lastPostTime: lastPostTime)
    }

    public func updateTopic(id: UInt32, forumId: UInt32, subject: String, sticky: Bool) -> Bool {
        return dbStorage.updateTopic(id: id, forumId: forumId, subject: subject, sticky: sticky)
    }

    public func insertTopic(forumId: UInt32, subject: String, user: YLDBusers, postTime: UInt32, type:Int32, sticky: Bool) throws -> UInt32 {
        guard let insertId = dbStorage.insertTopic(forumId: forumId, subject: subject, user: user, postTime: postTime, type: type, sticky: sticky) else {
            throw DataError.dbError
        }

        return insertId
    }

    public func deleteTopic(id: UInt32) -> Bool {
        return dbStorage.deletePost(id: id)
    }

    public func getDraconity(userId: UInt32) throws -> YLDBdraconity? {
        guard let args = dbStorage.getDraconity(userId: userId) else {
            throw DataError.dbError
        }

        if args.count == 0 {
            return nil
        }

        return YLDBdraconity(args)
    }

    public func insertUpload(fileName: String, localName: String, localDirectory: String, mimeType: String, size: UInt32, hash: String, userId: UInt32, createTime: UInt32) throws -> UInt32 {
        guard let insertId = dbStorage.insertUpload(fileName: fileName, localName: localName, localDirectory: localDirectory, mimeType: mimeType, size: size, hash: hash, userId: userId, createTime: createTime) else {
            throw DataError.dbError
        }

        return insertId
    }

    public func insertFolder(name: String, description: String, ownerId: UInt32) throws -> UInt32 {
        guard let insertId = dbStorage.insertFolder(name: name, description: description, ownerId: ownerId) else {
            throw DataError.dbError
        }

        return insertId
    }
}

