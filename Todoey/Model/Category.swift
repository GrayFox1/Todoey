//
//  Category.swift
//  Todoey
//
//  Created by André Vicente Pessanha on 25/02/2018.
//  Copyright © 2018 André Vicente Pessanha. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object {
    @objc dynamic var name : String = ""
    let items = List<Item>()
    
}
