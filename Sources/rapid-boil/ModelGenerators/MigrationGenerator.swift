import Foundation

enum MigrationType: String {
    case Add
    case Delete
    case Unknown
}

final class MigrationGenerator {
    private static func generateAddField(model: String, field: String, type: String, isArray: Bool, isOptional: Bool) -> String {
        let type = isArray ? ".array(of: .\(type))" : ".\(type)"
        let required = isOptional ? "" : ", .required"
        
        return  ".field(\(model.capitalized).FieldKeys.\(field.lowercased()), \(type)\(required))"
    }
    
    private static func generateDeleteField(model: String, field: String) -> String {
        return ".deleteField(\(model.capitalized).FieldKeys.\(field.lowercased()))"
    }
    
    private static func fieldsGenerator(name: String, fields: [String], skipTimestamps: Bool, migrationType: MigrationType = .Add, isInverse: Bool = false) -> String {
        var migration = ""
        for field in fields {
            let split = field.components(separatedBy: ":")
            
            // TODO: Handle case where no inverse should happen. This should allow us to send in only 1 param
            // if it is dropping a field and not re-adding it on the inverse
            if (split.count != 2 && split.count != 3) {
                fatalError("Invalid argument for field: \(field)")
            }

            let fieldName = split[0]

            if migrationType == .Delete {
                migration += "\t\t\t\(generateDeleteField(model: name, field: fieldName))\n"
                continue    
            }
                        
            var optional = false
            
            if split.count == 3 && ["optional", "o", "true"].contains(String(split[2])) {
                optional = true
            }

            var fieldType = split[1]
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
                fatalError("Invalid type for field: \(fieldName), valid types are: \(validFieldTypes)")
            }
            
            migration += "\t\t\t\(generateAddField(model: name, field: fieldName, type: fieldType, isArray: isArray, isOptional: optional || isInverse))\n"

        }
        
        if !skipTimestamps {
            migration += "\t\t\t\(generateAddField(model: name, field: "createdAt", type: "datetime", isArray: false, isOptional: true))\n"
            
            migration += "\t\t\t\(generateAddField(model: name, field: "updatedAt", type: "datetime", isArray: false, isOptional: true))\n"
        }
        
        return migration
    }
    
    private static func migrationHeader(name: String, model: String, timestamp: String, autoMigrate: Bool = false) -> String {
        """
        import Fluent
        
        final class M\(timestamp)_\(name): \(autoMigrate ? "AutoMigration" : "Migration") {
            func prepare(on database: Database) -> EventLoopFuture<Void> {
                database.schema(\(model.capitalized).schema)

        """
    }

    private static func emptyMigration(name: String, timestamp: String) -> String {
        """
        import Fluent
            
        final class M\(timestamp)_\(name.capitalized): Migration {
            func prepare(on database: Database) -> EventLoopFuture<Void> {
            }
        
            func revert(on database: Database) -> EventLoopFuture<Void> {
            }
        }
        """
    }

    static func initialMigrationGenerator(name: String, fields: [String], skipTimestamps: Bool, timestamp: String, autoMigrate: Bool = false) -> String {
        var migration = migrationHeader(name: name, model: name, timestamp: timestamp)

        migration += "\t\t\t.id()\n"

        migration += fieldsGenerator(name: name, fields: fields, skipTimestamps: skipTimestamps)
        
        migration += """
                    .create()
            }
        
        
        """
        
        migration += """
            func revert(on database: Database) -> EventLoopFuture<Void> {
                database.schema(\(name).schema)
                    .delete()
            }
        }
        """
        
        
        return migration
    }
    
    static func generateFieldMigration(name: String, model _model: String?, fields: [String], timestamp: String, type: MigrationType, autoMigrate: Bool = false) -> String {
        guard let model = _model else {
            return emptyMigration(name: name, timestamp: timestamp)
        }
        
        var migration = migrationHeader(name: name, model: model, timestamp: timestamp)
        migration += fieldsGenerator(name: model, fields: fields, skipTimestamps: true, migrationType: type)

        migration += """
                    .update()
            }
        
        
        """
        
        migration += """
            func revert(on database: Database) -> EventLoopFuture<Void> {
                database.schema(\(model).schema)

        """
        
        let inverse: MigrationType = type == .Add ? .Delete : .Add
        migration += fieldsGenerator(name: model, fields: fields, skipTimestamps: true, migrationType: inverse, isInverse: true)

        migration += """
                    .update()
            }
        
        }
        """
        return migration
    }
}
