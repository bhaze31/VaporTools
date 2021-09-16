import ArgumentParser
import Foundation

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
