import ArgumentParser

var validFieldTypes = ["string", "int", "double", "bool", "dict", "date"]

struct Generate: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Tool used to generate Controllers/Models/Forms/Resources/Migrations",
        subcommands: [
            Scaffold.self
        ]
    )
}
