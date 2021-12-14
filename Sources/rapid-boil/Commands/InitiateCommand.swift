import ArgumentParser
import Foundation

final class InitiateCommand: ParsableCommand {
    static let _commandName: String = "initiate"
    static let configuration = CommandConfiguration(
        abstract: "Initiate Vapor app to rapid-boil configuration"
    )

    @Option(help: "Name of application to generate")
    private var name: String?

    @Flag(help: "Display contents of conflicting files")
    private var showContents = false

    @Flag(name: .shortAndLong, help: "Add authentication middleware")
    private var authenticator = false
    
    @Flag(name: .shortAndLong, help: "Only use JWT authentication middleware with authenticator flag.")
    private var jwt = false
    
    @Flag(name: .shortAndLong, help: "Only use web session middleware with authenticator flag.")
    private var web = false
    

    func run() throws {
        if name != nil {
            print("Initiating Vapor application \(name!)")
        } else {
            print("Initiating Vapor application")
        }
        
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
        
        let configuration = ControllerGenerator.generateControllerProtocol()
        
        if authenticator {
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
