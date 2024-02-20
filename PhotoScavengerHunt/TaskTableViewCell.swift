import UIKit

class TaskTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var completionImageView: UIImageView!

    // Function to configure the cell with a Task
    func configure(with task: Task) {
        titleLabel.text = task.title
        completionImageView.image = task.isCompleted ? UIImage(named: "checkmark") : UIImage(named: "circle")
    }
}
