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
    
    private lazy var backgroundContext: NSManagedObjectContext = {
        let context = appDelegate.persistentContainer.newBackgroundContext()
        return context
    }()

    func saveContextToCompletedTask() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    public func createTask(title: String, info: String, date: String, completed: Bool, completion: @escaping () -> Void) {
        backgroundContext.perform { [weak self] in
            guard let self = self else { return }
            
            guard let taskEntityDescription = NSEntityDescription.entity(forEntityName: "Tasks", in: self.backgroundContext) else { return }
            
            let task = Tasks(entity: taskEntityDescription, insertInto: self.backgroundContext)
            task.title = title
            task.info = info
            task.date = date
            task.completed = completed
            
            do {
                try self.backgroundContext.save()
                DispatchQueue.main.async {
                    self.appDelegate.saveContext()
                    completion()
                }
            } catch {
                print("Error saving background context: \(error)")
            }
        }
    }
    
    public func fetchTasks() -> [Tasks] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasks")
        do {
            return (try? context.fetch(fetchRequest) as? [Tasks]) ?? []
        }
    }
    
    public func fetchTask(title: String, info: String) -> Tasks? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasks")
        do {
            guard let tasks = try? context.fetch(fetchRequest) as? [Tasks] else { return nil }
            return tasks.first(where: { $0.title == title && $0.info == info})
        }
    }
    
    public func updateTask(taskID: NSManagedObjectID, newTitle: String, newInfo: String, newDate: String, newCompleted: Bool, completion: @escaping () -> Void) {
        backgroundContext.perform {
            do {
                if let task = try self.backgroundContext.existingObject(with: taskID) as? Tasks {
                    task.title = newTitle
                    task.info = newInfo
                    task.date = newDate
                    task.completed = newCompleted
                    
                    try self.backgroundContext.save()
                    
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            } catch {
                print("Failed to update task in background: \(error)")
            }
        }
    }
    
    public func deleteTask(title: String, info: String, completion: (() -> Void)? = nil) {
        backgroundContext.perform { [weak self] in
            guard let self = self else { return }

            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasks")
            fetchRequest.predicate = NSPredicate(format: "title == %@ AND info == %@", title, info)

            do {
                let tasks = try self.backgroundContext.fetch(fetchRequest) as? [Tasks]
                if let task = tasks?.first {
                    self.backgroundContext.delete(task)
                    try self.backgroundContext.save()
                }
                DispatchQueue.main.async {
                    completion?()
                }
            } catch {
                print("Failed to delete task: \(error)")
            }
        }
    }
}
