import ArgumentParser
import Foundation

struct APIRepresentable: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Generate an API Representable version of a model"
    )
    
    @Argument(help: "")
    private var model: String
    
    func run() throws {
        FileGenerator.createFileWithContents(
            "",
            fileName: "\(model)+APIRepresentable.swift",
            path: .ModelPath
        )
    }
}
