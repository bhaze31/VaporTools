import Foundation

enum PathConstants: String {
    case BasePath = "Source"
    case ApplicationPath = "Source/App"

    case ModelPath = "Source/App/Models"

    case ProtocolPath = "Source/App/Protocols"
    case APIProtocolPath = "Source/App/Protocols/APIProtocols"
    case WebProtocolPath = "Source/App/Protocols/WebProtocols"
}

final class FileGenerator {
    
    static func fileExists(fileName: String, path: PathConstants) -> Bool {
        return FileManager.default.fileExists(atPath: "\(path.rawValue)/\(fileName)")
    }

    static func createFileWithContents(_ contents: String, fileName: String, path _path: PathConstants) {
        createFolderUnlessExists(_path)
        let path = _path.rawValue

        if FileManager.default.fileExists(atPath: "\(path)/\(fileName)") {
            print("File already exists")
        } else {
            print("Creating file at path: \(path)/\(fileName)")
            FileManager.default.createFile(atPath: "\(path)/\(fileName)", contents: contents.data(using: .utf8), attributes: [:])
        }
    }
    
    static func createFolderUnlessExists(_ _folderName: PathConstants) {
        let folderName = _folderName.rawValue

        var directory: ObjCBool = true
        if !FileManager.default.fileExists(atPath: folderName, isDirectory: &directory) {
            do {
                let folder = URL(fileURLWithPath: folderName, isDirectory: true)
                try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: [:])
            } catch let e {
                print(e)
                print("Error creating directory")
            }
        }
    }
}
