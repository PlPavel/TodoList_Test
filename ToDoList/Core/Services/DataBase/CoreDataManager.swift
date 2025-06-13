import Foundation
import UIKit
import CoreData

public final class CoreDataManager: NSObject {

    public static let shared = CoreDataManager()
    private override init() {}

    private var appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }

    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }

    // MARK: - Save

    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Unresolved error: \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // MARK: - Create

    public func createTask(title: String, info: String, date: String, completed: Bool, completion: @escaping () -> Void) {
        let task = Tasks(context: context)
        task.title = title
        task.info = info
        task.date = date
        task.completed = completed
        task.createdAt = Date()

        saveContext()
        completion()
    }

    // MARK: - Read

    public func fetchTasks() -> [Tasks] {
        let fetchRequest = NSFetchRequest<Tasks>(entityName: "Tasks")
        
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Fetch error: \(error)")
            return []
        }
    }

    public func fetchTask(title: String, info: String) -> Tasks? {
        let fetchRequest = NSFetchRequest<Tasks>(entityName: "Tasks")
        fetchRequest.predicate = NSPredicate(format: "title == %@ AND info == %@", title, info)
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Fetch single task error: \(error)")
            return nil
        }
    }

    // MARK: - Update

    public func updateTask(taskID: NSManagedObjectID, newTitle: String, newInfo: String, newDate: String, newCompleted: Bool, completion: @escaping () -> Void) {
        do {
            if let task = try context.existingObject(with: taskID) as? Tasks {
                task.title = newTitle
                task.info = newInfo
                task.date = newDate
                task.completed = newCompleted

                saveContext()
                completion()
            }
        } catch {
            print("Update error: \(error)")
        }
    }

    // MARK: - Delete

    public func deleteTask(title: String, info: String, completion: (() -> Void)? = nil) {
        let fetchRequest = NSFetchRequest<Tasks>(entityName: "Tasks")
        fetchRequest.predicate = NSPredicate(format: "title == %@ AND info == %@", title, info)

        do {
            if let task = try context.fetch(fetchRequest).first {
                context.delete(task)
                saveContext()
            }
            completion?()
        } catch {
            print("Delete error: \(error)")
        }
    }
}
