import Foundation

final class FileHandler {
    static func fileExists(fileName: String, path: PathConstants) -> Bool {
        return FileManager.default.fileExists(atPath: "\(path.rawValue)/\(fileName)")
    }
    
    static func createViewFileWithContents(_ contents: String, model: String, fileName: String, displayIfConflicting: Bool = false) {
        var path = PathConstants.ViewsPath.rawValue
        path += "/\(model.capitalized)/\(fileName).swift"
        
        if FileManager.default.fileExists(atPath: path) {
            print("File \(fileName) already exists")
            
            if displayIfConflicting {
                print("\nWould-be contents of \(fileName)")
                print(contents)
                print("\n\n")
            }
            
            return
        }
        
        print("Creating file at path: \(path)/\(fileName)")
        
        FileManager.default.createFile(
            atPath: path,
            contents: contents.data(using: .utf8),
            attributes: [:]
        )
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
            
            return
        }

        print("Creating file at path: \(path)/\(fileName)")

        FileManager.default.createFile(
            atPath: "\(path)/\(fileName)",
            contents: contents.data(using: .utf8),
            attributes: [:]
        )
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
                        
                        fileData.append("\t@Field(key: FieldKeys.\(fieldData[0])) var \(fieldData[0]): \(fieldData[1].capitalized)\(optional ? "?" : "")")
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
