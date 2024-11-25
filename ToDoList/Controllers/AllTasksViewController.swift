import UIKit

class AllTasksViewController: UIViewController {
    
    let coreDataManager = CoreDataManager.shared
    
    internal lazy var tasksSearchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    internal lazy var tasksTableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.showsVerticalScrollIndicator = false
        
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        
        return tableView
    }()
    
    internal var footerLabel: UILabel?
    
    internal lazy var footerView: UIView = {
        let footer = UIView()
        footer.translatesAutoresizingMaskIntoConstraints = false
        footer.backgroundColor = .systemGray6
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 11)
        label.textAlignment = .center
        
        self.footerLabel = label
        
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.image = UIImage(systemName: "square.and.pencil")
        icon.tintColor = .systemYellow
        icon.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addNewTask))
        icon.addGestureRecognizer(tapGesture)
        
        footer.addSubview(label)
        footer.addSubview(icon)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: footer.centerXAnchor),
            label.topAnchor.constraint(equalTo: footer.topAnchor, constant: 18),
            
            icon.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            icon.trailingAnchor.constraint(equalTo: footer.trailingAnchor, constant: -20),
            icon.heightAnchor.constraint(equalToConstant: 26),
            icon.widthAnchor.constraint(equalToConstant: 26)
        ])
        
        return footer
    }()

    @objc func addNewTask(){
        let vc = TaskViewController()
        vc.newElement = true
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    internal var filteredTasks: [Tasks] = []
    internal var isSearching: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        setupLayout()
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tasksTableView.reloadData()
        updateFooterLabel()
        title = "Задачи"
    }
    
    private func setupLayout() {
        view.addSubview(tasksSearchBar)
        view.addSubview(tasksTableView)
        view.addSubview(footerView)
        
        NSLayoutConstraint.activate([
            tasksSearchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            tasksSearchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tasksSearchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            tasksTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            tasksTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            tasksTableView.topAnchor.constraint(equalTo: tasksSearchBar.bottomAnchor, constant: 10),
            tasksTableView.bottomAnchor.constraint(equalTo: footerView.topAnchor),
            
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 83)
        ])
    }
    
    func updateFooterLabel(){
        footerLabel?.text = "\(coreDataManager.fetchTasks().count) Задач"
    }
    
    func fetchData(){
        if coreDataManager.fetchTasks().isEmpty {
            APICaller.shared.getTodoList { [weak self] result in
                switch result {
                case .success(let data):
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd/MM/yy"
                    let dateNow = formatter.string(from: Date())
                    
                    //при первом запуске ждет пока все данные из API будет загружены
                    DispatchQueue.main.async {
                        let group = DispatchGroup()
                        
                        for task in data.todos {
                            group.enter()
                            self?.coreDataManager.createTask(
                                title: "\(task.id) Задача",
                                info: task.todo,
                                date: dateNow,
                                completed: task.completed
                            ) {
                                group.leave()
                            }
                        }
                        
                        group.notify(queue: .main) {
                            self?.updateFooterLabel()
                            self?.tasksTableView.reloadData()
                        }
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}

extension AllTasksViewController: TaskUpdaterDelegate {
    func didSaveTask() {
        tasksTableView.reloadData()
        updateFooterLabel()
    }
}

extension AllTasksViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredTasks.count : coreDataManager.fetchTasks().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TaskTableViewCell else {
            return UITableViewCell()
        }
        let data = isSearching ? filteredTasks[indexPath.row] : coreDataManager.fetchTasks()[indexPath.row]
        cell.configure(task: data)
        return cell
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let task = coreDataManager.fetchTasks()[indexPath.row]
        let title = task.title ?? ""
        let info = task.info ?? ""
        
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            
            let editAction = UIAction(title: "Редактировать", image: UIImage(systemName: "square.and.pencil")) { [weak self] _ in
                let vc = TaskViewController()
                vc.modalPresentationStyle = .fullScreen
                vc.oldTitleTask = title
                vc.oldInfoTask = info
                vc.newElement = false
                vc.delegate = self
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            
            let shareAction = UIAction(title: "Поделиться", image: UIImage(systemName: "square.and.arrow.up")) { _ in

            }
            
            let deleteAction = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
                guard let self = self else { return }
                self.coreDataManager.deleteTask(title: title, info: info) {
                    self.tasksTableView.deleteRows(at: [indexPath], with: .automatic)
                    self.tasksTableView.reloadData()
                    self.updateFooterLabel()
                }
            }

            
            return UIMenu(title: "", children: [editAction, shareAction, deleteAction])
        }
        
        return configuration
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tasksTableView.deselectRow(at: indexPath, animated: true)
        let tasks = coreDataManager.fetchTasks()
        tasks[indexPath.row].completed.toggle()
        coreDataManager.saveContextToCompletedTask()
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
}

extension AllTasksViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredTasks = []
            tasksTableView.reloadData()
            return
        }
        
        isSearching = true
        
        let tasks = coreDataManager.fetchTasks()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let filtered = tasks.filter { ($0.title?.lowercased() ?? "").contains(searchText.lowercased()) }
            
            DispatchQueue.main.async {
                self.filteredTasks = filtered
                self.tasksTableView.reloadData()
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        filteredTasks = []
        searchBar.text = nil
        searchBar.resignFirstResponder()
        tasksTableView.reloadData()
    }
}

