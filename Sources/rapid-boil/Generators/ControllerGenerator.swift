import Foundation

final class ControllerGenerator {
    static func generateBlankAsyncController() -> String {
        return """
        import Vapor
        import Fluent
        
        final class Controller: ControllerProtocol {
            static let schema: String = ""

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
    
    static func generateModelProtocol() -> String {
        return """
        protocol ControllerModelProtocol: Model, AsyncResponseEncodable {
            func create(for: Request)
            func update(for: Request)
        }
        
        extension ControllerModelProtocol {
            func encodeResponse(for request: Request) async throws -> Response {
                let encoder = JSONEncoder()
                let data = try encoder.encode(self)
                
                return Response(body: Response.Body(data: data))
            }
        }
        """
    }

    static func generateControllerProtocol() -> String {
        // TODO: Add the ability to do API/Web only
        return """
        import Vapor
        import Fluent
        
        protocol ControllerProtocol: RouteCollection {
            associatedtype ControllerModel: ControllerModelProtocol
        
            func indexAPI(request: Request) async throws -> Page<ControllerModel>
        
            func index(request: Request) async throws -> View
        
            func showAPI(request: Request) async throws -> ControllerModel
        
            func show(request: Request) async throws -> View
        
            func createAPI(request: Request) async throws -> HTTPResponseStatus
        
            func create(request: Request) async throws -> View
        
            func updateAPI(request: Request) async throws -> HTTPResponseStatus
        
            func update(request: Request) async throws -> View
        
            func deleteAPI(request: Request) async throws -> HTTPResponseStatus
        
            func delete(request: Request) async throws -> View
        
            func find(request: Request) async throws -> ControllerModel
        }
        
        extension ControllerProtocol {
            var idParamKey: String { "id" }
            var idPathComponent: PathComponent { .init(stringLiteral: ":\\(self.idParamKey)") }
            var modelKey: String { ControllerModel.schema }
            var modelPathComponent: PathComponent { .init(stringLiteral: "\\(self.modelKey)") }
            
            func indexAPI(request: Request) async throws -> Page<ControllerModel> {
                return try await ControllerModel.query(on: request.db).paginate(for: request)
            }
            
            func index(request: Request) async throws -> View {
                let page = try await ControllerModel.query(on: request.db).paginate(for: request)
                
                return try await request.view.render("index", page)
            }
            
            func showAPI(request: Request) async throws -> ControllerModel {
                return try await find(request: request)
            }
            
            func show(request: Request) async throws -> View {
                let model = try await find(request: request)
                
                return try await request.view.render(modelKey, model)
            }
            
            func createAPI(request: Request) async throws -> HTTPResponseStatus {
                let model = ControllerModel()
                model.create(for: request)
                try await model.save(on: request.db)
                
                return .created
            }
            
            func create(request: Request) async throws -> View {
                let model = ControllerModel()
                model.create(for: request)
                try await model.save(on: request.db)
                return try await request.view.render(idParamKey)
            }
            
            func updateAPI(request: Request) async throws -> HTTPResponseStatus {
                let model = ControllerModel()
                model.update(for: request)
                try await model.update(on: request.db)
                
                return .accepted
            }
            
            func update(request: Request) async throws -> View {
                let model = ControllerModel()
                model.update(for: request)
                try await model.update(on: request.db)
                
                return try await request.view.render(idParamKey)
            }
            
            func deleteAPI(request: Request) async throws -> HTTPResponseStatus {
                return .noContent
            }
            
            func delete(request: Request) async throws -> View {
                let model = try await find(request: request)
                
                try await model.delete(on: request.db)
                
                return try await request.view.render(idParamKey)
            }
            
            func boot(routes: RoutesBuilder) throws {
                let modelRoutes = routes.grouped(modelPathComponent)
                modelRoutes.get(use: index)
                modelRoutes.get(idPathComponent, use: show)
                modelRoutes.get("new", use: create)
                modelRoutes.post(use: create)
                modelRoutes.get(idPathComponent, "edit", use: update)
                modelRoutes.put(idPathComponent, use: update)
                modelRoutes.delete(idPathComponent, use: delete)
                
                let apiRoutes = routes.grouped(["api", modelPathComponent])
                apiRoutes.get(use: indexAPI)
                apiRoutes.get(idPathComponent, use: showAPI)
                apiRoutes.post(use: createAPI)
                apiRoutes.put(idPathComponent, use: updateAPI)
                apiRoutes.delete(idPathComponent, use: deleteAPI)
            }
        }
        
        extension ControllerProtocol where ControllerModel.IDValue == UUID {
            func find(request: Request) async throws -> ControllerModel {
                guard let id = request.parameters.get(idParamKey), let uuid = UUID(uuidString: id) else {
                    throw Abort(.badRequest)
                }
                
                guard let model = try await ControllerModel.find(uuid, on: request.db) else {
                    throw Abort(.notFound)
                }
                
                return model
            }
        }
        
        extension ControllerProtocol where ControllerModel.IDValue == Int {
            func find(request: Request) async throws -> ControllerModel {
                guard let id = request.parameters.get(idParamKey), let intID = Int(id) else {
                    throw Abort(.badRequest)
                }
                
                guard let model = try await ControllerModel.find(intID, on: request.db) else {
                    throw Abort(.notFound)
                }
                
                return model
            }
        }
        """
    }
}
