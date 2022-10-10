// TODO: This file is unwieldy, move items to better folders
import Foundation

func getTimestamp() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "YYYYMMddHHmmssSSS"
    return formatter.string(from: Date())
}

let validTypes = ["string", "int", "double", "bool", "dict", "date", "any", "reference"]

struct Field {
    var name: String
    var type: String
    var isOptional: Bool = false
    var isArray: Bool = false
    var isReference: Bool = false
    
    // For dictionary items
    var keyType: String?
    var valueType: String?
    
    init(field: String) {
        var split = field.components(separatedBy: ":")
        
        if split.count != 2 && split.count != 3 {
            // By defualt, we set the field to be a string if we only get a name
            split = [split[0], "string"]
        }
        
        isOptional = split.count == 3 && ["optional", "o", "true"].contains(split[2])
        
        name = split[0]
        type = split[1]
        
        if type.starts(with: "dict") {
            let splitType = type.components(separatedBy: "|")
            
            type = splitType[0]

            if splitType.count != 3 {
                // If we cannot split the appropriate dict|key|value, then default to string -> any
                keyType = "String"
                valueType = "Any"
            } else {
                keyType = splitType[1]
                valueType = splitType[2]
            }
        }
        
        if type.contains(".") {
            let splitType = type.components(separatedBy: ".")
            
            type = splitType[0]
            
            if splitType.count != 2 {
                isArray = false
            } else if ["a", "array", "multi"].contains(splitType[1]) {
                isArray = true
            } else if ["r", "references", "foreign"].contains(splitType[1]) {
                isReference = true
            }
        }
    }
    
    func getSwiftType() -> String {
        switch type {
            case "string", "int", "double", "bool", "date", "any":
                if isArray {
                    return "[\(type.toModelCase())]\(isOptional ? "?" : "")"
                }
                
                return type.toModelCase().appending(isOptional ? "?" : "")
            case "dict":
                // If value type is not empty, but is a custom type, don't capitalize it
                var value = valueType ?? "any"
                
                // If passed value type is dictionary, fail until nested dictionaries are supported
                // TODO: Nested dictionaries
                if value == "dict" {
                    print("[XX] Nested dictionaries are not currently supported, a custom codable type must be passed.")
                    
                    value = "any"
                }

                value = validTypes.contains(value) ? value.toModelCase() : (valueType ?? "Any")
                
                let dictType = "Dictionary<\(keyType?.toModelCase() ?? "Any"), \(value)>"

                if isArray {
                    return "[\(dictType)]\(isOptional ? "?" : "")"
                }
                
                return dictType.appending(isOptional ? "?" : "")
            default:
                print("[XX] Invalid type found, assigning any")
                return "Any"
            
        }
    }
    
    func getFieldKey(spaces: String = "        ") -> String {
        return """
        \(spaces)static var \(name): FieldKey { \"\(name.lowercased())\" }
        """
    }
    
    func getField(spaces: String = "    ") -> String {
        return """
        \(spaces)@Field(key: FieldKeys.\(name)) var \(name): \(self.getSwiftType())
        """
    }
    
    func getFormInput(spaces: String = "    ") -> String {
        return """
        \(spaces)var \(name): \(getSwiftType())
        """
    }
    
    func migrationField(options: MigrationOptions) -> String {
        if options.migrationType == .Delete {
            return ".deleteField(\(options.stringTypes ? "\"\(name)\"" : "\(options.model).FieldKeys.\(name)"))"
        }

        var field = ".field("
        if options.stringTypes {
            field.append("\"\(name)\", ")
        } else {
            // TODO: Use the appropriate model name
            field.append("\(options.model).FieldKeys.\(name), ")
        }
        
        // TODO: Handle array/dict types
        field.append(".\(type)")
        
        if isReference {
            field.append(", .references(\(name.capitalized).schema)")
        }
        
        if isOptional {
            field.append(")")
        } else {
            field.append(", .required)")
        }
        
        return field
    }
    
    func revertField(options: MigrationOptions) -> String {
        if options.migrationType != .Delete {
            return ".deleteField(\(options.stringTypes ? "\"\(name)\"" : "\(options.model).FieldKeys.\(name)"))"
        }

        var field = ".field("
        if options.stringTypes {
            field.append("\"\(name)\", ")
        } else {
            // TODO: Use the appropriate model name
            field.append("\(options.model).FieldKeys.\(name), ")
        }
        
        // TODO: Handle array/dict types
        field.append(".\(type)")
        
        if isReference {
            field.append(", .references(\(name.capitalized).schema)")
        }
        
        // We can never have a required field be defined in the revert, as there would be an issue with missing data
        field.append(")")
        
        return field
    }
}

