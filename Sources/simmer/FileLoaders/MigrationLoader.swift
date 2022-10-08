final class MigrationLoader {
    static func loadAll(for options: MigrationOptions) {
        if options.isEmpty {
            generateEmptyMigration(options)
        } else {
            generateMigration(options)
        }
        
        if options.migrationType == .Create && !options.skipModel {
            createModel(options)
        }
	}
	
	static func generateMigration(_ options: MigrationOptions) {
        let defaultMigration = FileHandler.fetchDefaultFile("Migration")
        
        print(defaultMigration)
	}
    
    static func generateEmptyMigration(_ options: MigrationOptions) {
        let imports = getImports(useAutoMigrator: options.isAutoMigrate)
        
        let migrationType = getMigrationType(
            useAutoMigrator: options.isAutoMigrate,
            useAsyncMigration: options.isAsync
        )
        
        let migrationName = "M\(options.timestamp)_\(options.name)"
        
        let nameInfo = getNames(useAutoMigration: options.isAutoMigrate)
        
        let migrationSignature = getMigrationSignature(useAutoMigration: options.isAutoMigrate, useAsyncMigration: options.isAsync) + "}"
        
        let revertSignature = getRevertSignature(useAutoMigration: options.isAutoMigrate, useAsyncMigration: options.isAsync) + "}"
        
        let defaultMigration = FileHandler.fetchDefaultFile("Migration")
            .swap(from: "::imports::", to: imports)
            .swap(from: "::migration_type::", to: migrationType)
            .swap(from: "::migration_name::", to: migrationName)
            .swap(from: "::names::", to: nameInfo)
            .swap(from: "::migrate::", to: migrationSignature)
            .swap(from: "::revert::", to: revertSignature)
        
        print(defaultMigration)
    }
    
    static func createModel(_ options: MigrationOptions) {
        
    }
    
    static func getImports(useAutoMigrator: Bool) -> String {
        if useAutoMigrator {
            return "import Foundation\nimport AutoMigrator"
        }
        
        return "import Foundation"
    }
    
    
    static func getMigrationType(useAutoMigrator: Bool, useAsyncMigration: Bool) -> String {
        switch (useAutoMigrator, useAsyncMigration) {
            case (true, true):
                return "AsyncAutoMigration"
            case (true, false):
                return "AutoMigration"
            case (false, true):
                return "AsyncMigration"
            case (false, false):
                return "Migration"
        }
    }
    
    static func getNames(useAutoMigration: Bool) -> String {
        return useAutoMigration ?
            "override var name: String { String(reflecting: self) }\n    override var defaultName: String { String(reflecting: self) }" :
            ""
        
    }
    
    static func getMigrationSignature(useAutoMigration: Bool, useAsyncMigration: Bool) -> String {
        switch (useAutoMigration, useAsyncMigration) {
            case (true, true):
                return "override func prepare(on: database: Database) async throws {"
            case (true, false):
                return "override func prepare(on: database: Database) -> EventLoopFuture<Void> {"
            case (false, true):
                return "func prepare(on: database: Database) async throws {"
            case (false, false):
                return "func prepare(on: database: Database) -> EventLoopFuture<Void> {"
        }
    }
    
    static func getRevertSignature(useAutoMigration: Bool, useAsyncMigration: Bool) -> String {
        switch (useAutoMigration, useAsyncMigration) {
            case (true, true):
                return "override func revert(on database: Database) async throws {"
            case (true, false):
                return "override func revert(on database: Database) -> EventLoopFuture<Void> {"
            case (false, true):
                return "func revert(on database: Database) async throws {"
            case (false, false):
                return "func revert(on database: Database) -> EventLoopFuture<Void> {"
        }
    }
}
