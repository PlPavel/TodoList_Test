import Foundation

class TaskPresenter: TaskPresenterProtocol {
    weak var view: TaskViewProtocol?
    var interactor: TaskInteractorProtocol?
    var router: TaskRouterProtocol?
    weak var delegate: TaskUpdaterDelegate?
    
    var oldTitle: String?
    var oldInfo: String?
    var isNewTask: Bool = true

    init(view: TaskViewProtocol, interactor: TaskInteractorProtocol, router: TaskRouterProtocol, oldTitle: String?, oldInfo: String?, isNewTask: Bool, delegate: TaskUpdaterDelegate?) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.oldTitle = oldTitle
        self.oldInfo = oldInfo
        self.isNewTask = isNewTask
        self.delegate = delegate
        
        self.interactor?.delegate = delegate
    }
    
    func viewDidLoad() {
        let title = oldTitle ?? ""
        let info = oldInfo ?? ""
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        let date = formatter.string(from: Date())

        view?.setTaskData(title: title, info: info, date: date)
    }
    
    func saveTask(title: String, info: String) {
        delegate?.didSaveTask()
        if isNewTask {
            interactor?.saveTask(title: title, info: info) {
                self.router?.navigateBack()
            }
        } else {
            interactor?.updateTask(oldTitle: oldTitle ?? "", oldInfo: oldInfo ?? "", title: title, info: info) {
                self.router?.navigateBack()
            }
        }
    }
}
