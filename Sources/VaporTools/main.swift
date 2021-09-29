import ArgumentParser
import Foundation

struct VaporTools: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A Swift command line tool to manage Vapor applications",
        discussion: """
        vapor-tools is an opinionated library, and as such it makes certain assumptions about the configuration of your application. To learn the set up and concepts behind these opions, run `vapor-tools manual`.
        """,
        subcommands: [
            Manual.self,
            Initiate.self,
            Scaffold.self,
            Generate.self
        ]
    )

    init() {}
}

VaporTools.main()
