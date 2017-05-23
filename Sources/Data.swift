import Foundation

public struct DataComic {
    var id: UInt32
    var title: String
    var author: String
    var poster: String
    var pageCount: UInt32
    var description: String

    init(_ args: [String: Any]) throws {
        id = try item(from: args["id"])
        title = try item(from: args["title"])
        author = try item(from: args["author"])
        poster = try item(from: args["poster"])
        pageCount = try item(from: args["page_count"])
        description = try item(from: args["description"])
    }
}

public struct DataPage {
    var id: UInt32
    var comicId: UInt32
    var index: UInt32
    var title: String
    var poster: String
    var description: String
    var content: String

    init(_ args: [String: Any]) throws {
        id = try item(from: args["id"])
        comicId = try item(from: args["comic_id"])
        index = try item(from: args["index"])
        title = try item(from: args["title"])
        poster = try item(from: args["poster"])
        description = try item(from: args["description"])
        content = try item(from: args["content"])
    }
}

public struct DataComment {
    var id: UInt32
    var pageId: UInt32
    var poster: String
    var content: String

    init(_ args: [String: Any]) throws {
        id = try item(from: args["id"])
        pageId = try item(from: args["page_id"])
        poster = try item(from: args["poster"])
        content = try item(from: args["content"])
    }
}

public struct DataFile {
    var pageId: UInt32
    var filename: String
    var localname: String
    var mimetype: String
    var size: UInt32

    init(_ args: [String: Any]) throws {
        pageId = try item(from: args["page_id"])
        filename = try item(from: args["filename"])
        localname = try item(from: args["localname"])
        mimetype = try item(from: args["mimetype"])
        size = try item(from: args["size"])
    }
}

enum DataError: Error {
    case invalidValue
    case dbError
}

func item<T: Any>(from: Any?) throws -> T {
    guard let ret = from as? T else {
        throw DataError.invalidValue
    }
    return ret
}

public final class DataManager {
    let memoryStorage: MemoryStorage
    let dbStorage: DatabaseStorage

    init(dbStorage: DatabaseStorage, memoryStorage: MemoryStorage) {
        self.dbStorage = dbStorage
        self.memoryStorage = memoryStorage
    }

    public func transactionStart() {
        dbStorage.transactionStart()
    }

    public func transactionCommit() {
        dbStorage.transactionCommit()
    }

    public func transactionRollback() {
        dbStorage.transactionRollback()
    }

    public func getComic(id: UInt32) throws -> DataComic? {
        guard let args = dbStorage.getComic(id: id) else {
            throw DataError.dbError
        }
        if args.count == 0 {
            return nil
        }
        return try DataComic(args)
    }

    public func getComicList(offset: UInt32, limit: UInt32) throws -> [DataComic]? {
        guard let args = dbStorage.getComicList(offset: offset, limit: limit) else {
            throw DataError.dbError
        }
        if args.count == 0 {
            return nil
        }
        var comics: [DataComic] = []
        for row in args {
            comics.append(try DataComic(row))
        }
        return comics
    }

    public func addComic(title: String, author: String, poster: String, description: String) throws -> UInt32 {
        guard let insertId = dbStorage.addComic(title: title, author: author, poster: poster, pageCount: 0, description: description) else {
            throw DataError.dbError
        }
        return insertId
    }

    public func updateComic(id: UInt32, title: String, author: String, pageCount: UInt32, description: String) -> Bool {
        return dbStorage.updateComic(id: id, title: title, author: author, pageCount: pageCount, description: description)
    }

    public func getPage(comicId: UInt32, pageIndex: UInt32) throws -> DataPage? {
        guard let args = dbStorage.getPage(comicId: comicId, pageIndex: pageIndex) else {
            throw DataError.dbError
        }
        if args.count == 0 {
            return nil
        }
        return try DataPage(args)
    }

    public func updatePage(comicId: UInt32, pageIndex: UInt32, title: String, description: String, content: String) -> Bool {
        return dbStorage.updatePage(comicId: comicId, pageIndex: pageIndex, title: title, description: description, content: content)
    }

    public func addPage(comicId: UInt32, pageIndex: UInt32, title: String, poster: String, description: String, content: String) throws -> UInt32 {
        guard let insertId = dbStorage.addPage(comicId: comicId, pageIndex: pageIndex, title: title, poster: poster, description: description, content: content) else {
            throw DataError.dbError
        }
        return insertId
    }

    public func getPageListOfComic(id: UInt32) throws -> [DataPage]? {
        guard let args = dbStorage.getPageListOfComic(id: id) else {
            throw DataError.dbError
        }
        if args.count == 0 {
            return nil
        }
        var pages: [DataPage] = []
        for row in args {
            pages.append(try DataPage(row))
        }
        return pages
    }

    public func getCommentListOfPage(id: UInt32) throws -> [DataComment]? {
        guard let args = dbStorage.getCommentListOfPage(id: id) else {
            throw DataError.dbError
        }
        if args.count == 0 {
            return nil
        }
        var comments: [DataComment] = []
        for row in args {
            comments.append(try DataComment(row))
        }
        return comments
    }

    public func addFile(pageId: UInt32, filename: String, localname: String, mimetype: String, size: UInt32) throws {
        guard dbStorage.addFile(pageId: pageId, filename: filename, localname: localname, mimetype: mimetype, size: size) else {
            throw DataError.dbError
        }
    }
}
