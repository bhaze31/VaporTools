import ArgumentParser
import Foundation

final class ControllerCommand: ParsableCommand {
	static let configuration = CommandConfiguration(
	    abstract: "Generate a controller with the given name. If no name is passed a blank controller is created with the boot command. Otherwise, the name is assumed to be the model and a CRUD controller is generated."
	)
	
	@Option(help: "The name of the model to use for the controller")
	private var model: String?
	
	func run() throws {
        if let _model = model {
            // TODO: Add a model type controller
            let controller = ControllerGenerator.generateAsyncController(for: _model)
            
            FileHandler.createFileWithContents(
                controller,
                fileName: "\(_model)Controller.swift",
                path: .ControllerPath
            )

            return
        }
        
        // TODO: Add a blank controller
        let timestamp = getTimestamp()
        
        let controller = ControllerGenerator.generateAsyncController()
        
        FileHandler.createFileWithContents(
            controller,
            fileName: "\(timestamp)Controller.swift",
            path: .ControllerPath
        )
	}
}
