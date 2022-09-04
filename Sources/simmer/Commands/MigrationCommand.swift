import Foundation
import ArgumentParser

final class MigrationCommand: ParsableCommand {
    static let _commandName: String = "migration"
    static let _name: String = "shortAndLong"

    static let configuration = CommandConfiguration(
        abstract: "Generate a stand-alone migration",
        discussion: """
        To automate the process, pass the name as [Add/Delete][Field][To/From][Model]. If for example you wanted to remove the field nickname from a model User, it would be migration DeleteNicknameFromUser. If you wanted to add a field called username, you would use migration AddUsernameToUser username:string. Note that you need to add the field name you want along with its type.
        
        If you just want to generate an empty migration, you can use any name for your migration and pass --empty.\nIf you have a different naming convention for migration, you can specify the model and type using --model [ModelName] --migration-type [Add/Delete]. MigrationType defaults to Add.
        
        If you want to simply add a new model, use the format Create[Model]. This will work by creating the table instead of updating it, including ID fields. Similarly, use Drop[Model] to delete the table.
        
        For all options, refer to the manual at simmer manual.
        """
    )
    
    
    @Argument(help: "The name of the migration to generate. If empty will default to the timestamp only")
    private var name: String = ""
    
    @Argument(help: "Field name and type for migration")
    private var fields: [String] = []
    
    @Option(help: "The name of the model to use, if not defined in the migration name")
    private var model: String?
    
    @Flag(name: .shortAndLong, help: "Generate an empty migration")
    private var empty = false
    
    @Flag(name: .shortAndLong, help: "Use AutoMigrate class for migrations")
    private var autoMigrate = false

    func run() throws {
        let timestamp = getTimestamp()

        if empty {
            FileHandler.createFileWithContents(
                MigrationGenerator.emptyMigration(name: name, timestamp: timestamp, autoMigrate: autoMigrate),
                fileName:
                "\(timestamp)_\(name).swift",
                path: PathGenerator.load(path: .Migrations, name: "LOAD_CONFIGURATION_FILE")
            )
            
            return
        }

        var parts: [String] = []
        var migrationType: MigrationType = .Unknown
        
        if name.starts(with: "Add") {
            parts = name.components(separatedBy: "To")
            migrationType = .Add
        } else if name.starts(with: "Remove") || name.starts(with: "Delete") {
            parts = name.components(separatedBy: "From")
            migrationType = .Delete
        } else if name.starts(with: "Create") {
            migrationType = .Create
        }
        
        var modelName: String?

        if migrationType == .Create {
            modelName = name
            modelName?.removeFirst(6)
        } else if parts.isEmpty || parts.count == 1 {
            modelName = model
        } else {
            modelName = parts.last
            
            if let _model = model {
                modelName = _model
            }
        }

        let migration = MigrationGenerator.generateFieldMigration(
            name: name,
            model: modelName,
            fields: fields,
            timestamp: timestamp,
            type: migrationType,
            autoMigrate: autoMigrate
        )

        FileHandler.createFileWithContents(
            migration,
            fileName: "\(timestamp)_\(name).swift",
            path: PathGenerator.load(path: .Migrations, name: "MISSING_NAME")
        )
        
        // TODO: Add/Remove field key from model class.
        if migrationType == .Add {
            FileHandler.addFieldKeyToFile(
                folder: PathGenerator.load(path: .Model, name: "MISSING_NAME"),
                fileName: modelName ?? "UNKNOWN",
                fields: fields
            )
        } else if migrationType == .Delete {
            FileHandler.removeFieldKeyFromFile(
                folder: PathGenerator.load(path: .Model, name: "MISSING_NAME"),
                fileName: modelName ?? "UNKNOWN",
                fields: fields.map { $0.components(separatedBy: ":").first ?? "UNKNOWN_FIELD" }
            )
        }
    }
}
