//
//  Item.swift
//  Up4
//
//  Created by Andres Posada Cortazar on 5/24/19.
//  Copyright © 2019 Andres Posada Cortazar. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false // variable when user clicks
    @objc dynamic var dateItemCreated: Date?
    @objc dynamic var deadLineDays: Int = 1 // variable on time
    @objc dynamic var itemDeadLine: Date?
    @objc dynamic var cellColour: String = "" // variable on time depending on deadLineDays
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
