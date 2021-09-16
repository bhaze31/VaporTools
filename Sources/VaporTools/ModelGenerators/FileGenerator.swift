import Foundation

#if DEBUG
enum PathConstants: String {
    case BasePath = "Source"
    case ApplicationPath = "Source/App"

    case ModelPath = "Source/App/Models"

    case ResourcePath = "Source/App/Resources"

    case MigrationPath = "Source/App/Migrations"

    case ProtocolPath = "Source/App/Protocols"
    case APIProtocolPath = "Source/App/Protocols/APIProtocols"
    case WebProtocolPath = "Source/App/Protocols/WebProtocols"
}
#else
enum PathConstants: String {
    case BasePath = "Sources"
    case ApplicationPath = "Sources/App"
    
    case ModelPath = "Sources/App/Models"
    
    case ResourcePath = "Sources/App/Resources"
    
    case MigrationPath = "Sources/App/Migrations"
    
    case ProtocolPath = "Sources/App/Protocols"
    case APIProtocolPath = "Sources/App/Protocols/APIProtocols"
    case WebProtocolPath = "Sources/App/Protocols/WebProtocols"
}
#endif

final class AppFiles {
  var appRouter: String {
    return """
import Vapor

final class AppRouter {
  var app: Application

  init(_ application: Application) {
    self.app = application
  }

  func loadResources() throws {

  }

  func loadRoutes() throws {

  }
}
"""
  }
}
final class FileGenerator {

    static func fileExists(fileName: String, path: PathConstants) -> Bool {
        return FileManager.default.fileExists(atPath: "\(path.rawValue)/\(fileName)")
    }

    static func createFileWithContents(_ contents: String, fileName: String, path _path: PathConstants, displayIfConflicting: Bool = false) {
        createFolderUnlessExists(_path)
        let path = _path.rawValue

        if FileManager.default.fileExists(atPath: "\(path)/\(fileName)") {
            print("File \(fileName) already exists")

            if displayIfConflicting {
                print("\nWould-be contents of \(fileName)\n")
                print(contents)
                print("\n\n")
            }
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
