import Fluent
import Vapor

struct TodoController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let todos = routes.grouped("todos")

        todos.get(use: self.index)
        todos.get("all", use: self.all)
        todos.post(use: self.create)
        todos.group(":id") { todo in
            todo.delete(use: self.delete)
            todo.post(use: self.update)
            todo.post("toggle", use: self.toggle)
        }
    }

    @Sendable
    func index(req: Request) async throws -> View {
        let todos = try await Todo.query(on: req.db).all()
        return try await req.view.render("todo", ["todos": todos])
    }
    
    @Sendable
    func all(req: Request) async throws -> [TodoDTO] {
        try await Todo.query(on: req.db).all().map { $0.toDTO() }
    }

    @Sendable
    func create(req: Request) async throws -> TodoDTO {
        let todo = try req.content.decode(TodoDTO.self).toModel()

        try await todo.save(on: req.db)
        return todo.toDTO()
    }
    
    @Sendable
    func update(req: Request) async throws -> TodoDTO {
        guard let todo = try await Todo.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }

        todo.title = try req.content.decode(TodoDTO.self).toModel().title
        try await todo.update(on: req.db)
        return todo.toDTO()
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let todo = try await Todo.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }

        try await todo.delete(on: req.db)
        return .noContent
    }
    
    @Sendable
    func toggle(req: Request) async throws -> TodoDTO {
        guard let todo = try await Todo.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        todo.complete = !todo.complete
        try await todo.update(on: req.db)
        return todo.toDTO()
    }
}
