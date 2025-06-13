import XCTest
@testable import ToDoList
import CoreData
import UIKit


class AllTasksPresenterTests: XCTestCase {
    var presenter: AllTasksPresenter!
    var mockView: MockView!
    var mockInteractor: MockInteractor!
    var mockRouter: MockRouter!
    var persistentContainer: NSPersistentContainer!

    override func setUpWithError() throws {
        persistentContainer = {
            let container = NSPersistentContainer(name: "TodoList")
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
            container.loadPersistentStores { _, error in
                if let error = error {
                    fatalError("Failed to load test persistent store: \(error)")
                }
            }
            return container
        }()

        mockView = MockView()
        mockInteractor = MockInteractor()
        mockRouter = MockRouter()

        presenter = AllTasksPresenter()
        presenter.view = mockView
        presenter.interactor = mockInteractor
        presenter.router = mockRouter
    }

    override func tearDownWithError() throws {
        presenter = nil
        mockView = nil
        mockInteractor = nil
        mockRouter = nil
        persistentContainer = nil
    }

    func createTask(title: String?, info: String?, date: String?, completed: Bool, createdAt: Date? = nil) -> Tasks {
        let context = persistentContainer.viewContext
        let task = Tasks(context: context)
        task.title = title
        task.info = info
        task.date = date
        task.completed = completed
        task.createdAt = createdAt ?? Date()
        return task
    }

    func testRefreshData_CallsInteractorMethods() {
        presenter.refreshData()

        XCTAssertTrue(mockInteractor.loadInitialDataIfNeededCalled, "refreshData должен вызывать loadInitialDataIfNeeded")
        XCTAssertTrue(mockInteractor.fetchTasksCalled, "refreshData должен вызывать fetchTasks")
    }

    func testNumberOfTasks_ReturnsCorrectCount() {
        let task1 = createTask(title: "Task 1", info: "Info 1", date: "13/06/25", completed: false)
        let task2 = createTask(title: "Task 2", info: "Info 2", date: "13/06/25", completed: true)
        presenter.didFetchTasks([task1, task2])

        let count = presenter.numberOfTasks()

        XCTAssertEqual(count, 2, "numberOfTasks должен вернуть 2 задачи")
    }

    func testNumberOfTasks_WhenSearching_ReturnsFilteredCount() {
        let task1 = createTask(title: "Task 1", info: "Info 1", date: "13/06/25", completed: false)
        let task2 = createTask(title: "Other", info: "Info 2", date: "13/06/25", completed: true)
        presenter.didFetchTasks([task1, task2])
        presenter.search(text: "Task")

        let count = presenter.numberOfTasks()

        XCTAssertEqual(count, 1, "numberOfTasks должен вернуть 1 отфильтрованную задачу")
    }

    func testTaskAtIndex_ReturnsCorrectTask() {
        let task1 = createTask(title: "Task 1", info: "Info 1", date: "13/06/25", completed: false)
        let task2 = createTask(title: "Task 2", info: "Info 2", date: "13/06/25", completed: true)
        presenter.didFetchTasks([task1, task2])

        let task = presenter.task(at: 1)

        XCTAssertEqual(task.title, "Task 2", "task(at: 1) должен вернуть задачу с title 'Task 2'")
    }

