import ArgumentParser
import Foundation

final class ScaffoldCommand: ParsableCommand {
    static let _commandName: String = "scaffold"

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
                    M\(timestamp)_\(name)()
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

        let model = ModelGenerator.generateModel(name: name, fields: fields, hasTimestamps: !skipTimestamps)

        let resource = resourceGenerator(name: name.capitalized, timestamp: timestamp, autoMigrate: autoMigrate)
        
        let migration = MigrationGenerator.initialMigrationGenerator(
            name: name.capitalized,
            fields: fields,
            skipTimestamps: skipTimestamps,
            timestamp: timestamp,
            autoMigrate: autoMigrate
        )
        
        let form = FormGenerator.generateForm(
            model: name,
            fields: fields
        )
        
        // Creating Model
        FileHandler.createFileWithContents(
            model,
            fileName: "\(name.capitalized).swift",
            path: .ModelPath
        )
        
        // Creating Representable
        // If we have basic or noRepresentable, we do not generate these files
        if !(basic || noRepresentable) {
            let apiRepresentable = ModelGenerator.generateAPIRepresentable(for: name)
//            let apiController = ControllerGenerator.generateAPIController(for: name)
            let webRepresentable = ModelGenerator.generateWebRepresentable(for: name)
//            let webController = ControllerGenerator.generateWebController(for: name)

            if apiOnly {
                FileHandler.createFileWithContents(
                    apiRepresentable,
                    fileName: "\(name)+APIRepresentable.swift",
                    path: .ModelPath
                )
            } else if webOnly {
                FileHandler.createFileWithContents(
                    webRepresentable,
                    fileName: "\(name)+WebRepresentable.swift",
                    path: .ModelPath
                )
            } else {
                FileHandler.createFileWithContents(
                    apiRepresentable,
                    fileName: "\(name)+APIRepresentable.swift",
                    path: .ModelPath
                )
                
                FileHandler.createFileWithContents(
                    webRepresentable,
                    fileName: "\(name)+WebRepresentable.swift",
                    path: .ModelPath
                )
            }
        }
        
        if !apiOnly && !noRepresentable {
            FileHandler.createFileWithContents(
                form,
                fileName: "\(name)Form.swift",
                path: .FormPath
            )
        }
        
        FileHandler.createFileWithContents(
            resource,
            fileName: "\(name.capitalized)Resource.swift",
            path: .ResourcePath
        )
        
        FileHandler.createFileWithContents(
            migration,
            fileName: "\(timestamp)_\(name).swift",
            path: .MigrationPath
        )
    }
}
