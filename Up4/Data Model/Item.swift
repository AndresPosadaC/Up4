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
    @objc dynamic var done: Bool = false
    @objc dynamic var dateItemCreated: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
