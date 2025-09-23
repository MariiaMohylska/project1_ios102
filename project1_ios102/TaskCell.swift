//
//  TaskCell.swift
//  project1_ios102
//
//  Created by Mariia Mohylska on 9/23/25.
//
import UIKit

class TaskCell: UITableViewCell {
    
    @IBOutlet weak var completedIcon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(with task: Task) {
        titleLabel.textColor = task.isComplete ? .lightGray : .black
        titleLabel.text = task.title
        completedIcon.image = UIImage(systemName: task.isComplete ? "checkmark.circle.fill" : "circlebadge")?.withRenderingMode(.alwaysTemplate)
        
    }
}
