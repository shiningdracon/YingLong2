import Foundation


enum DataError: Error {
    case dbError
}

func item<T: Any>(from: Any?) -> T {
    guard let ret = from as? T else {
        fatalError("invalid data type")
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

}
