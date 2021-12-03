import Foundation

final class ControllerGenerator {
    static func generateControllerProtocol() -> String {
        return """
        import Vapor
        import Fluent
        
        protocol ModelController: RouteCollection {
            associatedtype Model: Fluent.Model
            
            var idParamKey: String { get }
            var idPathComponent: PathComponent { get }
            var modelKey: String { get }
            var modelPathComponent: PathComponent { get }
            
            func find(req: Request) async throws -> Model
            
            func boot(routes: RoutesBuilder) throws
        }
        
        extension ModelController {
            var idParamKey: String { \"id\" }
            var idPathComponent: PathComponent { .init(stringLiteral: \":\\(self.idParamKey)\") }
            var modelKey: String { Model.schema }
            var modelPathComponent: PathComponent { .init(stringLiteral: \"\\(self.modelKey)\") }
            
            func boot(routes: RoutesBuilder) throws {
                fatalError(\"Class with ModelController not conforming to boot: \\(String(describing: Model.self))\")
            }
        }
        
        extension ModelController where Model.IDValue == UUID {
            func find(req: Request) async throws -> Model {
                guard let param = req.parameters.get(self.idParamKey), let id = UUID(uuidString: param) else {
                    throw Abort(.badRequest)
                }
        
                return try await Model.find(id, on: req.db).unwrap(or: Abort(.notFound)).get()
            }
        }
        
        extension ModelController where Model.IDValue == Int {
            func find(req: Request) async throws -> Model {
                guard let id = req.parameters.get(self.idParamKey), let intID = Int(id) else {
                    throw Abort(.badRequest)
                }
        
                return try await Model.find(intID, on: req.db).unwrap(or: Abort(.notFound)).get()
            }
        }
        """
    }
    
    static func generateBlankAsyncController() -> String {
        return """
        import Vapor
        import Fluent
        
        final class Controller: RouteCollection {
            static let schema: String = \"\"

            func boot(routes: RouteCollection) throws {
        
            }
        }
        """
    }
    
    static func generateAsyncWebController(for model: String, withAuth: Bool = false) -> String {
        return """
        import Vapor
        import Fluent
        
        final class \(model)Controller: RouteCollection {
            static let schema: String = \"\(model.toCamelCase().pluralize())\"
        
            func index<Model: \(model)>(request: Request) async throws -> Page<Model> {
                return try await Model.query(on: request.db).paginate(for: request)
            }
        
            func boot(routes: RouteCollection) {
                routes.get('/
            }
        }
        """
    }
    
    static func generateAsyncController(for model: String, name: String?) -> String {
        return """
        import Vapor
        import Fluent
        
        final class \(name ?? model)Controller: ModelController {
            typealias Model = \(model)
            
            func index(req: Request) async throws -> Page<Model> {
                return async Model.query(on: req.db).paginate(for: req)
            }
            
            func get(req: Request) async throws -> Model {
                
            }
        }
        
        """
    }
    
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
