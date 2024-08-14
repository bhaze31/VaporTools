import ArgumentParser
import Foundation

final class InitiateCommand: ParsableCommand {
    static let _commandName: String = "initiate"
    static let configuration = CommandConfiguration(
        abstract: """
        Initiate Vapor app to simmer configuration.

        By default, this generates a Vapor application with Fluent, SQLite, Leaf, JWT key signing, and Redis. SQLite can be overwritten to use  It also adds extensions for Environment to easily extract the data for all of these configurations.

        If you wish to generate a project with a different database or without some of these configurations, there are flags for this. However, other commands may rely on the fact that the configuraiton was generated with these defaults, so please use the sensible flags for all other commands.

        If you are using this for an existing project, you can run this command still but beware that this will overwrite your configuration. It is not necessary to call initialize for an existing project, the only call out here is to add AutoMigrator if you plan to use that in your `Generate` commands.
        """
    )

    @Option(name: [.customShort("a"), .customLong("app")], help: "Name of application to generate. Defaults to 'App'")
    private var name: String = "App"

    @Flag(help: "Display contents of conflicting files")
    private var showContents = false

    @Option(name: [.customLong("db")], help: "The database to be used instead of sqlite, can be one of postgres, mysql, or mongodb")
    private var database: String = "sqlite"

    @Flag(name: .customLong("jwt"), inversion: .prefixedNo, help: "Add JWT support. Defaults to true")
    private var useJWT: Bool = true

    @Flag(name: [.customShort("r"), .customLong("redis")], inversion: .prefixedNo, help: "Add Redis configuration. Defaults to true")
    private var useRedis: Bool = true

    @Option(name: [.customShort("p"), .customLong("port")], help: "Default port to listen on.")
    private var defaultPort: Int?

    func run() throws {
        PrettyLogger.generate("Initiating Vapor application \(name)")

        FileHandler.createFolderUnlessExists(name, isFatal: true)

        FileManager.default.changeCurrentDirectoryPath("./\(name)")

        let databaseName: DatabasePackage

        switch database.lowercased() {
            case "mysql":
                databaseName = .MySQL
            case "postgres", "postgresql":
                databaseName = .PostgreSQL
            case "mongo", "mongodb":
                databaseName = .MongoDB
            default:
                databaseName = .SQLite
        }

        let packageData = InitialPackageData(
            database: databaseName,
            redis: useRedis,
            jwt: useJWT
        )

        InitiateLoader.loadAll(for: name, packageData: packageData)
    }
}
