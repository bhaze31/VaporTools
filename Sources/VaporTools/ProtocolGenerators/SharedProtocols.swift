import Foundation

final class SharedProtocols {
  var controllerProtocol: String {
    return """
import Vapor
import Fluent

protocol ControllerProtocol {
  associatedtype Model: Fluent.Model

  var idParamKey: String { get }
  var idPathComponent: PathComponent { get }
  var modelKey: String { get }
  var modelPathComponent: PathComponent { get }

  func find(_: Request) throws -> EventLoopFuture<Model>

  func boot(routes: RoutesBuilder) throws
}

extension ControllerProtocol {
    var idParamKey: String { \"id\" }
    var idPathComponent: PathComponent { .init(stringLiteral: \":\\(self.idParamKey)\") }
    var modelKey: String { Model.schema }
    var modelPathComponent: PathComponent { .init(stringLiteral: \"\\(self.modelKey)\") }

    func boot(routes: RoutesBuilder) throws {
        fatalError(\"Class with ControllerProtocol not conforming to boot: \\(String(describing: Model.self))\")
    }
}

extension ControllerProtocol where Model.IDValue == UUID {
    func find(_ req: Request) throws -> EventLoopFuture<Model> {
        guard let param = req.parameters.get(self.idParamKey), let id = UUID(uuidString: param) else {
            throw Abort(.badRequest)
        }

        return Model.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
    }
}

extension ControllerProtocol where Model.IDValue == Int {
  func find(req: Request) throws -> EventLoopFuture<Model> {
    guard let id = req.parameters.get(self.idParamKey),
      let intID = Int(id) else {
        throw Abort(.badRequest)
      }

    return Model.find(intID, on: req.db).unwrap(or: Abort(.notFound))
  }
}
"""
  }

  var formProtocol: String {
    return """
import Vapor
import Fluent

protocol Form: Encodable {
  associatedtype Model: Fluent.Model

  var id: String? { get set }

  init()
  init(_: Request) throws

  func write(to: Model)
  func read(from: Model)
  func validate(_: Request) -> EventLoopFuture<Bool>
}
"""
  }
}
