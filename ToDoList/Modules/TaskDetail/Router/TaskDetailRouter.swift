import UIKit

class TaskRouter: TaskRouterProtocol {
    
    weak var viewController: UIViewController?
    
    weak var delegate: TaskUpdaterDelegate?
    
    static func createModule(oldTitle: String?, oldInfo: String?, isNewTask: Bool, delegate: TaskUpdaterDelegate?) -> TaskDetailViewController {
        let view = TaskDetailViewController()
        let interactor = TaskInteractor()
        let router = TaskRouter()
        let presenter = TaskPresenter(view: view, interactor: interactor, router: router, oldTitle: oldTitle, oldInfo: oldInfo, isNewTask: isNewTask, delegate: delegate)

        view.presenter = presenter
        router.viewController = view
        router.delegate = delegate

        return view
    }
    
    func navigateBack() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
