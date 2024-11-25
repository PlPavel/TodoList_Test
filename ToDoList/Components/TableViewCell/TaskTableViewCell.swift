import UIKit

class TaskTableViewCell: UITableViewCell {
    
    private lazy var statusIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemYellow
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }()
    
    private lazy var taskTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.textColor = .lightGray
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    private func setupViews() {
        contentView.addSubview(statusIcon)
        contentView.addSubview(titleLabel)
        contentView.addSubview(taskTextLabel)
        contentView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([

            statusIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            statusIcon.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            statusIcon.widthAnchor.constraint(equalToConstant: 24),
            statusIcon.heightAnchor.constraint(equalToConstant: 48),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: statusIcon.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            taskTextLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            taskTextLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            taskTextLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: taskTextLabel.bottomAnchor, constant: 6),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(task: Tasks) {
        titleLabel.attributedText = nil
        titleLabel.text = task.title
        taskTextLabel.text = task.info
        dateLabel.text = task.date
        let isCompleted = task.completed
        
        if isCompleted {
            statusIcon.image = UIImage(systemName: "checkmark.circle")
            titleLabel.textColor = .lightGray
            taskTextLabel.textColor = .lightGray
            
            let attributeString = NSMutableAttributedString(string: titleLabel.text ?? "")
            attributeString.addAttribute(
                .strikethroughStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSRange(location: 0, length: attributeString.length)
            )
            titleLabel.attributedText = attributeString
        } else {
            statusIcon.image = UIImage(systemName: "circle")
            titleLabel.textColor = .label
            taskTextLabel.textColor = .label
        }
    }
}
