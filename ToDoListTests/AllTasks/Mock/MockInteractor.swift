import Foundation
import UIKit
@testable import ToDoList


class MockInteractor: AllTasksInteractorProtocol {
    var loadInitialDataIfNeededCalled = false
    var fetchTasksCalled = false
    var toggleTaskCompletionCalled = false
    var toggleTaskCompletionIndex: Int?
    var deleteTaskCalled = false
    var deleteTaskTitle: String?
    var deleteTaskInfo: String?

    func fetchTasks() {
        fetchTasksCalled = true
    }

    func loadInitialDataIfNeeded() {
        loadInitialDataIfNeededCalled = true
    }

    func toggleTaskCompletion(at index: Int) {
        toggleTaskCompletionCalled = true
        toggleTaskCompletionIndex = index
    }

    func deleteTask(title: String, info: String) {
        deleteTaskCalled = true
        deleteTaskTitle = title
        deleteTaskInfo = info
    }
}
