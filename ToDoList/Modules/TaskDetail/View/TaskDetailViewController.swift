import UIKit

class TaskDetailViewController: UIViewController, UITextViewDelegate {
    
    var presenter: TaskPresenterProtocol?

    lazy var titleTask: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = .boldSystemFont(ofSize: 34)
        textField.placeholder = "Название"
        return textField
    }()
    
    lazy var taskText: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .systemFont(ofSize: 16)
        textView.delegate = self
        return textView
    }()
    
    lazy var dateOfTask: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = .systemFont(ofSize: 12)
        textField.textColor = .lightGray
        textField.isUserInteractionEnabled = false
        return textField
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        presenter?.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter?.saveTask(title: titleTask.text ?? "", info: taskText.text ?? "")
    }
    
    func setupLayout() {
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
}

extension TaskDetailViewController: TaskViewProtocol {
    func setTaskData(title: String, info: String, date: String) {
        titleTask.text = title
        taskText.text = info
        dateOfTask.text = date
    }
}
