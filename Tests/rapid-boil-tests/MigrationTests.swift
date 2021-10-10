import XCTest
@testable import rapid_boil

final class MigrationTests: XCTestCase {
    func testInitialMigration() {
        let fields = [
            "name:string",
            "email:string",
            "username:string:o"
        ]
        
        let migration = MigrationGenerator.initialMigrationGenerator(
            name: "User",
            fields: fields,
            skipTimestamps: false,
            timestamp: "test_stamp"
        )
        
        XCTAssertEqual(migration, """
        import Fluent

        final class Mtest_stamp_User: Migration {
            func prepare(on database: Database) -> EventLoopFuture<Void> {
                database.schema(User.schema)
                    .id()
                    .field(User.FieldKeys.name, .string, .required)
                    .field(User.FieldKeys.email, .string, .required)
                    .field(User.FieldKeys.username, .string)
                    .field(User.FieldKeys.createdAt, .datetime)
                    .field(User.FieldKeys.updatedAt, .datetime)
                    .create()
            }

            func revert(on database: Database) -> EventLoopFuture<Void> {
                database.schema(User.schema)
                    .delete()
            }
        }
        """)
    }
    
    func testMigrationWithAutoMigration() {
        let fields = [
            "name:string",
            "email:string",
            "username:string:o"
        ]
        
        let migration = MigrationGenerator.initialMigrationGenerator(
            name: "User",
            fields: fields,
            skipTimestamps: false,
            timestamp: "test_stamp",
            autoMigrate: true
        )
        
        XCTAssertEqual(migration, """
        import Fluent
        import AutoMigrator

        final class Mtest_stamp_User: AutoMigration {
            override var name: String { String(reflecting: self) }
            override var defaultName: String { String(reflecting: self) }

            override func prepare(on database: Database) -> EventLoopFuture<Void> {
                database.schema(User.schema)
                    .id()
                    .field(User.FieldKeys.name, .string, .required)
                    .field(User.FieldKeys.email, .string, .required)
                    .field(User.FieldKeys.username, .string)
                    .field(User.FieldKeys.createdAt, .datetime)
                    .field(User.FieldKeys.updatedAt, .datetime)
                    .create()
            }

            override func revert(on database: Database) -> EventLoopFuture<Void> {
                database.schema(User.schema)
                    .delete()
            }
        }
        """)
    }
    
    func testSkipTimestamps() {
        let fields = [
            "name:string",
            "email:string",
            "username:string:o"
        ]
        
        let migration = MigrationGenerator.initialMigrationGenerator(
            name: "User",
            fields: fields,
            skipTimestamps: true,
            timestamp: "test_stamp"
        )
        
        XCTAssertEqual(migration, """
        import Fluent

        final class Mtest_stamp_User: Migration {
            func prepare(on database: Database) -> EventLoopFuture<Void> {
                database.schema(User.schema)
                    .id()
                    .field(User.FieldKeys.name, .string, .required)
                    .field(User.FieldKeys.email, .string, .required)
                    .field(User.FieldKeys.username, .string)
                    .create()
            }

            func revert(on database: Database) -> EventLoopFuture<Void> {
                database.schema(User.schema)
                    .delete()
            }
        }
        """)
    }
    
    func testAddFieldMigration() {
        let fields = ["admin:bool"]
        
        let migration = MigrationGenerator.generateFieldMigration(
            name: "AddAdminToUser",
            model: "User",
            fields: fields,
            timestamp: "test_stamp",
            type: .Add
        )
        
        XCTAssertEqual(migration, """
        import Fluent

        final class Mtest_stamp_AddAdminToUser: Migration {
            func prepare(on database: Database) -> EventLoopFuture<Void> {
                database.schema(User.schema)
                    .field(User.FieldKeys.admin, .bool, .required)
                    .update()
            }

            func revert(on database: Database) -> EventLoopFuture<Void> {
                database.schema(User.schema)
                    .deleteField(User.FieldKeys.admin)
                    .update()
            }
        }
        """)
    }
    
    func testDeleteFieldMigration() {
        let fields = ["admin:bool"]
        
        let migration = MigrationGenerator.generateFieldMigration(
            name: "RemoveAdminFromUser",
            model: "User",
            fields: fields,
            timestamp: "test_stamp",
            type: .Delete
        )
        
        print(migration)
        
        XCTAssertEqual(migration, """
        import Fluent

        final class Mtest_stamp_RemoveAdminFromUser: Migration {
            func prepare(on database: Database) -> EventLoopFuture<Void> {
                database.schema(User.schema)
                    .deleteField(User.FieldKeys.admin)
                    .update()
            }

            func revert(on database: Database) -> EventLoopFuture<Void> {
                database.schema(User.schema)
                    .field(User.FieldKeys.admin, .bool)
                    .update()
            }
        }
        """)
    }
}