    func testContextMenuConfiguration_CallsCorrectActions() {
        let task = createTask(title: "Task 1", info: "Info 1", date: "13/06/25", completed: false)
        presenter.didFetchTasks([task])
        let indexPath = IndexPath(row: 0, section: 0)

        let configuration = presenter.contextMenuConfiguration(for: indexPath)
        XCTAssertNotNil(configuration, "contextMenuConfiguration должен вернуть конфигурацию")

        let menu = presenter.createContextMenu(for: task)
        let actions = menu.children as? [UIAction]

        XCTAssertNotNil(menu, "Должно быть создано меню")
        XCTAssertEqual(actions?.count, 3, "Должно быть 3 действия в меню")
        XCTAssertEqual(actions?[0].title, "Редактировать", "Первое действие должно быть 'Редактировать'")
        XCTAssertEqual(actions?[0].image, UIImage(systemName: "square.and.pencil"), "Иконка действия 'Редактировать' должна быть корректной")
        XCTAssertEqual(actions?[1].title, "Поделиться", "Второе действие должно быть 'Поделиться'")
        XCTAssertEqual(actions?[1].image, UIImage(systemName: "square.and.arrow.up"), "Иконка действия 'Поделиться' должна быть корректной")
        XCTAssertEqual(actions?[2].title, "Удалить", "Третье действие должно быть 'Удалить'")
        XCTAssertEqual(actions?[2].image, UIImage(systemName: "trash"), "Иконка действия 'Удалить' должна быть корректной")
        XCTAssertEqual(actions?[2].attributes, .destructive, "Действие 'Удалить' должно иметь атрибут .destructive")
    }
    
    func testEditAction_TriggersNavigateToEditTask() {
        let task = createTask(title: "Task 1", info: "Info 1", date: "13/06/25", completed: false)
        presenter.didFetchTasks([task])

        mockRouter.navigateToEditTask(oldTitle: "Task 1", oldInfo: "Info 1", delegate: mockView)

        XCTAssertTrue(mockRouter.navigateToEditTaskCalled, "Должно вызываться navigateToEditTask")
        XCTAssertEqual(mockRouter.navigateToEditTaskOldTitle, "Task 1", "Должно передать правильный oldTitle")
        XCTAssertEqual(mockRouter.navigateToEditTaskOldInfo, "Info 1", "Должно передать правильный oldInfo")
        XCTAssertTrue(mockRouter.navigateToEditTaskDelegate as? MockView === mockView, "Должно передать правильный делегат")
    }

    func testDeleteAction_TriggersDeleteTask() {
        let task = createTask(title: "Task 1", info: "Info 1", date: "13/06/25", completed: false)
        presenter.didFetchTasks([task])

        mockInteractor.deleteTask(title: "Task 1", info: "Info 1")
        presenter.didDeleteTask()

        XCTAssertTrue(mockInteractor.deleteTaskCalled, "Должно вызываться deleteTask")
        XCTAssertEqual(mockInteractor.deleteTaskTitle, "Task 1", "Должно передать правильный title")
        XCTAssertEqual(mockInteractor.deleteTaskInfo, "Info 1", "Должно передать правильный info")
        XCTAssertTrue(mockInteractor.loadInitialDataIfNeededCalled, "didDeleteTask должен вызывать loadInitialDataIfNeeded")
        XCTAssertTrue(mockInteractor.fetchTasksCalled, "didDeleteTask должен вызывать fetchTasks")
        XCTAssertTrue(mockView.reloadDataCalled, "didDeleteTask должен вызывать reloadData")
    }
    
    func testSearch_FiltersTasksAndReloadsView() {
        let task1 = createTask(title: "Task 1", info: "Info 1", date: "13/06/25", completed: false)
        let task2 = createTask(title: "Other", info: "Info 2", date: "13/06/25", completed: true)
        presenter.didFetchTasks([task1, task2])

        presenter.search(text: "Task")

        XCTAssertEqual(presenter.numberOfTasks(), 1, "Должна быть 1 отфильтрованная задача")
        XCTAssertEqual(presenter.task(at: 0).title, "Task 1", "Отфильтрованная задача должна быть 'Task 1'")
        XCTAssertTrue(mockView.reloadDataCalled, "search должен вызывать reloadData")
    }

    func testCancelSearch_ResetsSearchAndReloadsView() {
        let task1 = createTask(title: "Task 1", info: "Info 1", date: "13/06/25", completed: false)
        presenter.didFetchTasks([task1])
        presenter.search(text: "Task")

        presenter.cancelSearch()

        XCTAssertEqual(presenter.numberOfTasks(), 1, "После отмены поиска должен быть доступ к исходным задачам")
        XCTAssertTrue(mockView.reloadDataCalled, "cancelSearch должен вызывать reloadData")
    }

