//
//  Models.swift
//  syncMyShoppingList
//
//  Created by Greg Cox on 15/07/2020.
//  Copyright © 2020 Greg Cox. All rights reserved.
//

import Foundation
import RealmSwift

typealias ProjectId = String

enum ItemStatus: String {
  case ToBuy
  case NoStock
  case Purchased
}

class User: Object {
    @objc dynamic var _id: ObjectId = ObjectId.generate()
    @objc dynamic var _partition: String = ""
    @objc dynamic var user_id: String = ""
    @objc dynamic var list: String = ""
    @objc dynamic var name: String = ""
    override static func primaryKey() -> String? {
        return "_id"
    }
}

class Item: Object {
    @objc dynamic var _id: ObjectId = ObjectId.generate()
    @objc dynamic var _partition: ProjectId = ""
    @objc dynamic var name = ""
    @objc dynamic var status = ItemStatus.ToBuy.rawValue
    @objc dynamic var created_by = ""
    @objc dynamic var created: Date = Date()
    @objc dynamic var updated_by: String? = ""
    @objc dynamic var updated: Date? = nil
    
    var statusEnum: ItemStatus {
        get {
            return ItemStatus(rawValue: status) ?? .ToBuy
        }
        set {
            status = newValue.rawValue
        }
    }

    override static func primaryKey() -> String? {
        return "_id"
    }

    convenience init(partition: String, name: String, created_by: String) {
        self.init()
        self._partition = partition
        self.name = name
        self.created_by = created_by
    }
}

