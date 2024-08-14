//
//  File.swift
//  
//
//  Created by Brian Hasenstab on 4/1/23.
//

import Foundation
import ConsoleKit

final class VaporMigrationCommand: Command {
    static var name = "migrate"

    struct Signature: CommandSignature {
        @Argument(name: "name", help: "The name of the migration to generate")
        private var name: String
        
        
//        @Argument(name: "fields", help: "The fields for the migration")
//        private var fields: [String]
        
        
//        @Argument(name: "fields", help: "Fields for migration, io")
//        private var fields: [String] = []
        
//        @Option(help: "The name of the model to use, if not defined in the migration name")
//        private var model: String?
//
//        @Flag(name: .shortAndLong, help: "Generate an empty migration")
//        private var empty = false
//
//        @Flag(name: [.customShort("m"), .long], help: "Use AutoMigrate class for migrations")
//        private var autoMigrate = false
//
//        @Flag(name: [.customShort("a"), .customLong("async")], help: "Create an async migration")
//        private var isAsync = false
//
//        @Flag(name: .shortAndLong, help: "Use strings as opposed to field keys")
//        private var stringTypes = false
//
//        @Flag(name: .long, help: "Skip model if migration type is Create")
//        private var skipModel = false
//
//        @Flag(name: [.long, .customShort("d")], help: "If creating a model, use soft delete for this model. Otherwise ignored")
//         private var softDelete = false
//
//        @Flag(name: [.long, .customShort("t")], help: "Skip timestamps if the creating a model. Otherwise ignored")
//        private var skipTimestamps = false
    }
    
    let help: String = """
    
    """
    
    func run(using context: CommandContext, signature: Signature) throws {
        print(signature)
        print(context.input.arguments)
    }
}
