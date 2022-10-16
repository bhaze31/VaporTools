//
//  ModelCommand.swift
//  
//
//  Created by Brian Hasenstab on 10/15/22.
//

import ArgumentParser

struct ModelOptions {
    var name: String
    var fields: [Field]
    var softDelete: Bool
    var skipTimestamps: Bool
    var customIdName: String?
    var schemaName: String?
    
}

final class ModelCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "model",
        abstract: "Generate a new model",
        discussion: "Creates a new model without a migration associated to add it to the database. If you want to generate a migration"
    )
    
    @Argument(help: "The name of the model to generate")
    private var name: String
    
    @Argument(help: "Fields")
    private var fields: [String] = []
    
    @Option(name: .shortAndLong, help: "Use a custom field for a model")
    private var customIdName: String?
    
    @Option(name: .shortAndLong, help: "Custom schema name.")
    private var schemaName: String?
    
    @Flag(name: [.long, .customShort("t")], help: "Don't use timestamps for model")
    private var skipTimestamps: Bool = false
    
    @Flag(name: [.long, .customShort("d")], help: "Use soft delete timestamp")
    private var softDelete: Bool = false
    
    
    func run() throws {
        let parsedFields = validateFields(fields: fields)
        
        let options = ModelOptions(
            name: name,
            fields: parsedFields,
            softDelete: softDelete,
            skipTimestamps: skipTimestamps,
            customIdName: customIdName,
            schemaName: schemaName
        )
        
        ModelLoader.generateModel(options: options)
    }
}
