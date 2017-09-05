import Foundation

extension MemoryStorage {
    func getConfigs() -> [String: String] {
        return storage["configs"] as! [String: String]
    }

    func getUsers() -> [UInt32: YLDBusers] {
        return storage["users"] as! [UInt32: YLDBusers]
    }

    func getForums() -> [UInt32: YLDBforums] {
        return storage["forums"] as! [UInt32: YLDBforums]
    }

    func getGroups() -> [UInt32: YLDBgroups] {
        return storage["groups"] as! [UInt32: YLDBgroups]
    }

    func getPermissions() -> [YLDBforum_perms] {
        return storage["permissions"] as! [YLDBforum_perms]
    }

    func getSiteInfo() -> YLDBsite_info {
        return storage["site info"] as! YLDBsite_info
    }

    func getNewestTopics() -> [YLDBtopics] {
        return storage["newest topics"] as! [YLDBtopics]
    }

    func loadConfigs(_ forumDb: DatabaseStorage) throws {
        guard let configs: [String: String] = forumDb.getAllConfigs() else {
            throw MemoryStorageError.initFailed
        }
        self.storage["configs"] = configs
    }

    func loadUsers(_ forumDb: DatabaseStorage) throws {
        guard let _users = forumDb.getAllUsers() else {
            throw MemoryStorageError.initFailed
        }
        var users: [UInt32: YLDBusers] = [:]
        for row in _users {
            let oneuser = YLDBusers(row)
            users[oneuser.id] = oneuser
        }
        self.storage["users"] = users
    }

    func loadForums(_ forumDb: DatabaseStorage) throws {
        guard let _forums = forumDb.getAllForums() else {
            throw MemoryStorageError.initFailed
        }
        var forums: [UInt32: YLDBforums]  = [:]
        for row in _forums {
            let oneforum = YLDBforums(row)
            forums[oneforum.id] = oneforum
        }
        self.storage["forums"] = forums
    }

    func loadGroups(_ forumDb: DatabaseStorage) throws {
        guard let _groups = forumDb.getAllGroups() else {
            throw MemoryStorageError.initFailed
        }
        var groups: [UInt32: YLDBgroups] = [:]
        for row in _groups {
            let onegroup = YLDBgroups(row)
            groups[onegroup.g_id] = onegroup
        }
        self.storage["groups"] = groups
    }

    func loadPermissions(_ forumDb: DatabaseStorage) throws {
        guard let _permissions = forumDb.getAllPermissions() else {
            throw MemoryStorageError.initFailed
        }
        var permissions: [YLDBforum_perms] = []
        for row in _permissions {
            let oneperm = YLDBforum_perms(row)
            permissions.append(oneperm)
        }
        self.storage["permissions"] = permissions
    }

    func loadInfo(_ forumDb: DatabaseStorage) throws {
        guard let _info = forumDb.getForumInfo() else {
            throw MemoryStorageError.initFailed
        }
        let info = YLDBsite_info(_info)
        self.storage["site info"] = info
    }

    func loadNewestTopics(_ forumDb: DatabaseStorage) throws {
        // TODO: range
        guard let _newestTopics = forumDb.getTopics(forumIds: [UInt32](1...15), startFrom: 0, limit: 5) else {
            throw MemoryStorageError.initFailed
        }
        var newestTopics: [YLDBtopics] = []
        for row in _newestTopics {
            let t = YLDBtopics(row)
            newestTopics.append(t)
        }
        self.storage["newest topics"] = newestTopics
    }

    func initMemoryStorageForum(_ forumDb: DatabaseStorage) throws {
        try loadConfigs(forumDb)
        try loadUsers(forumDb)
        try loadForums(forumDb)
        try loadGroups(forumDb)
        try loadPermissions(forumDb)
        try loadInfo(forumDb)
        try loadNewestTopics(forumDb)
    }
}
