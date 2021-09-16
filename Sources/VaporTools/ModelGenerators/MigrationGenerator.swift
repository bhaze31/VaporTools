import Foundation

final class MigrationGenerator {
    private static func generateField(model: String, field: String, type: String, isArray: Bool, isOptional: Bool) -> String {
        let type = isArray ? ".array(of: .\(type))" : ".\(type)"
        let required = isOptional ? "" : ", .required"
        
        return  ".field(\(model.capitalized).FieldKeys.\(field.lowercased()), \(type)\(required))"
    }
    
    private static func fieldsGenerator(name: String, fields: [String], skipTimestamps: Bool) -> String {
        var migration = ""
        for field in fields {
            let split = field.split(separator: ":")
            
            if split.count != 2 && split.count != 3 {
                fatalError("Invalid argument for field: \(field)")
            }
            
            var optional = false
            
            if split.count == 3 && ["optional", "o", "true"].contains(String(split[2])) {
                optional = true
            }
            
            let field = String(split[0])
            var fieldType = String(split[1])
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
                fatalError("Invalid type for field: \(field), valid types are: \(validFieldTypes)")
            }
            
            migration += "\t\t\t\(generateField(model: name, field: field, type: fieldType, isArray: isArray, isOptional: optional))\n"

        }
        
        if !skipTimestamps {
            migration += "\t\t\t\(generateField(model: name, field: "createdAt", type: "datetime", isArray: false, isOptional: true))\n"
            
            migration += "\t\t\t\(generateField(model: name, field: "updatedAt", type: "datetime", isArray: false, isOptional: true))\n"
        }
        
        return migration
    }
    
    private static func migrationHeader(name: String, timestamp: String) -> String {
        """
        import Fluent
        
        final class M\(timestamp)_\(name.capitalized): Migration {
            func prepare(on database: Database) -> EventLoopFuture<Void> {
                database.schema(\(name.capitalized).schema)
                    .id()
        
        """
    }

    static func initialMigrationGenerator(name: String, fields: [String], skipTimestamps: Bool, timestamp: String) -> String {
        var migration = migrationHeader(name: name, timestamp: timestamp)
        
        migration += fieldsGenerator(name: name, fields: fields, skipTimestamps: skipTimestamps)
        
        migration += """
                    .create()
            }
        
        
        """
        
        migration += """
            func revert(on database: Database) -> EventLoopFuture<Void> {
                database.schema(\(name.capitalized).schema)
                    .delete()
            }
        }
        """
        
        
        return migration
    }
    
    static func generateFieldMigration(name: String, fields: [String]) {
        
    }
}
