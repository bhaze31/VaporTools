import ArgumentParser
import Foundation

struct Initiate: ParsableCommand {
  static let configuration = CommandConfiguration(
    abstract: "Initiate Vapor app to VaporTools configuration"
  )

  @Option(help: "Name of application to generate")
  private var name: String?

  private func appRouter() -> String {
    return """
import Vapor

final class AppRouter {
  var app: Application

  init(_ application: Application) {
    self.app = application
  }

  func loadResources() throws {

  }

  func loadRoutes() throws {

  }
}
"""
  }
    
  func run() throws {
    let apiGenerator = APIProtocols()
    
    let sharedGenerator = SharedProtocols()

    if name != nil {
      print("Initiating Vapor application \(name!)")
    } else {
      print("Initiating Vapor application")
    }

    print(appRouter())
    
    FileGenerator.createFileWithContents(sharedGenerator.controllerProtocol, fileName: "ControllerProtocol.swift", path: PathConstants.ProtocolPath)
    FileGenerator.createFileWithContents(apiGenerator.apiProtocol, fileName: "APIControllerProtocol.swift", path: PathConstants.APIProtocolPath)
    FileGenerator.createFileWithContents(apiGenerator.apiRepresentable, fileName: "APIRepresentable.swift", path: PathConstants.APIProtocolPath)
    FileGenerator.createFileWithContents(apiGenerator.validatableContent, fileName: "ValidatableContent.swift", path: PathConstants.APIProtocolPath)
  }
}
