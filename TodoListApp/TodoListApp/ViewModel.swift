import Foundation

@Observable final class ViewModel {
    private let baseURL = "http://localhost:8080/todos" // 서버 URL 설정
    
    var todoList: [Todo] = []
    
    func fetchTodos() async {
        guard let url = URL(string: "\(baseURL)/all") else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let todos = try JSONDecoder().decode([Todo].self, from: data)
            await MainActor.run {
                todoList = todos
            }
        } catch {
            print(error)
        }
    }
    
    func addTodo(title: String) async {
        guard let url = URL(string: baseURL) else { return }
        
        let newTodo = Todo(id: nil, title: title, complete: false)
        
        guard let encodedTodo = try? JSONEncoder().encode(newTodo) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = encodedTodo
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let createdTodo = try JSONDecoder().decode(Todo.self, from: data)
            await MainActor.run {
                todoList.append(createdTodo)
            }
        } catch {
            print("Error adding todo: \(error)")
        }
    }
    
    func toggleTodo(_ todo: Todo) async {
        guard let id = todo.id, let url = URL(string: "\(baseURL)/\(id)/toggle") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let updatedTodo = try JSONDecoder().decode(Todo.self, from: data)
            await MainActor.run {
                if let index = todoList.firstIndex(where: { $0.id == updatedTodo.id }) {
                    todoList[index] = updatedTodo
                }
            }
        } catch {
            print("Error toggling todo: \(error)")
        }
    }
    
    func deleteTodo(_ todo: Todo) async {
        guard let id = todo.id, let url = URL(string: "\(baseURL)/\(id)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        do {
            _ = try await URLSession.shared.data(for: request)
            await MainActor.run {
                todoList.removeAll(where: { $0.id == id })
            }
        } catch {
            print("Error deleting todo: \(error)")
        }
    }
}
