import ArgumentParser
import Foundation

struct Controller: ParsableCommand {
	static let configuration = CommandConfiguration(
		abstract: "Generate a controller with the given name"
	)
	
	@Option(help: "The name of the model to use for the controller")
	private var model: String?
	
	func run() throws {
		
	}
}