func generateModelInitializer(fields: [Field]) -> String {
    var initializer = "init("
    
    initializer += fields.map { "\($0.name): \($0.getSwiftType())"}.joined(separator: ", ")
    
    initializer += ") {\n"
    
    initializer += fields.map { "        self.\($0.name) = \($0.name)" }.joined(separator: "\n")

    initializer += "\n    }"

    return initializer
}

func generateFieldKeys(fields: [Field], hasTimestamps: Bool = true) -> String {
    var fieldKeys = """
    static var id: FieldKey { \"id\" }

    """
        
    fieldKeys += fields.map { $0.getFieldKey() }.joined(separator: "\n")
    
    if hasTimestamps {
        fieldKeys += """
        
                static var createdAt: FieldKey { \"created_at\" }
                static var updatedAt: FieldKey { \"updated_at\" }
        """
    }
    return fieldKeys
}

func generateFields(fields: [Field], hasTimestamps: Bool = true) -> String {
    var modelFields = """
    @ID(key: FieldKeys.id) var id: UUID?

    """
    
    modelFields += fields.map { $0.getField() }.joined(separator: "\n")
    
    if hasTimestamps {
        modelFields += """
        
            @Timestamp(key: FieldKeys.createdAt, on: .create) var createdAt: Date?
            @Timestamp(key: FieldKeys.updatedAt, on: .update) var updatedAt: Date?
        """
    }

    return modelFields
}

func extractFieldsData(fields fs: [String], failOnError: Bool = false) -> [Field] {
    var fields = [Field]()
    
    for field in fs {
        fields.append(Field(field: field))
    }

    return fields
}

enum PrettyColor: String {
    case black = "\u{001B}[0;30m"
    case red = "\u{001B}[0;31m"
    case green = "\u{001B}[0;32m"
    case yellow = "\u{001B}[0;33m"
    case blue = "\u{001B}[0;34m"
    case magenta = "\u{001B}[0;35m"
    case cyan = "\u{001B}[0;36m"
    case white = "\u{001B}[0;37m"
    case `default` = "\u{001B}[0;0m"
    
    static func color(_ with: PrettyColor) -> String {
        return with.rawValue
    }
}

final class PrettyLogger {
    static func error(_ info: String, _ prefix: String = "[XX]", color: PrettyColor = .red, fullLength: Bool = false, secondaryColor: PrettyColor = .default) {
        _log(info: info, prefix: prefix, firstColor: color.rawValue, secondColor: fullLength ? color.rawValue : secondaryColor.rawValue)
    }
    
    static func info(_ info: String, _ prefix: String = "[!!]", color: PrettyColor = .blue, fullLength: Bool = false, secondaryColor: PrettyColor = .default) {
        _log(info: info, prefix: prefix, firstColor: color.rawValue, secondColor: fullLength ? color.rawValue : secondaryColor.rawValue)
    }
    
    static func generate(_ info: String, _ prefix: String = "[**]", color: PrettyColor = .green, fullLength: Bool = false, secondaryColor: PrettyColor = .default) {
        _log(info: info, prefix: prefix, firstColor: color.rawValue, secondColor: fullLength ? color.rawValue : secondaryColor.rawValue)
    }
    
    static func log(_ info: String, _ prefix: String = "[--]", color: PrettyColor = .default, fullLength: Bool = false, secondaryColor: PrettyColor = .default) {
        _log(info: info, prefix: prefix, firstColor: color.rawValue, secondColor: fullLength ? color.rawValue : secondaryColor.rawValue)
    }
    
    private static func _log(info: String, prefix: String, firstColor: String, secondColor: String) {
        print("\(firstColor)\(prefix) \(secondColor)\(info)\(PrettyColor.color(.default))")
    }
}

