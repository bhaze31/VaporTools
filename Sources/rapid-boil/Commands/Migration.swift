import Foundation
import ArgumentParser

struct Migration: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Generate a stand-alone migration",
        discussion: "To automate the process, pass the name as [Add/Delete][Field][To/From][Model]. If for example you wanted to remove the field nickname from a model User, it would be migration DeleteNicknameFromUser. If you wanted to add a field called username, you would use migration AddUsernameToUser username:string. Note that you need to add the field name you want along with its type.\nIf you just want to generate an empty migration, you can use any name for your migration and pass --empty.\nIf you have a different naming convention for migration, you can specify the model and type using --model [ModelName] --migration-type [Add/Delete]. MigrationType defaults to Add."
    )
    
    @Argument(help: "The name of the migration to generate")
    private var name: String
    
    @Argument(help: "Field name and type for migration")
    private var fields: [String] = []
    
    @Option(help: "The name of the model to use, if not defined in the migration name")
    private var model: String?
    
    @Option(help: "The type of migration to run")
    private var migrationType: String?
    
    @Flag(help: "Generate an empty migration")
    private var empty = false
    
    @Flag(help: "Use AutoMigrate class for migrations")
    private var autoMigrate = false

    func run() throws {
        let timestamp = getTimestamp()

        var parts: [String] = []
        var migrationType: MigrationType = .Unknown
        
        if name.starts(with: "Add") {
            parts = name.components(separatedBy: "To")
            migrationType = .Add
        } else if name.starts(with: "Remove") || name.starts(with: "Delete") {
            parts = name.components(separatedBy: "From")
            migrationType = .Delete
        }
        
        var modelName: String?

        if parts.isEmpty || parts.count == 1 {
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

        FileGenerator.createFileWithContents(
            migration,
            fileName: "\(timestamp)_\(name).swift",
            path: .MigrationPath
        )
        
        // TODO: Add/Remove field key from model class.
        if migrationType == .Add {
            FileGenerator.addFieldKeyToFile(
                folder: .ModelPath,
                fileName: modelName ?? "UNKNOWN",
                fields: fields
            )
        } else if migrationType == .Delete {
            FileGenerator.removeFieldKeyFromFile(
                folder: .ModelPath,
                fileName: modelName ?? "UNKNOWN",
                fields: fields.map { $0.components(separatedBy: ":").first ?? "UNKNOWN_FIELD" }
            )
        }
    }
}
