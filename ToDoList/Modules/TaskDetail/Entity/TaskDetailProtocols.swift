import Foundation

protocol TaskViewProtocol: AnyObject {
    func setTaskData(title: String, info: String, date: String)
}

protocol TaskPresenterProtocol: AnyObject {
    func viewDidLoad()
    func saveTask(title: String, info: String)
}

protocol TaskInteractorProtocol: AnyObject {
    var delegate: TaskUpdaterDelegate? { get set }
    func saveTask(title: String, info: String, completion: @escaping () -> Void)
    func updateTask(oldTitle: String, oldInfo: String, title: String, info: String, completion: @escaping () -> Void)
}

protocol TaskRouterProtocol: AnyObject {
    func navigateBack()
}
