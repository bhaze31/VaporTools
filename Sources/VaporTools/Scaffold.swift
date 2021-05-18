import ArgumentParser
import Foundation

struct Scaffold: ParsableCommand {
    func modelGenerator(name: String, fields: [String]) -> String {
        if FileGenerator.fileExists(fileName: "\(name.capitalized).swift", path: .ModelPath) {
            fatalError("Model \(name.capitalized) already exists at path")
        }
        
        print("Generating model \(name.capitalized)")
        
        
        var fieldKeys = """
    static var id: FieldKey { \"id\" }
    """
        
        // TODO: Implement check for Int id flag
        var modelFields = """
    @ID(key: FieldKeys.id) var id: UUID?
    """
        
        var initializer = "init("
        var initializeFields = ""
        
        var isFirstField = true
        
        for field in fields {
            let split = field.split(separator: ":")
            
            if split.count != 2 && split.count != 3 {
                fatalError("Invalid argument for field: \(field)")
            }
            
            var optional = false
            
            if split.count == 3 && ["optional", "o", "true"].contains(String(split[2])) {
                optional = true
            }
            
            let field = String(split[0])
            var fieldType = String(split[1])
            var isArray = false
            
            if fieldType.contains(".") {
                let splitFieldType = fieldType.split(separator: ".")
                
                // TODO: Handle dictionary types with two .
                if splitFieldType.count != 2 {
                    fatalError("Field type can only contain one . for definition.")
                }
                
                fieldType = String(splitFieldType[0])
                
                if ["a", "array", "multi"].contains(String(splitFieldType[1])) {
                    isArray = true
                }
            }
            
            if !validFieldTypes.contains(fieldType.lowercased()) {
                fatalError("Invalid type for field: \(field), valid types are: \(validFieldTypes)")
            }
            
            
            fieldKeys += """
      
          static var \(field): FieldKey { \"\(field.lowercased())\" }
      """
            
            let definition = "\(isArray ? "[" : "")\(fieldType.capitalized)\(isArray ? "]" : "")\(optional ? "?" : "")"
            
            modelFields += """
      
        @Field(key: FieldKeys.\(field)) var \(field): \(definition)
      """
            
            if isFirstField {
                initializer += "\(field): \(definition)"
                isFirstField = false
            } else {
                initializer += ", \(field): \(definition)"
            }
            
            initializeFields += """
      
          self.\(field) = \(field)
      """
        }
        
        initializer += """
    ) {\(initializeFields)
      }
    """
        
        if !skipTimestamps {
            fieldKeys += """
      
          static var createdAt: FieldKey { \"created_at\" }
          static var updatedAt: FieldKey { \"updated_at\" }
      """
            
            modelFields += """
      
        @Timestamp(key: FieldKeys.createdAt, on: .create) var createdAt: Date?
        @Timestamp(key: FieldKeys.updatedAt, on: .update) var updatedAt: Date?
      """
        }
        
        let model = """
    import Vapor
    import Fluent
    
    final class \(name.capitalized): Model {
      static let schema = \"\(name.lowercased())\"
    
      struct FieldKeys {
        \(fieldKeys)
      }
    
      \(modelFields)
    
      init() {}
    
      \(initializer)
    }
    """
        
        return model
    }
    public static let configuration = CommandConfiguration(abstract: "Generate a model for a Vapor application")
    
    @Argument(help: "The name of the model")
    private var name: String
    
    @Argument(help: "The fields for the model")
    private var fields: [String] = []
    
    @Option(help: "Override for the name of the table in the database, defaults to Model name")
    private var schema: String?
    
    @Flag(help: "Use Int instead of UUID for Model ID")
    private var intId = false
    
    @Flag(help: "Skip auto-generated timestamps for the Model")
    private var skipTimestamps = false
    
    private var validFieldTypes = ["string", "int", "double", "bool"]
    
    func run() throws {
        let model = modelGenerator(name: name, fields: fields)
        FileGenerator.createFileWithContents(model, fileName: "\(name.capitalized).swift", path: .ModelPath)
    }
}
