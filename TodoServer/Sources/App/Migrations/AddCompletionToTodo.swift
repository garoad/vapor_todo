import Fluent

struct AddCompletionToTodo: AsyncMigration {
    // AsyncMigration 프로토콜 사용
    func prepare(on database: Database) async throws {
        try await database.schema("todos")
            .field("complete", .bool, .required, .sql(.default(false)))
            .update()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("todos")
            .deleteField("complete")
            .update()
    }
}
