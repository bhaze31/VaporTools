//
//  File.swift
//
//
//  Created by Brian Hasenstab on 5/18/21.
//

import Foundation

final class WebProtocols {
  var webControllerProtocol: String {
    return """

import Vapor
import Fluent

protocol WebControllerProtocol: ControllerProtocol where Model: WebRepresentable {
    associatedtype EditForm: Form

    var indexView: String { get }
    var getView: String { get }
    var editView: String { get }

    func beforeIndex(_: Request) throws -> EventLoopFuture<[Model]>
    func index(_ req: Request) throws -> EventLoopFuture<View>
    func get(_ req: Request) throws -> EventLoopFuture<View>

    func beforeRender(_ req: Request, form: EditForm) -> EventLoopFuture<Void>
    func render(_ req: Request, form: EditForm) -> EventLoopFuture<View>

    func createView(_ req: Request) throws -> EventLoopFuture<View>
    func beforeCreate(_ req: Request, model: Model, form: EditForm) -> EventLoopFuture<Model>
    func create(_ req: Request) throws -> EventLoopFuture<Response>

    func updateView(_ req: Request) throws -> EventLoopFuture<View>
    func beforeUpdate(_ req: Request, model: Model, form: EditForm) -> EventLoopFuture<Model>
    func update(_ req: Request) throws -> EventLoopFuture<Response>

    func beforeDelete(_ req: Request, model: Model) -> EventLoopFuture<Model>
    func delete(_ req: Request) throws -> EventLoopFuture<HTTPStatus>
}

extension WebControllerProtocol {
    var indexView: String  { \"\\(String(describing: Model.self))s/index\" }
    var getView: String { \"\\(String(describing: Model.self))s/get\" }
    var editView: String { \"\\(String(describing: Model.self))s/form\" }

    func beforeIndex(_ req: Request) throws -> EventLoopFuture<[Model]> {
        Model.query(on: req.db).all()
    }

    func index(_ req: Request) throws -> EventLoopFuture<View> {
        try self.beforeIndex(req).flatMap { results in
            let mappedResults = results.map(\\.viewContext)
            return req.view.render(self.indexView, IndexContext(mappedResults))
        }
    }

    func get(_ req: Request) throws -> EventLoopFuture<View> {
        try self.find(req).flatMap { model in
            req.view.render(self.getView, GetContext(model))
        }
    }

    func beforeRender(_ req: Request, form: EditForm) -> EventLoopFuture<Void> {
        req.eventLoop.future()
    }

    func render(_ req: Request, form: EditForm) -> EventLoopFuture<View> {
        self.beforeRender(req, form: form).flatMap {
            req.view.render(self.editView, EditContext(form))
        }
    }

    func createView(_ req: Request) throws -> EventLoopFuture<View> {
        return self.render(req, form: .init())
    }

    func beforeCreate(_ req: Request, model: Model, form: EditForm) -> EventLoopFuture<Model> {
        req.eventLoop.future(model)
    }

    func create(_ req: Request) throws -> EventLoopFuture<Response> {
        let form = try EditForm(req)

        return form.validate(req)
            .flatMap { isValid -> EventLoopFuture<Response> in
                guard isValid else {
                    return self.render(req, form: form).encodeResponse(for: req)
                }

                let model = Model()
                form.write(to: model as! EditForm.Model)
                return self.beforeCreate(req, model: model, form: form)
                    .flatMap { model in
                        return model.create(on: req.db)
                            .map { req.redirect(to: \"/\\(self.modelPathComponent)/\\(model.viewIdentifier)/edit\") }
                    }
            }
    }

    func updateView(_ req: Request) throws -> EventLoopFuture<View> {
        try self.find(req).flatMap { model in
            let form = EditForm()
            form.read(from: model as! EditForm.Model)

            return self.render(req, form: form)
        }
    }

    func beforeUpdate(_ req: Request, model: Model, form: EditForm) -> EventLoopFuture<Model> {
        req.eventLoop.future(model)
    }

    func update(_ req: Request) throws -> EventLoopFuture<Response> {
        let form = try EditForm(req)

        return form.validate(req).flatMap { isValid in
            guard isValid else {
                return self.render(req, form: form).encodeResponse(for: req)
            }

            do {
                return try self.find(req)
                    .flatMap { model in
                        self.beforeUpdate(req, model: model, form: form)
                    }
                    .flatMap { model in
                        form.write(to: model as! EditForm.Model)
                        return model.update(on: req.db).map {
                            form.read(from: model as! EditForm.Model)

                            return req.redirect(to: \"/\\(self.modelPathComponent)/\\(model.viewIdentifier)/edit\")
                        }
                    }
            } catch {
                return req.eventLoop.future(error: error)
            }
        }
    }

    func beforeDelete(_ req: Request, model: Model) -> EventLoopFuture<Model> {
        req.eventLoop.future(model)
    }

    func delete(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        try self.find(req)
            .flatMap { self.beforeDelete(req, model: $0) }
            .flatMap { model in
                model.delete(on: req.db).map { .ok }
            }
    }

    func boot(routes: RoutesBuilder) throws {
        routes.get(modelPathComponent, idPathComponent, use: get)
        routes.get(modelPathComponent, use: index)

        routes.get(modelPathComponent, \"new\", use: createView)
        routes.post(modelPathComponent, use: create)

        routes.get(modelPathComponent, idPathComponent, \"edit\", use: updateView)
        routes.put(modelPathComponent, idPathComponent, use: update)

        routes.delete(modelPathComponent, idPathComponent, use: delete)
    }
}
"""
  }

  var webRepresentable: String {
    return """
import Foundation

struct IndexContext<T: Encodable>: Encodable {
    let items: [T]

    init(_ items: [T]) {
        self.items = items
    }
}

struct GetContext<T: Encodable>: Encodable {
    let item: T

    init(_ item: T) {
        self.item = item
    }
}

struct EditContext<T: Encodable>: Encodable {
    let item: T

    init(_ item: T) {
        self.item = item
    }
}

public protocol WebRepresentable {
    associatedtype ViewContext: Encodable

    var viewContext: ViewContext { get }
    var viewIdentifier: String { get }
}
"""
  }
}
