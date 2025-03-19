import Foundation

class TaskInteractor: TaskInteractorProtocol {
    
    let coreDataManager = CoreDataManager.shared
    
    weak var delegate: TaskUpdaterDelegate?

    func saveTask(title: String, info: String, completion: @escaping () -> Void) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        let date = formatter.string(from: Date())

        coreDataManager.createTask(title: title, info: info, date: date, completed: false) {
            DispatchQueue.main.async {
                self.delegate?.didSaveTask()
            }
        }
    }

    func updateTask(oldTitle: String, oldInfo: String, title: String, info: String, completion: @escaping () -> Void) {
        guard let oldTask = coreDataManager.fetchTask(title: oldTitle, info: oldInfo) else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        let date = formatter.string(from: Date())

        coreDataManager.updateTask(taskID: oldTask.objectID, newTitle: title, newInfo: info, newDate: date, newCompleted: false) {
            DispatchQueue.main.async {
                self.delegate?.didSaveTask()
            }
        }
    }
}
