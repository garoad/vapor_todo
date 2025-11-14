import SwiftUI

@main
struct TodoListAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environment(ViewModel())
        }
    }
}
