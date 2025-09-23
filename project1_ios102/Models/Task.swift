//
//  Task.swift
//  project1_ios102
//
//  Created by Mariia Mohylska on 9/23/25.
//

import UIKit
import CoreLocation

class Task{
    let title: String
    let description: String
    var image: UIImage?
    var imageLocation: CLLocation?
    var isComplete: Bool {
        image != nil
    }
    
    init(title: String, description: String) {
        self.title = title
        self.description = description
    }
    
    func set(_ image: UIImage, with location: CLLocation) {
        self.image = image
        self.imageLocation = location
    }
}

extension Task {
    static var mockedData: [Task] {
        return [
            Task(title: "Try the new seasonal latte ☕,",
                 description: "Stop by Ritual or Blue Bottle and ask for their autumn special. Bonus points if it’s pumpkin-y!"),

            Task(title: "Visit the bookshop on Valencia 📚",
                 description: "Browse the staff picks table and grab something you wouldn’t normally read."),

            Task(title: "Call Grandma 👵",
                 description: "She’d love to hear about your week. Don’t forget to ask about her garden."),

            Task(title: "Evening yoga in the park 🧘",
                 description: "Golden Gate Park has a sunset session—bring your mat and a light sweater."),

            Task(title: "Restock the snack drawer 🍪",
                 description: "Trader Joe’s has those maple cookies in stock—grab a box (or two).")
        ]
    }
}
