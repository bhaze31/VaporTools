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
    
    func resourceGenerator(name: String, timestamp: String, autoMigrate: Bool = false) -> String {
        var resource = """
        import Fluent
        
        final class \(name)Resource: Resource {
            typealias WebController = \(name)WebController
        
            typealias APIController = \(name)APIController
        
            var webController: \(name)WebController? = \(name)WebController()
            var apiController: \(name)APIController? = \(name)APIController()
        """

        if !autoMigrate {
            resource += """
                var migrations: [Migration] = [
                    M\(timestamp)_\(name)Model()
                ]
            }
            """
        } else {
            resource += """
            }
            """
        }

        return resource
    }
    
    public static let configuration = CommandConfiguration(
        abstract: "Generate necessary resources for a new Model in a Vapor application",
        discussion: """
        rapid-boil is an opinionated library, and as such it makes certain assumptions about the configuration of your application. Below is a list of basic terms in relation to the opinions of the tools. For a more complete explanation, run `rapid-boil manual`.
        
        NOTE: If you have not run `rapid-boil initiate`, you should be passing the --basic flag. Otherwise, your code will not compile.
        
        Model: The resource that represents a table in your database
        Migration: For this command, the initial migration related to the created Model
        [X]Representable: Data can be represented differently within the API and the Web versions, these helper methods return Codable content
        Controllers: Since Web and API representable are different, we also supply two different controllers
        AutoMigrate: A custom class that can be added to your Vapor application that allows for automatically adding all Migrations, use this flag to use that class instead of Migration.
        Views: Basic Show, Index, and Form views to interact with your Model. Not generated if api-only flag is passed.
        Basic: Scaffolding that gives a simple CRUD Controller, along with a Model, Migration, and Views
        """
    )
    
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
    
    @Flag(help: "Use AutoMigrate class for migrations")
    private var autoMigrate = false
    
    @Flag(help: "Only generate an APIRepresentable version for the Model")
    private var apiOnly = false
    
    @Flag(help: "Only generate a WebRepresentable version for the Model")
    private var webOnly = false
    
    @Flag(help: "Do not generate representable versions of the Model")
    private var noRepresentable = false
    
    @Flag(help: "Only initiate Model, Migration, Controller, and Views")
    private var basic = false
    
    func run() throws {
        let timestamp = getTimestamp()
        let model = modelGenerator(name: name, fields: fields)
        
        let resource = resourceGenerator(name: name.capitalized, timestamp: timestamp)
        
        let migration = MigrationGenerator.initialMigrationGenerator(
            name: name.capitalized,
            fields: fields,
            skipTimestamps: skipTimestamps,
            timestamp: timestamp,
            autoMigrate: autoMigrate
        )
        
        FileGenerator.createFileWithContents(
            model,
            fileName: "\(name.capitalized).swift",
            path: .ModelPath
        )
        
        FileGenerator.createFileWithContents(
            resource,
            fileName: "\(name.capitalized)Resource.swift",
            path: .ResourcePath
        )
        
        FileGenerator.createFileWithContents(
            migration,
            fileName: "\(timestamp)_\(name).swift",
            path: .MigrationPath
        )
    }
}
