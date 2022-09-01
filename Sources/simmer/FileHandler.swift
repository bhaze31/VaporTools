import Foundation

final class FileHandler {
    static func fileExists(fileName: String, path: PathConstants) -> Bool {
        return FileManager.default.fileExists(atPath: "\(path.rawValue)/\(fileName)")
    }
    
    static func createViewFileWithContents(_ contents: String, model: String, fileName: String, displayIfConflicting: Bool = false) {
        createFolderUnlessExists(PathConstants.ViewsPath.rawValue)
        createFolderUnlessExists(PathConstants.ViewsPath.rawValue + "/\(model.toModelCase())")

        var path = PathConstants.ViewsPath.rawValue

        path += "/\(model.toModelCase())/\(fileName).leaf"

        if FileManager.default.fileExists(atPath: path) {
            print("File \(fileName) already exists")

            if displayIfConflicting {
                print("\nWould-be contents of \(fileName)")
                print(contents)
                print("\n\n")
            }

            return
        }
        
        print("Creating file at path: \(path)")

        FileManager.default.createFile(
            atPath: path,
            contents: contents.data(using: .utf8),
            attributes: [:]
        )
    }

    static func createMainView() {
        createFolderUnlessExists(PathConstants.ViewsPath.rawValue)

        let path = PathConstants.ViewsPath.rawValue

        if !FileHandler.fileExists(fileName: "main.leaf", path: PathConstants.ViewsPath) {
            let mainView = ViewsGenerator.generateMainView()
            
            FileManager.default.createFile(
                atPath: path + "/main.leaf",
                contents: mainView.data(using: .utf8),
                attributes: [:]
            )
        }
    }

    static func createFileWithContents(_ contents: String, fileName: String, path _path: PathConstants, displayIfConflicting: Bool = false) {
        createFolderUnlessExists(_path.rawValue)

        let path = _path.rawValue

        if FileManager.default.fileExists(atPath: "\(path)/\(fileName)") {
            print("File \(fileName) already exists")

            if displayIfConflicting {
                print("\nWould-be contents of \(fileName)\n")
                print(contents)
                print("\n\n")
            }
            
            return
        }

        print("Creating file at path: \(path)/\(fileName)")

        FileManager.default.createFile(
            atPath: "\(path)/\(fileName)",
            contents: contents.data(using: .utf8),
            attributes: [:]
        )
    }
    
    static func changeFileWithContents(_ contents: String, fileName: String, path _path: PathConstants) {
        createFolderUnlessExists(_path.rawValue)
    
        let path = _path.rawValue
    
        print("Updating file at path: \(path)/\(fileName)")
    
        FileManager.default.createFile(
            atPath: "\(path)/\(fileName)",
            contents: contents.data(using: .utf8),
            attributes: [:]
        )
    }

    static func createFolderUnlessExists(_ folderName: String, isFatal: Bool = false) {
        PrettyLogger.info("Attempting to generate directory \(folderName)")
        var directory: ObjCBool = true
        if !FileManager.default.fileExists(atPath: folderName, isDirectory: &directory) {
            do {
                PrettyLogger.generate("Folder does not exist, generating")
                let folder = URL(fileURLWithPath: folderName, isDirectory: true)
                try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: [:])
            } catch let e {
                if isFatal {
                    fatalError("Error creating directory \(folderName)")
                } else {
                    print("Error creating directory")
                }
                
            }
        } else {
            PrettyLogger.error("Error generating folder, folder '\(folderName)' exists.")
            if isFatal {
                PrettyLogger.error("Cannot continue without generating folder, exiting.")
                exit(0)
            }
        }
    }
    
    static func addRouteCollectionToRouter(controllerName: String) {
        let path = "\(PathConstants.ApplicationPath.rawValue)/routes.swift"

        if let data = FileManager.default.contents(atPath: path), let file = String(data: data, encoding: .utf8) {
            var fileData = [String]()

            let rows = file.components(separatedBy: "\n")

            var collectionsHit = false

            for (index, row) in rows.enumerated() {
                if row.contains("try app.register(") {
                    collectionsHit = true
                    fileData.append(row)
                    continue
                }

                if row.contains("}") && collectionsHit {
                    fileData.append("    try app.register(\(controllerName))")
                    collectionsHit = false
                } else if row.contains("}") && (rows.count - index) < 5 {
                    fileData.append("    try app.register(\(controllerName))")
                    collectionsHit = false
                }

                fileData.append(row)
            }

            FileManager.default.createFile(atPath: path, contents: fileData.joined(separator: "\n").data(using: .utf8), attributes: [:])
        }
    }
    
    static func addFieldKeyToFile(folder _folderName: PathConstants, fileName: String, fields: [String]) {
        let folderName = _folderName.rawValue
        let path = "\(folderName)/\(fileName).swift"
        
        if let data = FileManager.default.contents(atPath: path), let file = String(data: data, encoding: .utf8) {
            var fileData = [String]()
            let rows = file.components(separatedBy: "\n")
            
            for row in rows {
                if row.contains("createdAt: FieldKey") {
                    for field in fields {
                        // TODO: Camel case things
                        let fieldName = field.components(separatedBy: ":").first!
                        fileData.append("\t\t\tstatic var \(fieldName): FieldKey { \(fieldName) }")
                    }
                }
                
                if row.contains("@Timestamp(key: FieldKeys.createdAt") {
                    for field in fields {
                        let fieldData = field.components(separatedBy: ":")
                        if fieldData.count <= 1 {
                            continue
                        }

                        var optional = false
                        if fieldData.count == 3 && ["o", "optional"].contains(fieldData[2]) {
                            optional = true
                        }
                        
                        fileData.append("\t@Field(key: FieldKeys.\(fieldData[0])) var \(fieldData[0]): \(fieldData[1].toModelCase())\(optional ? "?" : "")")
                    }
                }
                
                fileData.append(row)
            }
            
            FileManager.default.createFile(atPath: "\(folderName)/\(fileName).swift", contents: fileData.joined(separator: "\n").data(using: .utf8), attributes: [:])
        }
    }
    
    static func removeFieldKeyFromFile(folder _folderName: PathConstants, fileName: String, fields: [String]) {
        let folderName = _folderName.rawValue
        let path = "\(folderName)/\(fileName).swift"
        
        if let data = FileManager.default.contents(atPath: path), let file = String(data: data, encoding: .utf8) {
            var fileData = [String]()
            let rows = file.components(separatedBy: "\n")

            for row in rows {
                var rowValid = true
                for field in fields {
                    if row.contains("FieldKeys.\(field)") {
                        rowValid = false
                    }
                }
                
                if rowValid {
                    fileData.append(row)
                }
            }
            
            FileManager.default.createFile(atPath: "\(folderName)/\(fileName).swift", contents: fileData.joined(separator: "\n").data(using: .utf8), attributes: [:])
        }
    }
}
