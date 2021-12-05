import ArgumentParser
import Foundation

final class APICommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Generate an API Representable version of a model"
    )
    
    @Argument(help: "")
    private var model: String
    
    func run() throws {
        FileHandler.createFileWithContents(
            "",
            fileName: "\(model)+APIRepresentable.swift",
            path: .ModelPath
        )
    }
}
