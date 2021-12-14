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

    func run() throws {
        let appGenerator = AppFiles()
        let sharedGenerator = SharedProtocols()

        if name != nil {
            print("Initiating Vapor application \(name!)")
        } else {
            print("Initiating Vapor application")
        }

        FileHandler.createFileWithContents(
            appGenerator.appRouter,
            fileName: "router.swift",
            path: PathConstants.ApplicationPath,
            displayIfConflicting: showContents
        )

        FileHandler.createFileWithContents(
            sharedGenerator.controllerProtocol,
            fileName: "ControllerProtocol.swift",
            path: PathConstants.ProtocolPath,
            displayIfConflicting: showContents
        )
    
        FileHandler.createFileWithContents(
            sharedGenerator.resource,
            fileName: "Resource.swift",
            path: PathConstants.ProtocolPath,
            displayIfConflicting: showContents
        )
    }
}
