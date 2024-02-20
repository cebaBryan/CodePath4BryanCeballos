import UIKit

class TasksTableViewController: UITableViewController {
    
    var tasks: [Task] = [
        Task(title: "Favorite Hiking Spot", description: "Capture a photo of your favorite hiking destination.", isCompleted: false, userQuestion: "What's a spot where you feel one with nature?"),
        Task(title: "Favorite Local Cafe", description: "Snap a picture of the cafe that's your escape for peace or a caffeine fix.", isCompleted: false, userQuestion: "Where do you find your coffee sanctuary in the hustle and bustle?"),
        Task(title: "Go-to Brunch Spot", description: "Take a photo of your go-to brunch spot. What makes it special for your weekends?", isCompleted: false, userQuestion: "What's your brunch oasis for a lazy weekend morning?"),
        Task(title: "Favorite Local Restaurant", description: "Photograph your favorite local restaurant. Share what dish transforms your meal into a celebration.", isCompleted: false, userQuestion: "Where do you dine to make an ordinary day extraordinary?")
    ]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskTableViewCell
        let task = tasks[indexPath.row]
        cell.titleLabel.text = task.title
        cell.completionImageView.image = task.isCompleted ? UIImage(named: "checkmark") : UIImage(named: "circle")
        return cell
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTaskDetail",
           let destinationVC = segue.destination as? TaskDetailViewController,
           let indexPath = tableView.indexPathForSelectedRow {
            let selectedTask = tasks[indexPath.row]
            destinationVC.task = selectedTask
            destinationVC.delegate = self // Set the delegate
        }
    }



}
extension TasksTableViewController: TaskDetailViewControllerDelegate {
    func taskDetailViewController(_ controller: TaskDetailViewController, didUpdateTask task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
}

