import UIKit

class TaskViewController: UIViewController {
    
    weak var delegate: TaskUpdaterDelegate?
    
    var oldTitleTask: String?
    var oldInfoTask: String?

    var newElement: Bool = true
    
    let coreDataManager = CoreDataManager.shared
    
    internal lazy var titleTask: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = .boldSystemFont(ofSize: 34)
        textField.placeholder = "Название"
        textField.text = oldTitleTask ?? ""
        
        return textField
    }()
    
    internal lazy var taskText: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .systemFont(ofSize: 16)
        textView.text = oldInfoTask ?? "Введите задачу"
        if textView.text == "Введите задачу" {
            textView.textColor = .lightGray
        }
        textView.delegate = self
        return textView
    }()
    
    internal lazy var dateOfTask: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = .systemFont(ofSize: 12)
        textField.textColor = .lightGray
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        let dateNow = formatter.string(from: Date())
        textField.text = dateNow
        textField.isUserInteractionEnabled = false
        return textField
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        navigationController?.navigationBar.topItem?.title = "Назад"
        navigationController?.navigationBar.tintColor = .systemYellow
        
        setupLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if titleTask.text?.isEmpty == false {
            saveTask()
        }
    }
    
    func setupLayout(){
        view.addSubview(titleTask)
        view.addSubview(taskText)
        view.addSubview(dateOfTask)
        
        NSLayoutConstraint.activate([
            titleTask.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleTask.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleTask.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            dateOfTask.leadingAnchor.constraint(equalTo: titleTask.leadingAnchor),
            dateOfTask.topAnchor.constraint(equalTo: titleTask.bottomAnchor, constant: 6),
            
            taskText.leadingAnchor.constraint(equalTo: titleTask.leadingAnchor, constant: -4),
            taskText.trailingAnchor.constraint(equalTo: titleTask.trailingAnchor),
            taskText.topAnchor.constraint(equalTo: dateOfTask.bottomAnchor, constant: 10),
            taskText.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            
        ])
    }
    
    func saveTask() {
        let title = titleTask.text ?? ""
        let info = taskText.text ?? ""
        let date = dateOfTask.text ?? ""
        if newElement {
            coreDataManager.createTask(title: title, info: info, date: date, completed: false) {
                DispatchQueue.main.async {
                    self.delegate?.didSaveTask()
                }
            }
        } else {
            guard let oldTask = coreDataManager.fetchTask(title: oldTitleTask ?? "", info: oldInfoTask ?? "") else {return}
            coreDataManager.updateTask(taskID: oldTask.objectID,
                                       newTitle: title,
                                       newInfo: info,
                                       newDate: date,
                                       newCompleted: false) {
                self.delegate?.didSaveTask()
            }
        }
    }
}

extension TaskViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if taskText.textColor == .lightGray {
            taskText.text = nil
            taskText.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if taskText.text.isEmpty {
            taskText.text = "Введите задачу"
            taskText.textColor = .lightGray
        }
    }
}
