import Foundation

final class ControllerGenerator {
    static func generateAPIController(for model: String) -> String {
        return """
        import Vapor

        final class \(model)APIController: APIControllerProtocol {
            typealias Model = \(model)
            
        }
        """
    }
    
    static func generateWebController(for model: String) -> String {
        return """
        import Vapor

        final class \(model)WebController: WebControllerProtocol {
            typealias EditForm = \(model)Form
            
            typealias Model = \(model)
        }
        """
    }
}
