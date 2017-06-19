import Foundation

extension DatabaseStorage {
    public func getAllConfigs() -> [String: String]? {
        guard let results = db.select(statement: "select * from \(prefix)config", params: []) else {
            return nil
        }

        defer {
            db.clear()
        }

        if results.count > 0 {
            var configs = [String: String]()
            for row in results {
                if let value: String = item(from: row["conf_value"]) {
                    configs[item(from: row["conf_name"])] = value
                } else {
                    configs[item(from: row["conf_name"])] = ""
                }
            }
            return configs
        }
        return nil
    }

    public func getForumInfo() -> YLDBforum_info? {
        defer {
            db.clear()
        }

        var info = YLDBforum_info(newestUserId: 0, newestUserName: "", totalUsers: 0, totalTopics: 0, totalPosts: 0)

        guard let results = db.select(statement: "select cast(sum(num_topics) as UNSIGNED) as num_topics, cast(sum(num_posts) as UNSIGNED) as num_posts from \(prefix)forums", params: []) else {
            return nil
        }

        if results.count == 1 {
            info.totalTopics = item(from: results[0]["num_topics"])
            info.totalPosts = item(from: results[0]["num_posts"])
        } else {
            return nil
        }

        db.clear()
        guard let results2 = db.select(statement: "SELECT CAST(COUNT(id)-1 as UNSIGNED) as num FROM \(prefix)users WHERE group_id!=?", params: [.uint(0)]) else {
            return nil
        }

        if results2.count == 1 {
            info.totalUsers = item(from: results2[0]["num"])
        } else {
            return nil
        }

        db.clear()
        guard let results3 = db.select(statement: "SELECT id, username FROM \(prefix)users WHERE group_id!=?  ORDER BY registered DESC LIMIT 1", params: [.uint(0)]) else {
            return nil
        }

        if results3.count == 1 {
            info.newestUserId = item(from: results3[0]["id"])
            info.newestUserName = item(from: results3[0]["username"])
        } else {
            return nil
        }

        return info
    }

    public func getUser(userID: UInt32) -> [String: Any]? {
        guard let results = db.select(statement: "select * from \(prefix)users where id=?", params: [.uint(UInt(userID))]) else {
            return nil
        }

        defer {
            db.clear()
        }

        if results.count == 1 {
            return results[0]
        }

        return [:]
    }

    public func getUser(userName: String) -> [String: Any]? {
        guard let results = db.select(statement: "select * from \(prefix)users where username=?", params: [.string(userName)]) else {
            return nil
        }

        defer {
            db.clear()
        }

        if results.count == 1 {
            return results[0]
        }

        return [:]
    }

    public func getDefaultUser(remoteAddress: String) -> [String: Any]? {
        guard let results = db.select(statement: "SELECT u.*, g.*, o.logged, o.last_post, o.last_search FROM \(prefix)users AS u INNER JOIN \(prefix)groups AS g ON u.group_id=g.g_id LEFT JOIN \(prefix)online AS o ON o.ident=? WHERE u.id=1", params: [.string(remoteAddress)]) else {
            return nil
        }

        defer {
            db.clear()
        }

        if results.count == 1 {
            return results[0]
        }
        return [:]
    }

    public func getAllUsers() -> [[String: Any]]? {
        guard let results = db.select(statement: "select * from \(prefix)users", params: []) else {
            return nil
        }

        defer {
            db.clear()
        }

        if results.count > 0 {
            return results
        }

        return []
    }

    public func getGroup(id: UInt32) -> [String: Any]? {
        guard let results = db.select(statement: "select * from \(prefix)groups where g_id=?", params: [.uint(UInt(id))]) else {
            return nil
        }

        defer {
            db.clear()
        }

        if results.count == 1 {
            return results[0]
        }
        return [:]
    }

    public func getAllGroups() -> [[String: Any]]? {
        guard let results = db.select(statement: "select * from \(prefix)groups", params: []) else {
            return nil
        }

        defer {
            db.clear()
        }

        if results.count > 0 {
            return results
        }
        return []
    }

    public func getForum(id: UInt32) -> [String: Any]? {
        guard let results = db.select(statement: "select * from \(prefix)forums where id=?", params: [.uint(UInt(id))]) else {
            return nil
        }

        defer {
            db.clear()
        }

        if results.count == 1 {
            return results[0]
        }
        return [:]
    }

    public func getAllForums() -> [[String: Any]]? {
        guard let results = db.select(statement: "select * from \(prefix)forums", params: []) else {
            return nil
        }

        defer {
            db.clear()
        }

        if results.count > 0 {
            return results
        }
        return []
    }

    public func getAllPermissions() -> [[String: Any]]? {
        guard let results = db.select(statement: "select * from \(prefix)forum_perms", params: []) else {
            return nil
        }

        defer {
            db.clear()
        }

        if results.count > 0 {
            return results
        }
        return []
    }

    public func getTopic(id: UInt32) -> [String: Any]? {
        guard let results = db.select(statement: "select * from \(prefix)topics where id=?", params: [.uint(UInt(id))]) else {
            return nil
        }

        defer {
            db.clear()
        }

        if results.count > 0 {
            return results[0]
        }
        return [:]
    }

