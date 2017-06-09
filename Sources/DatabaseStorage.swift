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
}
