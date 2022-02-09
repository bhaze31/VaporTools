import Foundation

enum MigrationType: String {
    case Add
    case Create
    case Delete
    case Drop
    case Unknown
}

#warning("TODO (04/10/2021) Add reference types")

final class MigrationGenerator {
    private static func generateAddField(model: String, field: String, type: String, isArray: Bool, isOptional: Bool, modifyFieldCase: Bool = true) -> String {
        let type = isArray ? ".array(of: .\(type))" : ".\(type)"
        let required = isOptional ? "" : ", .required"
        let fieldKey = modifyFieldCase ? field.lowercased() : field
        return  ".field(\(model).FieldKeys.\(fieldKey), \(type)\(required))"
    }
    
    private static func generateDeleteField(model: String, field: String) -> String {
        return ".deleteField(\(model.toModelCase()).FieldKeys.\(field.lowercased()))"
    }
    
    private static func fieldsGenerator(name: String, fields: [String], skipTimestamps: Bool, migrationType: MigrationType = .Add, isInverse: Bool = false) -> String {
        var migration = ""
        for field in fields {
            let split = field.components(separatedBy: ":")

            if (split.count != 2 && split.count != 3) {
                fatalError("Invalid argument for field: \(field)")
            }

            let fieldName = split[0]

            if migrationType == .Delete {
                migration += """
                            \(generateDeleteField(model: name, field: fieldName))

                """
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
            
            migration += """
                        \(generateAddField(model: name, field: fieldName, type: fieldType, isArray: isArray, isOptional: optional || isInverse))

            """

        }
        
        if !skipTimestamps {
            migration += """
                        \(generateAddField(model: name, field: "createdAt", type: "datetime", isArray: false, isOptional: true, modifyFieldCase: false))
                        \(generateAddField(model: name, field: "updatedAt", type: "datetime", isArray: false, isOptional: true, modifyFieldCase: false))

            """
        }
        
        return migration
    }
    
    private static func migrationHeader(name: String, model: String, timestamp: String, autoMigrate: Bool = false) -> String {
        if autoMigrate {
            return """
            import Fluent
            import AutoMigrator
            
            final class M\(timestamp)_\(name): AutoMigration {
                override var name: String { String(reflecting: self) }
                override var defaultName: String { String(reflecting: self) }
            
                override func prepare(on database: Database) -> EventLoopFuture<Void> {
                    database.schema(\(model.toModelCase()).schema)

            """
        }

        return """
        import Fluent
        
        final class M\(timestamp)_\(name): Migration {
            func prepare(on database: Database) -> EventLoopFuture<Void> {
                database.schema(\(model.toModelCase()).schema)

        """
    }

    public static func emptyMigration(name: String, timestamp: String, autoMigrate: Bool = false) -> String {
        if autoMigrate {
            return """
            import Fluent
            import AutoMigrator

            final class M\(timestamp)_\(name): AutoMigration {
                override var name: String { String(reflecting: self) }
                override var defaultName: String { String(reflecting: self) }

                override func prepare(on database: Database) -> EventLoopFuture<Void> {
                }
            
                override func revert(on database: Database) -> EventLoopFuture<Void> {
                }
            }
            """
        } else {
            return """
            import Fluent
                
            final class M\(timestamp)_\(name): Migration {
                func prepare(on database: Database) -> EventLoopFuture<Void> {
                }
            
                func revert(on database: Database) -> EventLoopFuture<Void> {
                }
            }
            """
        }
    }

    static func initialMigrationGenerator(name: String, fields: [String], skipTimestamps: Bool, timestamp: String, autoMigrate: Bool = false) -> String {
        var migration = migrationHeader(name: name, model: name, timestamp: timestamp, autoMigrate: autoMigrate)

        migration += """
                    .id()\n
        """

        migration += fieldsGenerator(name: name, fields: fields, skipTimestamps: skipTimestamps)
        
        migration += """
                    .create()
            }
        
        
        """
        
        migration += """
            \(autoMigrate ? "override " : "")func revert(on database: Database) -> EventLoopFuture<Void> {
                database.schema(\(name).schema)
                    .delete()
            }
        }
        """

        return migration
    }
    
    static func generateFieldMigration(name: String, model _model: String? = nil, fields: [String] = [], timestamp: String = "", type: MigrationType = .Unknown, autoMigrate: Bool = false) -> String {
        guard let model = _model else {
            return emptyMigration(name: name, timestamp: timestamp)
        }
        
        var migration = migrationHeader(name: name, model: model, timestamp: timestamp, autoMigrate: autoMigrate)

        migration += fieldsGenerator(name: model, fields: fields, skipTimestamps: true, migrationType: type)

        migration += """
                    .update()
            }
        
        
        """
        
        migration += """
            \(autoMigrate ? "override " : "")func revert(on database: Database) -> EventLoopFuture<Void> {
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
