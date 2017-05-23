import Foundation

public enum DatabaseValue {
    case string(String)
    case int(Int)
    case uint(UInt)
    case double(Double)
    case null
}

protocol DatabaseProtocol {
    func select(statement: String, params: [DatabaseValue]) -> [[String: Any]]?
    func insert(statement: String, params: [DatabaseValue]) -> UInt?
    func update(statement: String, params: [DatabaseValue]) -> Bool
    func delete(statement: String, params: [DatabaseValue]) -> Bool
    func clear()
    func transactionStart()
    func transactionCommit()
    func transactionRollback()
}

public final class DatabaseStorage {
    let db: DatabaseProtocol
    let prefix: String

    init(database: DatabaseProtocol, prefix: String) {
        self.db = database
        self.prefix = prefix
    }

    public func transactionStart() {
        self.db.transactionStart()
    }

    public func transactionCommit() {
        self.db.transactionCommit()
    }

    public func transactionRollback() {
        self.db.transactionRollback()
    }

    public func getComic(id: UInt32) -> [String: Any]? {
        guard let results = db.select(statement: "select * from \(prefix)comics where id=?", params: [.uint(UInt(id))]) else {
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

    public func getComicList(offset: UInt32, limit: UInt32) -> [[String: Any]]? {
        guard let results = db.select(statement: "select * from \(prefix)comics order by id limit ?,?",
            params: [
                .uint(UInt(offset)),
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

    public func addComic(title: String, author: String, poster: String, pageCount: UInt32, description: String) -> UInt32? {
        guard let insertId = db.insert(statement: "insert into \(prefix)comics (title, author, poster, description, page_count) values(?,?,?,?,?)",
            params: [
                .string(title),
                .string(author),
                .string(poster),
                .string(description),
                .uint(UInt(pageCount))
            ]) else {
                return nil
        }

        defer {
            db.clear()
        }

        return UInt32(insertId)
    }

    public func updateComic(id: UInt32, title: String, author: String, pageCount: UInt32, description: String) -> Bool {
        let ret = db.update(statement: "update \(prefix)comics set title=?, author=?, page_count=?, description=? where id=?",
            params: [
                .string(title),
                .string(author),
                .uint(UInt(pageCount)),
                .string(description),
                .uint(UInt(id))
            ])

        defer {
            db.clear()
        }

        return ret
    }

    public func getPage(comicId: UInt32, pageIndex: UInt32) -> [String: Any]? {
        guard let results = db.select(statement: "select * from \(prefix)pages where comic_id=? and `index`=?", params: [.uint(UInt(comicId)), .uint(UInt(pageIndex))]) else {
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

    public func updatePage(comicId: UInt32, pageIndex: UInt32, title: String, description: String, content: String) -> Bool {
        let ret = db.update(statement: "update \(prefix)pages set title=?, description=?, content=? where comic_id=? and `index`=?",
            params: [
                .string(title),
                .string(description),
                .string(content),
                .uint(UInt(comicId)),
                .uint(UInt(pageIndex))
            ])

        defer {
            db.clear()
        }

        return ret
    }

    public func addPage(comicId: UInt32, pageIndex: UInt32, title: String, poster: String, description: String, content: String) -> UInt32? {
        guard let insertId = db.insert(statement: "insert into \(prefix)pages (comic_id, `index`, title, poster, description, content) values(?,?,?,?,?,?)",
            params: [
                .uint(UInt(comicId)),
                .uint(UInt(pageIndex)),
                .string(title),
                .string(poster),
                .string(description),
                .string(content)
            ]) else {
                return nil
        }

        defer {
            db.clear()
        }

        return UInt32(insertId)
    }

    public func getPageListOfComic(id: UInt32) -> [[String: Any]]? {
        guard let results = db.select(statement: "select * from \(prefix)pages where comic_id=?", params: [.uint(UInt(id))]) else {
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

    public func getCommentListOfPage(id: UInt32) -> [[String: Any]]? {
        guard let results = db.select(statement: "select * from \(prefix)comments where page_id=?", params: [.uint(UInt(id))]) else {
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

    public func addFile(pageId: UInt32, filename: String, localname: String, mimetype: String, size: UInt32) -> Bool {
        guard let _ = db.insert(statement: "insert into \(prefix)files (page_id, filename, localname, mimetype, size) values(?,?,?,?,?)",
            params: [
                .uint(UInt(pageId)),
                .string(filename),
                .string(localname),
                .string(mimetype),
                .uint(UInt(size))
            ]) else {
                return false
        }

        defer {
            db.clear()
        }

        return true
    }
}
