import ArgumentParser
import Foundation

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

    @Option(help: "Name of application to generate")
    private var name: String?

    @Flag(help: "Display contents of conflicting files")
    private var showContents = false

    @Flag(name: .shortAndLong, help: "Add authentication middleware")
    private var middlewareAuthenticator = false
    
    @Flag(name: .shortAndLong, help: "Only use JWT authentication middleware with authenticator flag.")
    private var jwt = false
    
    @Flag(name: .shortAndLong, help: "Only use web session middleware with authenticator flag.")
    private var web = false
    
    @Flag(name: .shortAndLong, help: "Skip loading a Redis configuration.")
    private var redisSkip = false
    
    @Flag(name: .shortAndLong, help: "Skip creating Environment extensions.")
    private var environmentSkip = false
    
    @Flag(name: .shortAndLong, help: "Don't include AutoMigrator in configuration.")
    private var autoMigrationSkip = false
    
    @Flag(name: .shortAndLong, help: "Don't load JWT signing keys.")
    private var signingSkip = false

    func run() throws {
        if name != nil {
            print("Initiating Vapor application \(name!)")
        } else {
            print("Initiating Vapor application")
        }
        
        #warning("Generate full vapor application here")
        
        let config = ConfigurationGenerator.generateRedisConfiguration()
        
        FileHandler.changeFileWithContents(
            config, fileName: "configuration.swift",
            path: .ApplicationPath
        )

        let controllerProtocol = ControllerGenerator.generateControllerProtocol()
        
        FileHandler.createFileWithContents(
            controllerProtocol,
            fileName: "ControllerProtocol.swift",
            path: .ProtocolPath
        )
        
        let modelProtocol = ControllerGenerator.generateModelProtocol()
        
        FileHandler.createFileWithContents(
            modelProtocol,
            fileName: "ControllerModelProtocol.swift",
            path: .ProtocolPath
        )
        
        if middlewareAuthenticator {
            let jwtMiddleware = AuthenticationGenerator.generateJWTMiddleware()
            let jwtToken = AuthenticationGenerator.generateToken()
            let webMiddleware = AuthenticationGenerator.generateWebMiddleware()

            if jwt {
                FileHandler.createFileWithContents(
                    jwtMiddleware,
                    fileName: "APIMiddleware.swift",
                    path: .MiddlewarePath,
                    displayIfConflicting: true
                )
                
                FileHandler.createFileWithContents(
                    jwtToken,
                    fileName: "Token.swift",
                    path: .ModelPath,
                    displayIfConflicting: true
                )
            } else if web {
                FileHandler.createFileWithContents(
                    webMiddleware,
                    fileName: "WebMiddleware.swift",
                    path: .MiddlewarePath,
                    displayIfConflicting: true
                )
            } else {
                FileHandler.createFileWithContents(
                    jwtMiddleware,
                    fileName: "APIMiddleware.swift",
                    path: .MiddlewarePath,
                    displayIfConflicting: true
                )
                
                FileHandler.createFileWithContents(
                    jwtToken,
                    fileName: "Token.swift",
                    path: .ModelPath,
                    displayIfConflicting: true
                )
                
                FileHandler.createFileWithContents(
                    webMiddleware,
                    fileName: "WebMiddleware.swift",
                    path: .MiddlewarePath,
                    displayIfConflicting: true
                )
            }
        }
    }
}
