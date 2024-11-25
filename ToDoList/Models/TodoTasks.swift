import Foundation

struct TodoTasks: Codable {
    let todos: [Todo]
}

struct Todo: Codable {
    let id: Int
    let todo: String
    var completed: Bool
}
