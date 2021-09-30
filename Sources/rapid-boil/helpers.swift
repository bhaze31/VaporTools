import Foundation

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
                    return "[\(type.capitalized)]\(isOptional ? "?" : "")"
                }
                
                return type.capitalized.appending(isOptional ? "?" : "")
            case "dict":
                // If value type is not empty, but is a custom type, don't capitalize it
                var value = valueType ?? "any"
                
                // If passed value type is dictionary, fail until nested dictionaries are supported
                // TODO: Nested dictionaries
                if value == "dict" {
                    print("[XX] Nested dictionaries are not currently supported, a custom codable type must be passed.")
                    
                    value = "any"
                }

                value = validTypes.contains(value) ? value.capitalized : (valueType ?? "Any")
                
                let dictType = "Dictionary<\(keyType?.capitalized ?? "Any"), \(value)>"

                if isArray {
                    return "[\(dictType)]\(isOptional ? "?" : "")"
                }
                
                return dictType.appending(isOptional ? "?" : "")
            default:
                print("[XX] Invalid type found, assigning any")
                return "Any"
            
        }
    }
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
