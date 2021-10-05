import Foundation

final class FormGenerator {
    fileprivate static func generateFormInput(fields: [Field]) -> String {
        return """
        var id: String?
        \(fields.map { "    \($0.getFormInput())" }.joined(separator: "\n"))
        """
    }
    
    fileprivate static func typeForFormField(field: Field) -> String {
        if field.isArray {
            return "ArrayFormField()"
        }
        
        if field.getSwiftType() == "Bool" {
            return "CheckBoxFormField()"
        }
        
        return "BasicFormField()"
    }
    
    fileprivate static func generateFormFields(fields _fields: [Field]) -> String {
        var fields = """
        var id: String? = nil

        """
        
        for field in _fields {
            fields += """
                var \(field.name) = \(typeForFormField(field: field))

            """
        }
        
        return fields
    }
    
    fileprivate static func generateRequestFields(fields: [Field]) -> String {
        var request = """
        init(req: Request) throws {
                let context = try req.content.decode(Input.self)
        
                if !context.id.isEmpty {
                    self.id = context.id
                }


        """
        
        for field in fields {
            request += """
                    self.\(field.name).value = context.\(field.name)

            """
        }

        request += "    }"

        return request
    }
    
    fileprivate static func generateWriteFields(model: String, fields: [Field]) -> String {
        var write = """
        if let id = self.id {
                    \(model.lowercased()).id = UUID(uuidString: id)
                }
        
        
        """
        
        for field in fields {
            write += """
                    \(model.lowercased()).\(field.name) = self.\(field.name).value

            """
        }
        
        return write
    }
    
    fileprivate static func genereateReadFields(model: String, fields: [Field]) -> String {
        var read = """
        self.id = \(model.lowercased()).id?.uuidString
        
        """
        
        for field in fields {
            read += """
                    self.\(field.name).value = \(model.lowercased()).\(field.name)

            """
        }

        return read
    }

    public static func generateForm(model: String, fields: [String]) -> String {
        let parsed = extractFieldsData(fields: fields)
        let formInput = generateFormInput(fields: parsed)
        let formFields = generateFormFields(fields: parsed)
        let formRequest = generateRequestFields(fields: parsed)
        let formWrite = generateWriteFields(model: model, fields: parsed)
        let formRead = genereateReadFields(model: model, fields: parsed)

        let form = """
        import Vapor
        import Fluent
        
        final class \(model)Form: Form {
            typealias Model = \(model)
        
            struct Input: Content {
                \(formInput)
            }
        
            \(formFields)
            init() {}

            \(formRequest)

            func write(to \(model.lowercased()): \(model)) {
                \(formWrite)
            }
            
            func read(from \(model.lowercased()): \(model)) {
                \(formRead)
            }

            func validate(req: Request) -> EventLoopFuture<Bool> {
                var valid = true
        
                // Add validations

                return req.eventLoop.future(valid)
            }
        }
        """
        
        return form
    }
}
