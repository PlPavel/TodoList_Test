import Foundation

protocol AllTasksInteractorProtocol: AnyObject {
    func fetchTasks()
    func loadInitialDataIfNeeded()
    func toggleTaskCompletion(at index: Int)
    func deleteTask(title: String, info: String)
}

final class AllTasksInteractor: AllTasksInteractorProtocol {
    weak var presenter: AllTasksPresenterProtocol?
    let coreDataManager = CoreDataManager.shared

    func fetchTasks() {
        let tasks = coreDataManager.fetchTasks()
        presenter?.didFetchTasks(tasks)
    }

    func loadInitialDataIfNeeded() {
        if coreDataManager.fetchTasks().isEmpty {
            APICaller.shared.getTodoList { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd/MM/yy"
                    let dateNow = formatter.string(from: Date())

                    DispatchQueue.main.async {
                        for task in data.todos {
                            self.coreDataManager.createTask(
                                title: "\(task.id) Задача",
                                info: task.todo,
                                date: dateNow,
                                completed: task.completed
                            ) {}
                        }
                        self.fetchTasks()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }

    func toggleTaskCompletion(at index: Int) {
        let tasks = coreDataManager.fetchTasks()
        tasks[index].completed.toggle()
        coreDataManager.saveContext()
        presenter?.didFetchTasks(tasks)
    }

    func deleteTask(title: String, info: String) {
        coreDataManager.deleteTask(title: title, info: info) { [weak self] in
            self?.presenter?.didDeleteTask()
        }
    }

}
