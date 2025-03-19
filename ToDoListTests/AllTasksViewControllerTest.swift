import XCTest
@testable import ToDoList

class AllTasksViewControllerTests: XCTestCase {
    
    var viewController: AllTasksViewController!
    
    override func setUpWithError() throws {
        super.setUp()
        viewController = AllTasksViewController()
        _ = viewController.view
    }
    
    override func tearDownWithError() throws {
        viewController = nil
        super.tearDown()
    }
    
    func testUIElementsAreConnected() {
        XCTAssertNotNil(viewController.tasksSearchBar, "tasksSearchBar не подключен.")
        XCTAssertNotNil(viewController.tasksTableView, "tasksTableView не подключен.")
        XCTAssertNotNil(viewController.footerView, "footerView не подключен.")
        XCTAssertNotNil(viewController.footerLabel, "footerLabel не подключен.")

    }
    
    func testInitialState() {
        XCTAssertEqual(viewController.isSearching, false, "isSearching должно быть false в начальном состоянии.")
        XCTAssertEqual(viewController.filteredTasks.count, 0, "filteredTasks должен быть пустым в начальном состоянии.")
    }
    

    func testSearchCancelButton() {
        viewController.searchBarCancelButtonClicked(viewController.tasksSearchBar)
        
        XCTAssertFalse(viewController.isSearching, "isSearching должно быть false после отмены поиска.")
        XCTAssertEqual(viewController.filteredTasks.count, 0, "filteredTasks должен быть пустым после отмены поиска.")
    }
}