    func testDidFetchTasks_UpdatesTasksAndView() {
        let task1 = createTask(title: "Task 1", info: "Info 1", date: "13/06/25", completed: false)
        let task2 = createTask(title: "Task 2", info: "Info 2", date: "13/06/25", completed: true)
        let expectation = XCTestExpectation(description: "Ожидание асинхронного вызова reloadData")

        presenter.didFetchTasks([task1, task2])

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.presenter.numberOfTasks(), 2, "Должно быть 2 задачи")
            XCTAssertTrue(self.mockView.reloadDataCalled, "didFetchTasks должен вызывать reloadData")
            XCTAssertTrue(self.mockView.updateFooterCalled, "didFetchTasks должен вызывать updateFooter")
            XCTAssertEqual(self.mockView.updateFooterCount, 2, "updateFooter должен получить правильное количество задач")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testDidTapAddTask_NavigatesToAddTask() {
        presenter.didTapAddTask()

        XCTAssertTrue(mockRouter.navigateToAddTaskCalled, "didTapAddTask должен вызывать navigateToAddTask")
        XCTAssertNotNil(mockRouter.navigateToAddTaskDelegate, "Должен быть передан делегат")
    }

    func testDidSelectTask_CallsToggleTaskCompletion() {
        let task1 = createTask(title: "Task 1", info: "Info 1", date: "13/06/25", completed: false)
        presenter.didFetchTasks([task1])

        presenter.didSelectTask(at: 0)

        XCTAssertTrue(mockInteractor.toggleTaskCompletionCalled, "didSelectTask должен вызывать toggleTaskCompletion")
        XCTAssertEqual(mockInteractor.toggleTaskCompletionIndex, 0, "Должен передать правильный индекс")
    }

    func testDidSelectTask_WhenSearching_CallsToggleTaskCompletionWithCorrectIndex() {
        let task1 = createTask(title: "Task 1", info: "Info 1", date: "13/06/25", completed: false)
        let task2 = createTask(title: "Other", info: "Info 2", date: "13/06/25", completed: true)
        presenter.didFetchTasks([task1, task2])
        presenter.search(text: "Task")

        presenter.didSelectTask(at: 0)

        XCTAssertTrue(mockInteractor.toggleTaskCompletionCalled, "didSelectTask должен вызывать toggleTaskCompletion")
        XCTAssertEqual(mockInteractor.toggleTaskCompletionIndex, 0, "Должен передать индекс 0 для Task 1")
    }

    func testDidDeleteTask_RefreshesDataAndReloadsView() {
        presenter.didDeleteTask()

        XCTAssertTrue(mockInteractor.loadInitialDataIfNeededCalled, "didDeleteTask должен вызывать loadInitialDataIfNeeded")
        XCTAssertTrue(mockInteractor.fetchTasksCalled, "didDeleteTask должен вызывать fetchTasks")
        XCTAssertTrue(mockView.reloadDataCalled, "didDeleteTask должен вызывать reloadData")
    }

    func testSearch_EmptyText_ClearsFilteredTasks() {
        let task1 = createTask(title: "Task 1", info: "Info 1", date: "13/06/25", completed: false)
        presenter.didFetchTasks([task1])
        presenter.search(text: "Task")

        presenter.search(text: "")

        XCTAssertEqual(presenter.numberOfTasks(), 1, "Пустой поиск должен вернуть исходное количество задач")
        XCTAssertTrue(mockView.reloadDataCalled, "search с пустым текстом должен вызывать reloadData")
    }

    func testSearch_NoMatches_ReturnsEmptyFilteredTasks() {
        let task1 = createTask(title: "Task 1", info: "Info 1", date: "13/06/25", completed: false)
        presenter.didFetchTasks([task1])

        presenter.search(text: "Nonexistent")

        XCTAssertEqual(presenter.numberOfTasks(), 0, "Поиск без совпадений должен вернуть 0 задач")
        XCTAssertTrue(mockView.reloadDataCalled, "search должен вызывать reloadData")
    }
}
