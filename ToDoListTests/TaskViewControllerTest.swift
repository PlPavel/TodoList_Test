import XCTest
@testable import ToDoList

class TaskViewControllerTests: XCTestCase {
    
    var viewController: TaskViewController!
    
    override func setUpWithError() throws {
        super.setUp()
        viewController = TaskViewController()
        _ = viewController.view
    }
    
    override func tearDownWithError() throws {
        viewController = nil
        super.tearDown()
    }
    
    func testUIElements() {
        XCTAssertNotNil(viewController.titleTask)
        XCTAssertNotNil(viewController.taskText)
        XCTAssertNotNil(viewController.dateOfTask)
    }
}
