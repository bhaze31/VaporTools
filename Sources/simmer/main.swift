import ArgumentParser
import Foundation

#warning("Add color to the discussion/commands")
struct Simmer: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A Swift command line tool to manage Vapor applications",
        discussion: """
        Simmer: A command line tool to easily generate models, controllers, migrations, and more for Vapor applications. Simmer uses a similar pattern to Rails, with inidividual calls for Models, Migrations, and Controllers, as well as the ability to Scaffold a full Model in one call.
        
        With Simmer, much of the boilerplate code of creating a Vapor application is abstracted away, making it easier to focus on the business logic of your application and not generating all the fields required to define your data.
        
        Simmer leans on other frameworks to make it easier for you to reason about your Controllers and Models, but these can be omitted using the provided commands along with a configuration file that is placed at the root of your directory. These libraries are:
        - AutoMigrator: Automatically have Vapor pick up Migrations without the need of muddying up your config file.
        - FormattedResponse: Library to have one route handle multiple response types, efficiently and easily.
        
        Simmer is an opinionated library, and as such it makes certain assumptions about the configuration of your application. To learn the set up and concepts behind these opions, run `simmer manual`.
        """,
        subcommands: [
            InitiateCommand.self,
            ScaffoldCommand.self,
            GenerateCommand.self
        ]
    )

    init() {}
}

// subcommands to add bak [
//     ManualCommand.self,
//     AuthenticationCommand.self
// ]

Simmer.main()
