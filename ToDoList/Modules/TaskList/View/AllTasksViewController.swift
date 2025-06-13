import UIKit


protocol AllTasksViewProtocol: AnyObject {
    func updateFooter(count: Int)
    func reloadData()
}

class AllTasksViewController: UIViewController {
    
    var presenter: AllTasksPresenterProtocol!
    
    internal lazy var tasksSearchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    internal lazy var tasksTableView: UITableView = {
        let tableView = UITableView()
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
        footerLabel = label
        
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.image = UIImage(systemName: "square.and.pencil")
        icon.tintColor = .systemYellow
        icon.isUserInteractionEnabled = true
        icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addNewTask)))
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        title = "Задачи"
        
        setupLayout()
        presenter.refreshData()
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
    
    @objc private func addNewTask() {
        presenter.didTapAddTask()
    }
}

// MARK: - AllTasksViewProtocol

extension AllTasksViewController: AllTasksViewProtocol, TaskUpdaterDelegate {
    func didSaveTask(){
        presenter.refreshData()
    }
    
    func reloadData() {
        tasksTableView.reloadData()
    }
    
    func updateFooter(count: Int) {
        footerLabel?.text = "\(count) Задач"
    }
}

// MARK: - TableView

extension AllTasksViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfTasks()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TaskTableViewCell else {
            return UITableViewCell()
        }
        let task = presenter.task(at: indexPath.row)
        cell.configure(task: task)
        return cell
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return presenter.contextMenuConfiguration(for: indexPath)
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tasksTableView.deselectRow(at: indexPath, animated: true)
        presenter.didSelectTask(at: indexPath.row)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - SearchBar

extension AllTasksViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.search(text: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        presenter.cancelSearch()
        searchBar.text = nil
        searchBar.resignFirstResponder()
    }
}
