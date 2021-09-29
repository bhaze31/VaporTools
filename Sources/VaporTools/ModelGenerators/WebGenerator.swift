import Foundation

final class WebGenerator {
    private static func generateFieldData(fields: [String]) -> String {
        var fieldString = ""
        
        for field in fields {
            // TODO: Handle optionals and arrays
            let parts = field.split(separator: ":")
            fieldString += "\t\tvar \(parts[0]): \(parts[1].capitalized)\n"
        }
        
        return fieldString
    }
    
    private static func generateFieldInitializers(model: String, fields: [String]) -> String {
        var fieldInitializers = ""
        
        for field in fields {
            let parts = field.split(separator: ":")
            if parts[0] == "id" {
                // TODO: Handle Integer case for id
                fieldInitializers += "\t\t\tself.\(field) = \(model.lowercased()).\(field)!.uuidString\n"
            } else {
                fieldInitializers += "\t\t\tself.\(field) = \(model.lowercased()).\(field)\n"
            }
        }
        
        return fieldInitializers
    }

    static func generateExtension(model: String, fields: [String]) -> String {
        let fieldData = generateFieldData(fields: fields)
        let fieldInitializers = generateFieldInitializers(model: model, fields: fields)
        
        let webExtension = """
        import Foundation
        
        extension \(model): WebRepresentable {
            var viewContext: ViewContext { .init(with: self) }
        
            var viewIdentifier: String { self.id!.uuidString }
        
            struct ViewContext: Encodable {
                \(fieldData)
                init(with \(model.lowercased()): \(model)) {
                    \(fieldInitializers)
                }
            }
        }
        """
        
        return webExtension
    }
}
