//
//  Category.swift
//  Up4
//
//  Created by Andres Posada Cortazar on 5/24/19.
//  Copyright © 2019 Andres Posada Cortazar. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    //@objc dynamic var dateCreated: Date?
    //@objc dynamic var colour: String = ""
    let items = List<Item>()
}
