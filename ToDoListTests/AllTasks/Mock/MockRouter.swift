import Foundation
import UIKit
@testable import ToDoList

class MockRouter: AllTasksRouterProtocol {
    var navigateToAddTaskCalled = false
    var navigateToEditTaskCalled = false
    var navigateToAddTaskDelegate: TaskUpdaterDelegate?
    var navigateToEditTaskOldTitle: String?
    var navigateToEditTaskOldInfo: String?
    var navigateToEditTaskDelegate: TaskUpdaterDelegate?

    func navigateToAddTask(delegate: TaskUpdaterDelegate?) {
        navigateToAddTaskCalled = true
        navigateToAddTaskDelegate = delegate
    }

    func navigateToEditTask(oldTitle: String, oldInfo: String, delegate: TaskUpdaterDelegate?) {
        navigateToEditTaskCalled = true
        navigateToEditTaskOldTitle = oldTitle
        navigateToEditTaskOldInfo = oldInfo
        navigateToEditTaskDelegate = delegate
    }
}
