import UIKit

protocol AllTasksRouterProtocol: AnyObject {
    func navigateToAddTask(delegate: TaskUpdaterDelegate?)
    func navigateToEditTask(oldTitle: String, oldInfo: String, delegate: TaskUpdaterDelegate?)
}

final class AllTasksRouter: AllTasksRouterProtocol {
    weak var viewController: UIViewController?

    static func createModule() -> UIViewController {
        let view = AllTasksViewController()
        let presenter = AllTasksPresenter()
        let interactor = AllTasksInteractor()
        let router = AllTasksRouter()

        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter
        router.viewController = view

        return view
    }

    func navigateToAddTask(delegate: TaskUpdaterDelegate?) {
        let taskDetailVC = TaskRouter.createModule(oldTitle: nil, oldInfo: nil, isNewTask: true, delegate: delegate)
        viewController?.navigationController?.pushViewController(taskDetailVC, animated: true)
    }
    
    func navigateToEditTask(oldTitle: String, oldInfo: String, delegate: TaskUpdaterDelegate?) {
        let editVC = TaskRouter.createModule(oldTitle: oldTitle, oldInfo: oldInfo, isNewTask: false, delegate: delegate)
        viewController?.navigationController?.pushViewController(editVC, animated: true)
    }


}
