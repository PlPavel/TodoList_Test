import Foundation
import UIKit

protocol AllTasksPresenterProtocol: AnyObject {
    func refreshData()
    func didTapAddTask()
    func didSelectTask(at index: Int)
    func didFetchTasks(_ tasks: [Tasks])
    func numberOfTasks() -> Int
    func task(at index: Int) -> Tasks
    func search(text: String)
    func cancelSearch()
    func contextMenuConfiguration(for indexPath: IndexPath) -> UIContextMenuConfiguration?
    func didDeleteTask()

}

final class AllTasksPresenter: AllTasksPresenterProtocol {
    weak var view: AllTasksViewProtocol?
    var interactor: AllTasksInteractorProtocol?
    var router: AllTasksRouterProtocol?

    private var tasks: [Tasks] = []
    private var filteredTasks: [Tasks] = []
    private var isSearching = false

    func refreshData() {
        interactor?.loadInitialDataIfNeeded()
        interactor?.fetchTasks()
    }
    
    func numberOfTasks() -> Int {
        return isSearching ? filteredTasks.count : tasks.count
    }
    
    func task(at index: Int) -> Tasks {
        return isSearching ? filteredTasks[index] : tasks[index]
    }

    func contextMenuConfiguration(for indexPath: IndexPath) -> UIContextMenuConfiguration? {
        let task = isSearching ? filteredTasks[indexPath.row] : tasks[indexPath.row]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            return self.createContextMenu(for: task)
        }
    }

    func createContextMenu(for task: Tasks) -> UIMenu {
        let title = task.title ?? ""
        let info = task.info ?? ""

        let editAction = UIAction(title: "Редактировать", image: UIImage(systemName: "square.and.pencil")) { [weak self] _ in
            self?.router?.navigateToEditTask(oldTitle: title, oldInfo: info, delegate: self?.view as? TaskUpdaterDelegate)
        }

        let shareAction = UIAction(title: "Поделиться", image: UIImage(systemName: "square.and.arrow.up")) { _ in
            
        }

        let deleteAction = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
            self?.interactor?.deleteTask(title: title, info: info)
            self?.didDeleteTask()
        }

        return UIMenu(title: "", children: [editAction, shareAction, deleteAction])
    }

    
    func search(text: String) {
        if text.isEmpty {
            isSearching = false
            filteredTasks = []
        } else {
            isSearching = true
            filteredTasks = tasks.filter { $0.title?.lowercased().contains(text.lowercased()) ?? false }
        }
        view?.reloadData()
    }

    func cancelSearch() {
        isSearching = false
        filteredTasks = []
        view?.reloadData()
    }


    func didFetchTasks(_ tasks: [Tasks]) {
        self.tasks = tasks
        DispatchQueue.main.async {
            self.view?.reloadData()
            self.view?.updateFooter(count: tasks.count)
        }
    }


    func didTapAddTask() {
        router?.navigateToAddTask(delegate: view as? TaskUpdaterDelegate)
    }

    func didSelectTask(at index: Int) {
        if isSearching {
            let selectedTask = filteredTasks[index]
            if let actualIndex = tasks.firstIndex(where: { $0.title == selectedTask.title && $0.info == selectedTask.info }) {
                interactor?.toggleTaskCompletion(at: actualIndex)
            }
        } else {
            interactor?.toggleTaskCompletion(at: index)
        }
    }
    
    func didDeleteTask() {
        refreshData()
        view?.reloadData()
    }

}
