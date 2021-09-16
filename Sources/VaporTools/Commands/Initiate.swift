import ArgumentParser
import Foundation

struct Initiate: ParsableCommand {
  static let configuration = CommandConfiguration(
    abstract: "Initiate Vapor app to vapor-tools configuration"
  )

  @Option(help: "Name of application to generate")
  private var name: String?

  @Flag(help: "Display contents of conflicting files")
  private var showContents = false

  func run() throws {
    let appGenerator = AppFiles()
    let apiGenerator = APIProtocols()
    let webGenerator = WebProtocols()
    let sharedGenerator = SharedProtocols()

    if name != nil {
      print("Initiating Vapor application \(name!)")
    } else {
      print("Initiating Vapor application")
    }

    FileGenerator.createFileWithContents(
        appGenerator.appRouter,
        fileName: "router.swift",
        path: PathConstants.ApplicationPath,
        displayIfConflicting: showContents
    )

    FileGenerator.createFileWithContents(
        sharedGenerator.controllerProtocol,
        fileName: "ControllerProtocol.swift",
        path: PathConstants.ProtocolPath,
        displayIfConflicting: showContents
    )
    
    FileGenerator.createFileWithContents(
        sharedGenerator.formProtocol,
        fileName: "FormProtocol.swift",
        path: PathConstants.ProtocolPath,
        displayIfConflicting: showContents
    )
    
    FileGenerator.createFileWithContents(
        sharedGenerator.resource,
        fileName: "Resource.swift",
        path: PathConstants.ProtocolPath,
        displayIfConflicting: showContents
    )
    
    FileGenerator.createFileWithContents(
        webGenerator.webControllerProtocol,
        fileName: "WebControllerProtocol.swift",
        path: PathConstants.WebProtocolPath,
        displayIfConflicting: showContents
    )

    FileGenerator.createFileWithContents(
        webGenerator.webRepresentable,
        fileName: "WebRepresentable.swift",
        path: PathConstants.WebProtocolPath,
        displayIfConflicting: showContents
    )
    
    FileGenerator.createFileWithContents(
        apiGenerator.apiProtocol,
        fileName: "APIControllerProtocol.swift",
        path: PathConstants.APIProtocolPath,
        displayIfConflicting: showContents
    )
    FileGenerator.createFileWithContents(
        apiGenerator.apiRepresentable,
        fileName: "APIRepresentable.swift",
        path: PathConstants.APIProtocolPath,
        displayIfConflicting: showContents
    )
    
    FileGenerator.createFileWithContents(
        apiGenerator.validatableContent,
        fileName: "ValidatableContent.swift",
        path: PathConstants.APIProtocolPath,
        displayIfConflicting: showContents
    )
  }
}
