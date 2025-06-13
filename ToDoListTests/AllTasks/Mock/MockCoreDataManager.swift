

final class MockCoreDataManager: CoreDataManagerProtocol {
    var tasks: [Tasks] = []
    var isSaveContextCalled = false
    var isCreateTaskCalled = false

    func fetchTasks() -> [Tasks] {
        return tasks
    }

    func createTask(title: String, info: String, date: String, completed: Bool, completion: @escaping () -> Void) {
        isCreateTaskCalled = true
        completion()
    }

    func saveContext() {
        isSaveContextCalled = true
    }

    func deleteTask(title: String, info: String, completion: (() -> Void)?) {
        tasks.removeAll { $0.title == title && $0.info == info }
        completion?()
    }
}
