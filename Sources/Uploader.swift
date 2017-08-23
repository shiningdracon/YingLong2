import Foundation
import SwiftGD


class ImageUploader {
    public enum ImageUploadError: Error {
        case IOError(String)
        case TypeError
        case ValidationError
    }

    struct ImageOptions {
        let uploadDir: String
        let newName: String
        let maxWidth: Int
        let maxHeight: Int
        let quality: Int
        let rotateByExif: Bool
    }

    let imageVersions: Array<ImageOptions>

    init(imageVersions: Array<ImageOptions>) {
        self.imageVersions = imageVersions
    }

    // return: new file path
    func uploadByFile(path: String, contentType: String, fileName: String) throws {
        var fileExtension: String
        if contentType == "image/jpeg" {
            fileExtension = "jpeg"
        } else if contentType == "image/png" {
            fileExtension = "png"
        } else if contentType == "" {
            fileExtension = fileName.filePathExtension
        } else {
            fileExtension = ""
        }
        guard fileExtension == "png" || fileExtension == "jpg" || fileExtension == "jpeg" else {
            throw ImageUploadError.TypeError
        }

        if let image = Image(url: URL(fileURLWithPath: path)) {
            try reCreateImage(image: image, ext: fileExtension)
        } else {
            throw ImageUploadError.ValidationError
        }
    }

    func uploadByBase64(base64: String, contentType: String) {

    }

    func uploadByRemote(url: String) {

    }

    private func reCreateImage(image: Image, ext: String) throws {
        for option in imageVersions {
            guard image.write(to: URL(fileURLWithPath: option.uploadDir + "/" + option.newName + "." + ext), quality: option.quality) else {
                throw ImageUploadError.IOError("Write file failed")
            }
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
