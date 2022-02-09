import ArgumentParser
import Foundation

final class ManualCommand: ParsableCommand {
    static let _commandName: String = "manual"

    static let configuration = CommandConfiguration(
        abstract: "The manual for Vapor Tools"
    )
    
    func run() throws {
        print("Here is how it works")
        print("Also other things")
    }
}
