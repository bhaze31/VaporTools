import Foundation

final class FileHandler {
    static func createViewFileWithContents(_ contents: String, model: String, fileName: String, displayIfConflicting: Bool = false) {
        let viewsPath = PathGenerator.load(path: .Views)
        createFolderUnlessExists(viewsPath)
        createFolderUnlessExists(viewsPath + "/\(model.toModelCase())")

        var path = viewsPath

        path += "/\(model.toModelCase())/\(fileName).leaf"

        if FileManager.default.fileExists(atPath: path) {

            if displayIfConflicting {
                // TODO: log info
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

    static func createFileWithContents(_ contents: String, fileName: String, path: String, displayIfConflicting: Bool = false, overwriteFile: Bool = false) {
        createFolderUnlessExists(path)

        if FileManager.default.fileExists(atPath: "\(path)/\(fileName)") && !overwriteFile {
            PrettyLogger.warn("File \(fileName) already exists")

            if displayIfConflicting {
                print("\nWould-be contents of \(fileName)\n")
                print(contents)
                print("\n\n")
            }

            return
        }

        PrettyLogger.info("Creating file at path: \(path == "./" ? "." : path)/\(fileName)")

        FileManager.default.createFile(
            atPath: "\(path)/\(fileName)",
            contents: contents.data(using: .utf8),
            attributes: [:]
        )
    }

    static func fetchDefaultFile(_ file: String) -> String {
        guard let url = Bundle.module.url(forResource: "DefaultFiles/\(file)", withExtension: ".txt"), let contents = try? String(contentsOfFile: url.path) else {
            PrettyLogger.error("Cannot load contents of file \(file), this is a problem with Simmer, please report it at: https://github.com/bhaze31/simmer")
            exit(0)
        }

        return contents
    }

    static func changeFileWithContents(_ contents: String, fileName: String, path: String) {
        createFolderUnlessExists(path)


        print("Updating file at path: \(path)/\(fileName)")

        FileManager.default.createFile(
            atPath: "\(path)/\(fileName)",
            contents: contents.data(using: .utf8),
            attributes: [:]
        )
    }

    static func createFolderUnlessExists(_ folderName: String, isFatal: Bool = false) {
        // We are just generating a file in the current directory, this should never be called
        if folderName == "./" {
            PrettyLogger.info("Attempting to add a folder that is just the current directory, bailing.")
            return
        }

        PrettyLogger.info("Attempting to generate directory \(folderName)")

        var directory: ObjCBool = true
        if !FileManager.default.fileExists(atPath: folderName, isDirectory: &directory) {
            do {
                PrettyLogger.generate("Folder does not exist, generating")
                let folder = URL(fileURLWithPath: folderName, isDirectory: true)
                try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: [:])
            } catch {
                if isFatal {
                    fatalError("Error creating directory \(folderName)")
                } else {
                    print("Error creating directory")
                }
            }
        } else {
            PrettyLogger.warn("Error generating folder, folder '\(folderName)' exists.")
            if isFatal {
                PrettyLogger.error("Cannot continue without generating folder, exiting.")
                exit(0)
            }
        }
    }

    static func addRouteCollectionToRouter(controllerName: String) {
        let path = PathGenerator.load(path: .App, name: "MISSING_NAME")

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

    static func addFieldKeyToFile(folder: String, fileName: String, fields: [String]) {
        let path = "\(folder)/\(fileName).swift"

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

            FileManager.default.createFile(atPath: "\(folder)/\(fileName).swift", contents: fileData.joined(separator: "\n").data(using: .utf8), attributes: [:])
        }
    }

    static func removeFieldKeyFromFile(folder folderName: String, fileName: String, fields: [String]) {
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

    static func cleanup(app name: String) throws {
        let folder = URL(fileURLWithPath: name, isDirectory: true)
        try FileManager.default.removeItem(at: folder)
    }
}
