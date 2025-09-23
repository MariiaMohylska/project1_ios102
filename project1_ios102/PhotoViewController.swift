//
//  PhotoViewController.swift
//  project1_ios102
//
//  Created by Mariia Mohylska on 9/23/25.
//

import UIKit

class PhotoViewController: UIViewController {
    
    @IBOutlet weak var photoView: UIImageView!
    var task: Task!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoView.image = task?.image
    }
    
}
