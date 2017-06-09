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

    func initMemoryStorageForum(_ forumdb: DatabaseStorage) throws {
        guard let configs: [String: String] = forumdb.getAllConfigs() else {
            throw MemoryStorageError.initFailed
        }

        guard let _users = forumdb.getAllUsers() else {
            throw MemoryStorageError.initFailed
        }
        var users: [UInt32: YLDBusers] = [:]
        for row in _users {
            let oneuser = YLDBusers(row)
            users[oneuser.id] = oneuser
        }

        guard let _forums = forumdb.getAllForums() else {
            throw MemoryStorageError.initFailed
        }
        var forums: [UInt32: YLDBforums]  = [:]
        for row in _forums {
            let oneforum = YLDBforums(row)
            forums[oneforum.id] = oneforum
        }

        guard let _groups = forumdb.getAllGroups() else {
            throw MemoryStorageError.initFailed
        }
        var groups: [UInt32: YLDBgroups] = [:]
        for row in _groups {
            let onegroup = YLDBgroups(row)
            groups[onegroup.g_id] = onegroup
        }

        guard let _permissions = forumdb.getAllPermissions() else {
            throw MemoryStorageError.initFailed
        }
        var permissions: [YLDBforum_perms] = []
        for row in _permissions {
            let oneperm = YLDBforum_perms(row)
            permissions.append(oneperm)
        }

        self.storage["configs"] = configs
        self.storage["users"] = users
        self.storage["forums"] = forums
        self.storage["groups"] = groups
        self.storage["permissions"] = permissions
    }
}
