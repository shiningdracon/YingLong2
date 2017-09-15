import Foundation

public enum MemoryStorageError: Error {
    case initFailed(String)
}

public class MemoryStorage {
    var storage: [String: Any] = [:]
}
