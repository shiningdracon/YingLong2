import Foundation

public enum MemoryStorageError: Error {
    case initFailed
}

public class MemoryStorage {
    var storage: [String: Any] = [:]
}
