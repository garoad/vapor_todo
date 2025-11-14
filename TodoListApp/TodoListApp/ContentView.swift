import SwiftUI

struct ContentView: View {
    @Environment(ViewModel.self) private var viewModel
    @State private var newTodoTitle = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // 새 Todo 입력 부분
                HStack {
                    TextField("새 할 일...", text: $newTodoTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                        if !newTodoTitle.isEmpty {
                            Task {
                                await viewModel.addTodo(title: newTodoTitle)
                                newTodoTitle = ""
                            }
                        }
                    }) {
                        Text("추가")
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
                
                // Todo 목록
                List {
                    ForEach(viewModel.todoList) { todo in
                        todoRow(todo)
                    }
                }
            }
            .navigationTitle("Todo List")
            .task {
                await viewModel.fetchTodos()
            }
        }
    }
    
    @ViewBuilder
    private func todoRow(_ todo: Todo) -> some View {
        HStack {
            Button(action: {
                Task {
                    await viewModel.toggleTodo(todo)
                }
            }) {
                Image(systemName: todo.complete ? "checkmark.square.fill" : "square")
                    .foregroundColor(todo.complete ? .green : .gray)
            }
            .buttonStyle(BorderlessButtonStyle())
            
            Text(todo.title)
                .strikethrough(todo.complete)
                .foregroundColor(todo.complete ? .gray : .primary)
            
            Spacer()
            
            Button(action: {
                Task {
                    await viewModel.deleteTodo(todo)
                }
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
    }
}

#Preview {
    ContentView().environment(ViewModel())
}
