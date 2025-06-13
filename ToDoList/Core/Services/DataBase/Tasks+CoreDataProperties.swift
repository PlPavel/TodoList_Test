import Foundation
import CoreData

@objc(Tasks)
public class Tasks: NSManagedObject {}

extension Tasks {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tasks> {
        return NSFetchRequest<Tasks>(entityName: "Tasks")
    }

    @NSManaged public var title: String?
    @NSManaged public var info: String?
    @NSManaged public var date: String?
    @NSManaged public var completed: Bool
    @NSManaged public var createdAt: Date?
    
}

extension Tasks : Identifiable {}
