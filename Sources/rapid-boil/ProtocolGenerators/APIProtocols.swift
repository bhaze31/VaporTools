import Foundation

final class APIProtocols {
  var apiProtocol: String {
    return """
    import Vapor
    import Fluent

    protocol APIControllerProtocol: ControllerProtocol where Model: APIRepresentable {
        func index(_: Request) throws -> EventLoopFuture<Page<Model.IndexContent>>
        func get(_: Request) throws -> EventLoopFuture<Model.GetContent>
        func create(_: Request) throws -> EventLoopFuture<Model.GetContent>
        func update(_: Request) throws -> EventLoopFuture<Model.GetContent>
        func delete(_: Request) throws -> EventLoopFuture<HTTPStatus>
    }

    extension APIControllerProtocol {
        func index(_ req: Request) throws -> EventLoopFuture<Page<Model.IndexContent>> {
            Model.query(on: req.db)
                .paginate(for: req)
                .map { $0.map(\\.indexContent) }
        }

        func get(_ req: Request) throws -> EventLoopFuture<Model.GetContent> {
            try self.find(req)
                .map { $0.getContent }
        }

        func create(_ req: Request) throws -> EventLoopFuture<Model.GetContent> {
            try Model.PostContent.validate(content: req)

            let input = try req.content.decode(Model.PostContent.self)
            
            let model = Model()
            
            try model.create(input)
        
            return model.create(on: req.db)
                .transform(to: model.getContent)
        }

        func update(_ req: Request) throws -> EventLoopFuture<Model.GetContent> {
            try Model.PutContent.validate(content: req)

            let input = try req.content.decode(Model.PutContent.self)

            return try self.find(req)
                .flatMapThrowing { model -> Model in
                    try model.update(input)
                    return model
                }
                .flatMap { model in
                    model.update(on: req.db)
                        .transform(to: model.getContent)
                }
        }

        func delete(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
            try self.find(req)
                .flatMap { $0.delete(on: req.db) }
                .transform(to: .ok)
        }

        func boot(routes: RoutesBuilder) throws {
            routes.get(modelPathComponent, idPathComponent, use: get)
            routes.get(modelPathComponent, use: index)

            routes.post(modelPathComponent, use: create)
            routes.put(modelPathComponent, idPathComponent, use: update)
            routes.delete(modelPathComponent, idPathComponent, use: delete)
        }
    }
    """
  }

  var apiRepresentable: String {
    return """
    import Vapor

    protocol APIRepresentable: Encodable {
        associatedtype IndexContent: Content
        associatedtype GetContent: Content
        associatedtype PostContent: ValidatableContent
        associatedtype PutContent: ValidatableContent

        var indexContent: IndexContent { get }
        var getContent: GetContent { get }

        func create(_: PostContent) throws
        func update(_: PutContent) throws
    }
    """
  }

  var validatableContent: String {
    return """
    import Vapor

    protocol ValidatableContent: Content, Validatable {}

    extension ValidatableContent {
        static func validations(_ validations: inout Validations) {}
    }
    """
  }
}
