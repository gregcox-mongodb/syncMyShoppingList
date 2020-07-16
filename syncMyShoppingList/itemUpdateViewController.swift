//
//  itemUpdateControllerViewController.swift
//  syncMyShoppingList
//
//  Created by Greg Cox on 15/07/2020.
//  Copyright © 2020 Greg Cox. All rights reserved.
//

import UIKit
import RealmSwift

class itemUpdateViewController: UIViewController {

    @IBOutlet weak var itemField: UITextField!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var item:Item?
    var partitionValue: String = ""
    var realm:Realm? = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set value of item field to that passed from previous screen
        itemField.text = item?.name
        // Set focus on field
        self.itemField.becomeFirstResponder()
    }
    
    @IBAction func updateClicked(_ sender: Any) {
        // update Item
        try! self.realm?.write {
            item?.name = itemField.text!
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        // Cancel and return to previous screen
        self.dismiss(animated: true, completion: nil)
    }

}
