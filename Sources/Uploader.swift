import Foundation
import SwiftGD

class FileUploader {
    let sizeLimit: Int
    let uploadDir: String

    init(sizeLimit: Int, uploadDir: String) {
        self.sizeLimit = sizeLimit
        self.uploadDir = uploadDir
    }

    func uploadByFile(path: String, contentType: String, fileName: String, fileSize: Int) {

    }

    func uploadByBase64(base64: String, contentType: String) {

    }

    func uploadByRemote(url: String) {

    }

    private func validateImage(path: String) -> Bool {
        if let image = Image(url: URL(fileURLWithPath: path)) {
            return true
        } else {
            return false
        }
    }
}

extension String {
    var filePathSeparator: UnicodeScalar {
        return UnicodeScalar(47)
    }

    var fileExtensionSeparator: UnicodeScalar {
        return UnicodeScalar(46)
    }

    private func lastPathSeparator(in unis: String.CharacterView) -> String.CharacterView.Index {
        let startIndex = unis.startIndex
        var endIndex = unis.endIndex
        while endIndex != startIndex {
            if unis[unis.index(before: endIndex)] != Character(filePathSeparator) {
                break
            }
            endIndex = unis.index(before: endIndex)
        }
        return endIndex
    }

    private func lastExtensionSeparator(in unis: String.CharacterView, endIndex: String.CharacterView.Index) -> String.CharacterView.Index {
        var endIndex = endIndex
        while endIndex != startIndex {
            endIndex = unis.index(before: endIndex)
            if unis[endIndex] == Character(fileExtensionSeparator) {
                break
            }
        }
        return endIndex
    }

    public var filePathExtension: String {
        let unis = self.characters
        let startIndex = unis.startIndex
        var endIndex = lastPathSeparator(in: unis)
        let noTrailsIndex = endIndex
        endIndex = lastExtensionSeparator(in: unis, endIndex: endIndex)
        guard endIndex != startIndex else {
            return ""
        }
        return self[unis.index(after: endIndex)..<noTrailsIndex]
    }
}