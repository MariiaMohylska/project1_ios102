//
//  ViewController.swift
//  project1_ios102
//
//  Created by Mariia Mohylska on 9/23/25.
//

import UIKit

class TaskListViewController: UIViewController {
    
    @IBOutlet weak var emptyStateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var tasks = [Task]() {
        didSet {
            emptyStateLabel.isHidden = !tasks.isEmpty
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tasks = Task.mockedData
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailSegue" {
            if let detailViewController = segue.destination as? TaskDetailsViewController,
               let selectedIndex = tableView.indexPathForSelectedRow{
                let task = tasks[selectedIndex.row]
                
                detailViewController.task = task
            }
        }
    }

}

extension TaskListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskCell else {
            fatalError("Unable to dequeu Task Cell")
            }
        
        cell.configure(with: tasks[indexPath.row])
        
        return cell
    }
    
    
}

