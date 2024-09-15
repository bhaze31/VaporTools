import ArgumentParser
import Foundation

final class ControllerCommand: ParsableCommand {
    static let _commandName: String = "controller"

	static let configuration = CommandConfiguration(
	    abstract: """
        Generate a controller with the given name. The name is assumed to be the model and a CRUD controller is generated.
        In addition to the CRUD methods, this will also generate views, unless a flag is passed to suppress creating the views.
        """
	)
    
    @Option(name: [.customShort("n"), .customLong("name")], help: "The name of the model")
    private var name: String
    
    @Flag(name: [.customLong("skip-views")], help: "Skip the creation of views for the model.")
    private var skipViews: Bool = false

    func run() throws {
        PrettyLogger.info("Generating a controller for \(name)")
        
        let controllerPath = PathGenerator.load(path: .Controller)
        
        FileHandler.createFolderUnlessExists(controllerPath)
        
        
    }
}
