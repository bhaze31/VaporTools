import ArgumentParser
import Foundation

struct Generate: ParsableCommand {
  static let configuration = CommandConfiguration(
    abstract: "Tool used to generate Controllers/Models/Forms/Resources",
    subcommands: [Scaffold.self]
  )

  func run() throws {

  }
}

struct VaporTools: ParsableCommand {
  static let configuration = CommandConfiguration(
    abstract: "A Swift command line tool to manage Vapor applications",
    subcommands: [
      Generate.self,
      Initiate.self
    ]
  )

  init() {}
}

VaporTools.main()
