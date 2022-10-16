import ArgumentParser
import Foundation

final class ControllerCommand: ParsableCommand {
    static let _commandName: String = "controller"
	static let configuration = CommandConfiguration(
	    abstract: "Generate a controller with the given name. If no name is passed a blank controller is created with the boot command. Otherwise, the name is assumed to be the model and a CRUD controller is generated."
	)
    
    func run() throws {
        
    }
}
