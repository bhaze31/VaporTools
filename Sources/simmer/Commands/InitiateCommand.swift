import ArgumentParser
import Foundation

#if DEBUG
    let SOURCE_BASE = "Source"
#else
    let SOURCE_BASE = "Sources"
#endif
final class PathGenerator {
    enum Pathname: String {
        case Base = "Sources"
        case Controller
        case Middleware
        case Migrations
        case Model
    }

    static func load(path: Pathname, name: String) -> String {
        #warning("Allow for configuration to determine paths")
        switch (path) {
            case .Base:
                return SOURCE_BASE
            case .Controller:
                return "\(SOURCE_BASE)/\(name)/Controllers"
            case .Middleware:
                return "\(SOURCE_BASE)/\(name)/Middleware"
            case .Migrations:
                return "\(SOURCE_BASE)/\(name)/Migrations"
            case .Model:
                return "\(SOURCE_BASE)/\(name)/Models"
        }
    }
}

final class InitiateCommand: ParsableCommand {
    static let _commandName: String = "initiate"
    static let configuration = CommandConfiguration(
        abstract: """
        Initiate Vapor app to simmer configuration.
        
        By default, this generates a Vapor application with PostgreSQL, Leaf, JWT key signing, and Redis. It also adds extensions for Environment to easily extract the data for all of these configurations.

        If you wish to generate a project with a different database or without some of these configurations, there are flags for this. However, other commands may rely on the fact that the configuraiton was generated with these defaults, so please use the sensible flags for all other commands.

        If you are using this for an existing project, you can run this command still but beware that this will overwrite your configuration. It is not necessary to call initialize for an existing project, the only call out here is to add AutoMigrator if you plan to use that in your `Generate` commands.
        """
    )

    @Option(name: [.customShort("a"), .customLong("app")], help: "Name of application to generate.")
    private var name: String = "App"

    @Flag(name: [.customShort("m"), .customLong("auto-migrator")], help: "Use auto-migrator by default.")
    private var useAutoMigrator: Bool = false
    
    @Flag(help: "Display contents of conflicting files")
    private var showContents = false
    
    @Flag(name: .customLong("postgres"), help: "Add PostgreSQL")
    private var usePostgres: Bool = false
    
    @Flag(name: .customLong("sqlite"), help: "Add SQLite")
    private var useSQLite: Bool = false
    
    @Flag(name: .customLong("mysql"), help: "Add MySQL")
    private var useMySQL: Bool = false
    
    @Flag(name: .customLong("mongodb"), help: "Add MongoDB")
    private var useMongoDB: Bool = false

    @Flag(name: .customLong("jwt"), help: "Add JWT support")
    private var useJWT: Bool = false

    @Flag(name: [.customShort("l"), .customLong("leaf")], help: "Add Leaf for templating.")
    private var useLeaf: Bool = false
    
    @Flag(name: [.customShort("r"), .customLong("redis")], help: "Add Redis configuration.")
    private var useRedis: Bool = false

    func run() throws {
        PrettyLogger.generate("Initiating Vapor application \(name)")
        
        FileHandler.createFolderUnlessExists(name, isFatal: true)
        
        FileManager.default.changeCurrentDirectoryPath("./\(name)")
        
        #warning("Generate full vapor application here")
        #warning("Generate json file to handle defaults (authentication, database, leaf, int vs uuid, etc from default file")
        
        let packageData = SwiftPackageLoader.Packages(
            postgres: usePostgres,
            mysql: useMySQL,
            mongodb: useMongoDB,
            sqlite: useSQLite,
            redis: useRedis,
            leaf: useLeaf,
            jwt: useJWT,
            autoMigrator: useAutoMigrator
        )

        InitiateLoader.loadAll(for: name, packageData: packageData)
    }
}
