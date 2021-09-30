import ArgumentParser
import Foundation

struct Manual: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "The manual for Vapor Tools"
    )
}
