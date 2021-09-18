import ArgumentParser
import Foundation

var validFieldTypes = ["string", "int", "double", "bool", "dict", "date"]

func getTimestamp() -> String {    
    let formatter = DateFormatter()
    formatter.dateFormat = "YYYYMMddHHmmssSSS"
    return formatter.string(from: Date())
}

struct Generate: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Tool used to generate Controllers/Models/Forms/Resources/Migrations",
        subcommands: [
            Scaffold.self,
            Migration.self
        ]
    )
}
