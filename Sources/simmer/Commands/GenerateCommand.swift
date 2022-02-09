import ArgumentParser
import Foundation

final class GenerateCommand: ParsableCommand {
    static let _commandName: String = "generate"

    static let configuration = CommandConfiguration(
        abstract: "Tool used to generate Controllers/Models/Forms/Resources/Migrations",
        subcommands: [
            MigrationCommand.self,
        ]
    )
}
