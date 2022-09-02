import ArgumentParser
import Foundation

final class ScaffoldCommand: ParsableCommand {
    static let _commandName: String = "scaffold"

    public static let configuration = CommandConfiguration(
        abstract: "Generate necessary resources for a new Model in a Vapor application",
        discussion: """
        simmer is an opinionated library, and as such it makes certain assumptions about the configuration of your application. Below is a list of basic terms in relation to the opinions of the tools. For a more complete explanation, run `simmer manual`.
        
        NOTE: If you have not run `simmer initiate`, you should be passing the --basic flag. Otherwise, your code will not compile.
        
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
    
    @Flag(help: "Do not generate representable versions of the Model")
    private var noRepresentable = false
    
    @Flag(help: "Only initiate Model, Migration, Controller, and Views")
    private var basic = false
    
    func run() throws {
        let timestamp = getTimestamp()

        let model = ModelGenerator.generateModel(name: name, fields: fields, hasTimestamps: !skipTimestamps)
        
        let controller = ControllerGenerator.generateModelController(for: name)
        
        let migration = MigrationGenerator.initialMigrationGenerator(
            name: name.toModelCase(),
            fields: fields,
            skipTimestamps: skipTimestamps,
            timestamp: timestamp,
            autoMigrate: autoMigrate
        )
        
        let indexView = ViewsGenerator.generateIndexView(
            for: name.toModelCase(),
            fields: fields,
            hasTimestamps: !skipTimestamps
        )
        
        let showView = ViewsGenerator.generateShowView(
            model: name,
            fields: fields
        )
        
        FileHandler.createMainView()

        FileHandler.createViewFileWithContents(
            indexView,
            model: name,
            fileName: "index"
        )
        
        FileHandler.createViewFileWithContents(
            showView,
            model: name,
            fileName: "show"
        )

        FileHandler.createFileWithContents(
            model,
            fileName: "\(name.toModelCase()).swift",
            path: .ModelPath
        )
        
        FileHandler.createFileWithContents(
            controller,
            fileName: "\(name.toModelCase())Controller.swift",
            path: .ControllerPath
        )
        
        FileHandler.createFileWithContents(
            migration,
            fileName: "\(timestamp)_Create\(name).swift",
            path: .MigrationPath
        )
        
        
    }
}
