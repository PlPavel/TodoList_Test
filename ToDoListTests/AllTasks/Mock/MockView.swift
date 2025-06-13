import Foundation
import UIKit
@testable import ToDoList

class MockView: AllTasksViewProtocol, TaskUpdaterDelegate {
    var reloadDataCalled = false
    var updateFooterCalled = false
    var updateFooterCount: Int?

    func reloadData() {
        reloadDataCalled = true
    }

    func updateFooter(count: Int) {
        updateFooterCalled = true
        updateFooterCount = count
    }

    func didSaveTask() {}
}
