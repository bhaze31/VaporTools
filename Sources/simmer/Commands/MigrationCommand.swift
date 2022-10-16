import Foundation
import ArgumentParser

enum MigrationType {
    case Add
    case Delete
    case Create
    case Unknown
}

struct MigrationOptions {
    var name: String
    var timestamp: String
    var migrationType: MigrationType
    var fields: [String]
    var model: String
    var isAutoMigrate: Bool
    var isAsync: Bool
    var stringTypes: Bool
    var isEmpty: Bool
    var skipModel: Bool
    
    init(name: String, fields: [String], model: String?, isAutoMigrate: Bool, isAsync: Bool, stringTypes: Bool, isEmpty: Bool, skipModel: Bool) {
        self.fields = fields
        
        if name.starts(with: "Add") {
            let parts = name.components(separatedBy: "To")
            self.migrationType = .Add
            self.model = parts.last!
            
            if parts.count == 2, var field = parts.first {
                field.removeFirst(3)
                self.fields.append("\(field.lowercased()):string")
            }
        } else if name.starts(with: "Remove") || name.starts(with: "Delete") {
            let parts = name.components(separatedBy: "From")
            migrationType = .Delete
            self.model = parts.last!
            
            if parts.count == 2, var field = parts.first {
                field.removeFirst(6)
                self.fields.append("\(field.lowercased()):string")
            }
        } else if name.starts(with: "Create") {
            migrationType = .Create
            
            self.model = name
            self.model.removeFirst(6)
        } else {
            migrationType = .Unknown
            self.model = name
        }
        
        if let _model = model {
            self.model = _model
        }
        
        self.timestamp = getTimestamp()
        self.name = name
        self.isAutoMigrate = isAutoMigrate
        self.isAsync = isAsync
        self.stringTypes = stringTypes
        self.isEmpty = isEmpty
        self.skipModel = skipModel
        
        if let field = extractDefaultField(name: name) {
            self.fields.append(field)
        }
    }
    
    func extractDefaultField(name: String) -> String? {
        if name.starts(with: "Add") {
            
        } else if name.starts(with: "Delete") || name.starts(with: "Remove") {
            
        } else if name.starts(with: "Create") {
            
        }
        
        return nil
    }
}

final class MigrationCommand: ParsableCommand {
    static let _commandName: String = "migration"

    static let configuration = CommandConfiguration(
        abstract: "Generate a stand-alone migration",
        discussion: """
        To automate the process, pass the name as [Add/Delete][Field][To/From][Model]. If for example you wanted to remove the field nickname from a model User, it would be migration DeleteNicknameFromUser. If you wanted to add a field called username, you would use migration AddUsernameToUser username:string. Note that you need to add the field name you want along with its type.
        
        If you just want to generate an empty migration, you can use any name for your migration and pass --empty.\nIf you have a different naming convention for migration, you can specify the model and type using --model [ModelName] --migration-type [Add/Delete]. MigrationType defaults to Add.
        
        If you want to simply add a new model, use the format Create[Model]. This will work by creating the table instead of updating it, including ID fields. Similarly, use Drop[Model] to delete the table.
        
        For all options, refer to the manual at simmer manual.
        """
    )

    @Argument(help: "The name of the migration to generate.")
    private var name: String
    
    @Argument(help: "Fields for migration, io")
    private var fields: [String] = []
    
    @Option(help: "The name of the model to use, if not defined in the migration name")
    private var model: String?
    
    @Flag(name: .shortAndLong, help: "Generate an empty migration")
    private var empty = false
    
    @Flag(name: [.customShort("m"), .long], help: "Use AutoMigrate class for migrations")
    private var autoMigrate = false
    
    @Flag(name: [.customShort("a"), .customLong("async")], help: "Create an async migration")
    private var isAsync = false
    
    @Flag(name: .shortAndLong, help: "Use strings as opposed to field keys")
    private var stringTypes = false
    
    @Flag(name: .long, help: "Skip model if migration type is Create.")
    private var skipModel = false

    func run() throws {
        let options = MigrationOptions(
            name: name,
            fields: fields,
            model: model,
            isAutoMigrate: autoMigrate,
            isAsync: isAsync,
            stringTypes: stringTypes,
            isEmpty: empty,
            skipModel: skipModel
        )

        MigrationLoader.loadAll(for: options)
    }
}
