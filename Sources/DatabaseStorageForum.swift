import Foundation

extension DatabaseStorage {
    public func getAllConfigs() -> [String: String]? {
        guard let results = db.select(statement: "select * from \(prefix)config", params: []) else {
            return nil
        }

        defer {
            db.clear()
        }

        var configs = [String: String]()
        if results.count > 0 {
            for row in results {
                if let value: String = item(from: row["conf_value"]) {
                    configs[item(from: row["conf_name"])] = value
                } else {
                    configs[item(from: row["conf_name"])] = ""
                }
            }
            return configs
        }
        return configs
    }

    public func getForumInfo() -> [String: Any]? {
        defer {
            db.clear()
        }

        var info: [String: Any] = [:]

        guard let results = db.select(statement: "select cast(sum(num_topics) as UNSIGNED) as total_topics, cast(sum(num_posts) as UNSIGNED) as total_posts from \(prefix)forums", params: []) else {
            return nil
        }

        if results.count == 1 {
            info.update(other: results[0])
            if info["total_topics"] as? UInt64 == nil {
                info["total_topics"] = UInt64(0)
            }
            if info["total_posts"] as? UInt64 == nil {
                info["total_posts"] = UInt64(0)
            }
        } else {
            return nil
        }

        db.clear()
        guard let results2 = db.select(statement: "SELECT CAST(COUNT(id)-1 as UNSIGNED) as total_users FROM \(prefix)users WHERE group_id!=?", params: [.uint(0)]) else {
            return nil
        }

        if results2.count == 1 {
            info.update(other: results2[0])
            if info["total_users"] as? UInt64 == nil {
                info["total_users"] = UInt64(0)
            }
        } else {
            return nil
        }

        db.clear()
        guard let results3 = db.select(statement: "SELECT id as user_id, username FROM \(prefix)users WHERE group_id!=?  ORDER BY registered DESC LIMIT 1", params: [.uint(0)]) else {
            return nil
        }

        if results3.count == 1 {
            info.update(other: results3[0])
        } else {
            info["username"] = "N/A"
            info["user_id"] = UInt32(0)
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

    public func getTopics(forumIds: [UInt32], startFrom: UInt32, limit: UInt32) -> [[String: Any]]? {
        let forumIdsPlaceHolder = forumIds.map({
            (_) -> String in
            "?"
        }).joined(separator: ",")
        let sql = "SELECT * FROM \(prefix)topics WHERE forum_id IN (\(forumIdsPlaceHolder)) ORDER BY last_post DESC LIMIT ?, ?"

        var params: [DatabaseValue] = forumIds.map({
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

    public func getDraconity(userId: UInt32) -> [String: Any]? {
        guard let results = db.select(statement: "SELECT * FROM \(prefix)otherforms WHERE user_id=?", params: [.uint(UInt(userId))]) else {
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

    public func insertUpload(fileName: String, localName: String, mimeType: String, size: UInt32, hash: String, userId: UInt32) -> UInt32? {
        guard let insertId = db.insert(statement: "insert into \(prefix)uploads (file_name, local_name, size, hash, mime_type, user_id) values(?,?,?,?,?,?)",
            params: [
                .string(fileName),
                .string(localName),
                .uint(UInt(size)),
                .string(hash),
                .string(mimeType),
                .uint(UInt(userId))
            ]) else {
                return nil
        }

        defer {
            db.clear()
        }

        return UInt32(insertId);
    }
}