    public func getTopics(from: [UInt32], startFrom: UInt32, limit: UInt32) -> [[String: Any]]? {
        let forumIdsPlaceHolder = from.map({
            (_) -> String in
            "?"
        }).joined(separator: ",")
        let sql = "SELECT * FROM \(prefix)topics WHERE forum_id IN (\(forumIdsPlaceHolder)) ORDER BY last_post DESC LIMIT ?, ?"

        var params: [DatabaseValue] = from.map({
            (n) -> DatabaseValue in
            .uint(UInt(n))
        })
        params.append(.uint(UInt(startFrom)))
        params.append(.uint(UInt(limit)))

        guard let results = db.select(statement: sql, params: params) else {
            return nil
        }

        defer {
            db.clear()
        }

        if results.count > 0 {
            return results
        }
        return []
    }

    public func getPosts(topicId: UInt32, startFrom: UInt32, limit: UInt32) -> [[String: Any]]? {
        guard let results = db.select(statement: "SELECT * FROM \(prefix)posts WHERE topic_id=? ORDER BY id LIMIT ?, ?",
            params: [
                .uint(UInt(topicId)),
                .uint(UInt(startFrom)),
                .uint(UInt(limit))
            ]) else {
                return nil
        }

        defer {
            db.clear()
        }

        if results.count > 0 {
            return results
        }
        return []
    }

    public func getPost(id: UInt32) -> [String: Any]? {
        guard let results = db.select(statement: "SELECT * FROM \(prefix)posts WHERE id=?", params: [.uint(UInt(id))]) else {
            return nil
        }

        defer {
            db.clear()
        }

        if results.count > 0 {
            return results[0]
        }
        return [:]
    }

    public func locatePostInTopic(topicId: UInt32, posted: UInt32) -> UInt32? {
        guard let result = db.select(statement: "SELECT COUNT(id) as loc FROM \(prefix)posts WHERE topic_id=? AND posted<?", params: [.uint(UInt(topicId)), .uint(UInt(posted))]) else {
            return nil
        }

        defer {
            db.clear()
        }

        if let row = result.first {
            if let loc = row["loc"] as? Int64 {
                return UInt32(loc)
            }
        }
        return nil
    }

    public func getTotalTopicsAndPosts() -> (topics: Int, posts: Int) {
        guard let result = db.select(statement: "SELECT SUM(num_topics) as totalTopic, SUM(num_posts) as totalPost FROM \(prefix)forums", params: []) else {
            return (topics: 0, posts: 0)
        }

        defer {
            db.clear()
        }

        if let row = result.first {
            let totalTopic = row["totalTopic"] as? String ?? "0"
            let totalPost = row["totalPost"] as? String ?? "0"
            return (topics: Int(totalTopic) ?? 0, posts: Int(totalPost) ?? 0)
        }
        return (topics: 0, posts: 0)
    }

    public func insertPost(topicId: UInt32, message: String, user: YLDBusers, remoteAddress: String, postTime: UInt32) -> UInt32? {
        guard let insertId = db.insert(statement: "INSERT INTO \(prefix)posts (poster, poster_id, poster_ip, message, hide_smilies, posted, topic_id) VALUES(?,?,?,?,?,?,?)",
            params: [
                .string(user.username),
                .uint(UInt(user.id)),
                .string(remoteAddress),
                .string(message),
                .int(0),
                .uint(UInt(postTime)),
                .uint(UInt(topicId))
            ]) else {
                return nil
        }

        defer {
            db.clear()
        }

        return UInt32(insertId)
    }

    public func deletePost(id: UInt32) -> Bool {
        let ret = db.delete(statement: "DELETE \(prefix)posts WHERE id=?", params: [
            .uint(UInt(id))
            ])

        defer {
            db.clear()
        }

        return ret
    }

    public func updateTopic(id: UInt32, lastPostId: UInt32, lastPoster: YLDBusers, lastPostTime: UInt32) -> Bool {
        let ret = db.update(statement: "UPDATE \(prefix)topics SET num_replies=num_replies+1, last_post=?, last_post_id=?, last_poster=? WHERE id=?", params: [
            .uint(UInt(lastPostTime)),
            .uint(UInt(lastPostId)),
            .string(lastPoster.username),
            .uint(UInt(id))
            ])

        defer {
            db.clear()
        }

        return ret
    }

    public func insertTopic(forumId: UInt32, subject: String, user: YLDBusers, postTime: UInt32, type:Int32, sticky: Bool) -> UInt32? {
        var isSticky: Int = 0
        if sticky {
            isSticky = 1
        }
        guard let insertId = db.insert(statement: "INSERT INTO \(prefix)topics (poster, subject, posted, last_post, last_poster, sticky, forum_id, special) VALUES(?,?,?,?,?,?,?,?)",
            params: [
                .string(user.username),
                .string(subject),
                .uint(UInt(postTime)),
                .uint(UInt(postTime)),
                .string(user.username),
                .int(isSticky),
                .uint(UInt(forumId)),
                .int(Int(type))
            ]) else {
                return nil
        }

        defer {
            db.clear()
        }

        return UInt32(insertId)
    }

    public func deleteTopic(id: UInt32) -> Bool {
        let ret = db.delete(statement: "DELETE \(prefix)topics WHERE id=?", params: [
            .uint(UInt(id))
            ])

        defer {
            db.clear()
        }

        return ret
    }
}
