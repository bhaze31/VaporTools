import Foundation

var validFieldTypes = ["string", "int", "double", "bool", "dict", "date"]

func getTimestamp() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "YYYYMMddHHmmssSSS"
    return formatter.string(from: Date())
}

struct Field {
    var name: String
    var type: String
    var isOptional: Bool = false
    var isArray: Bool = false
    
    // For dictionary items
    var keyType: String?
    var valueType: String?
    
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

let validTypes = ["string", "int", "double", "bool", "dict", "date", "any"]

func extractFieldsData(fields fs: [String], failOnError: Bool = false) -> [Field] {
    var fields = [Field]()
    
    for field in fs {
        let split = field.components(separatedBy: ":")
        
        if split.count != 2 && split.count != 3 {
            if failOnError {
                fatalError("Invalid field: \(field). Should be in the format <name>:<type>:[o] where the last part is optional and indicates an optional value.")
            }

            print("[XX] Invalid field: \(field). Should be in the format <name>:<type>:[o] where the last part is optional and indicates an optional value.")
            continue
        }
        
        let optional = split.count == 3 && ["optional", "o", "true"].contains(split[2])
        
        let fieldName = split[0]
        var fieldType = split[1]
        var array = false
        var keyType: String?
        var valueType: String?
        
        if fieldType.starts(with: "dict") {
            let splitType = fieldType.components(separatedBy: "|")
            
            if splitType.count != 3 {
                if failOnError {
                    fatalError("Dict type must be in format dict|[key_type]|[value_type].")
                }
                
                print("[XX] Dict type must be in format dict|[key_type]|[value_type].")
                continue
            }
            
            fieldType = splitType[0]
            keyType = splitType[1]
            valueType = splitType[2]
        }
        
        if fieldType.contains(".") {
            let splitType = fieldType.components(separatedBy: ".")
            
            if splitType.count != 2 {
                if failOnError {
                    fatalError("Type can only contain one . for definition.")
                }
                
                print("[XX] Type can only contain one . for definition.")
                continue
            }
            
            fieldType = splitType[0]
            
            if ["a", "array", "multi"].contains(splitType[1]) {
                array = true
            }
        }
        
        // TODO: Handle Dictionary type

        fields.append(Field(
            name: fieldName,
            type: fieldType,
            isOptional: optional,
            isArray: array,
            keyType: keyType,
            valueType: valueType
        ))
    }

    return fields
}

