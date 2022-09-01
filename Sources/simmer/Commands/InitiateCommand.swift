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

    @Option(name: [.customShort("n"), .customLong("app-name")], help: "Name of application to generate")
    private var name: String = "App"

    @Flag(help: "Display contents of conflicting files")
    private var showContents = false

    // @Flag(name: .shortAndLong, help: "Add authentication middleware")
    // private var middlewareAuthenticator = false
    // 
    // @Flag(name: .shortAndLong, help: "Only use JWT authentication middleware with authenticator flag.")
    // private var jwt = false
    
    // @Flag(name: .shortAndLong, help: "Only use web session middleware with authenticator flag.")
    // private var web = false
    
    // @Flag(name: .shortAndLong, help: "Skip loading a Redis configuration.")
    // private var redisSkip = false
    
    // @Flag(name: .shortAndLong, help: "Skip creating Environment extensions.")
    // private var environmentSkip = false
    
    // @Flag(name: .shortAndLong, help: "Don't include AutoMigrator in configuration.")
    // private var autoMigrationSkip = false
    
    // @Flag(name: .shortAndLong, help: "Don't load JWT signing keys.")
    // private var signingSkip = false

    func run() throws {
        PrettyLogger.generate("Initiating Vapor application \(name)")
        
        FileHandler.createFolderUnlessExists(name, isFatal: true)
        FileManager.default.changeCurrentDirectoryPath("./\(name)")
        
        FileHandler.createFileWithContents(
            """
            {
                "appname": "\(name)"
            }
            """,
            fileName: "ersatz.json",
            path: .BasePath
        )

        FileHandler.createFileWithContents("Test file", fileName: "Package.swift", path: .RootPath)

        #warning("Generate full vapor application here")
        #warning("Generate json file to handle defaults (authentication, database, leaf, int vs uuid, etc")
        
//         let config = ConfigurationGenerator.generateRedisConfiguration()
//         
//         FileHandler.changeFileWithContents(
//             config,
//             fileName: "configure.swift",
//             path: .ApplicationPath
//         )
// 
//         let controllerProtocol = ControllerGenerator.generateControllerProtocol()
//         
//         FileHandler.createFileWithContents(
//             controllerProtocol,
//             fileName: "ControllerProtocol.swift",
//             path: .ProtocolPath
//         )
//         
//         let modelProtocol = ControllerGenerator.generateModelProtocol()
//         
//         FileHandler.createFileWithContents(
//             modelProtocol,
//             fileName: "ControllerModelProtocol.swift",
//             path: .ProtocolPath
//         )
//         
//         if middlewareAuthenticator {
//             let jwtMiddleware = AuthenticationGenerator.generateJWTMiddleware()
//             let jwtToken = AuthenticationGenerator.generateToken()
//             let webMiddleware = AuthenticationGenerator.generateWebMiddleware()
// 
//             if jwt {
//                 FileHandler.createFileWithContents(
//                     jwtMiddleware,
//                     fileName: "APIMiddleware.swift",
//                     path: .MiddlewarePath,
//                     displayIfConflicting: true
//                 )
//                 
//                 FileHandler.createFileWithContents(
//                     jwtToken,
//                     fileName: "Token.swift",
//                     path: .ModelPath,
//                     displayIfConflicting: true
//                 )
//             } else if web {
//                 FileHandler.createFileWithContents(
//                     webMiddleware,
//                     fileName: "WebMiddleware.swift",
//                     path: .MiddlewarePath,
//                     displayIfConflicting: true
//                 )
//             } else {
//                 FileHandler.createFileWithContents(
//                     jwtMiddleware,
//                     fileName: "APIMiddleware.swift",
//                     path: .MiddlewarePath,
//                     displayIfConflicting: true
//                 )
//                 
//                 FileHandler.createFileWithContents(
//                     jwtToken,
//                     fileName: "Token.swift",
//                     path: .ModelPath,
//                     displayIfConflicting: true
//                 )
//                 
//                 FileHandler.createFileWithContents(
//                     webMiddleware,
//                     fileName: "WebMiddleware.swift",
//                     path: .MiddlewarePath,
//                     displayIfConflicting: true
//                 )
//             }
//         }
    }
}
