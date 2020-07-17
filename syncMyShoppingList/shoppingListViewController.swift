//
//  shoppingListViewController.swift
//  syncMyShoppingList
//
//  Created by Greg Cox on 14/07/2020.
//  Copyright © 2020 Greg Cox. All rights reserved.
//

import UIKit
// DEMO_COMMENT_1
import RealmSwift

class shoppingListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var partitionValue: String?
    var realm:Realm? = try! Realm()
    var items: Results<Item>? = nil
    let user = app.currentUser()
    var user_name:String = ""
    let formatter1 = DateFormatter()
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var itemField: UITextField!
    @IBOutlet weak var addItemButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var userLabel: UILabel!
    
    var notificationToken: NotificationToken?
    
    func initialiseData() {
        
        // Set User label
        guard let userData = user?.customData?["name"], let name = userData?.stringValue! else {return}
        user_name = name
        let boldText = "Logged In: "
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]
        let attributedString = NSMutableAttributedString(string:boldText, attributes:attrs)
        
        let normalText = name
        let attrs2 = [NSAttributedString.Key.font : UIFont.italicSystemFont(ofSize: 12)]
        let normalString = NSMutableAttributedString(string:normalText, attributes:attrs2)
        
        attributedString.append(normalString)
        userLabel.attributedText = attributedString
        
        // Sync Realm Configuration
        guard let syncConfiguration = realm?.configuration.syncConfiguration else {
            fatalError("Sync configuration not found! Realm not opened with sync?");
        }
        
        // Set Partition Value
        partitionValue = syncConfiguration.partitionValue.stringValue!
        
        // Access all items in the realm.
        // Only items with the "list" as the partition key value will be in the realm.
        items = realm?.objects(Item.self)
        
        // DEMO_COMMENT_7
        // Watch for changes
        notificationToken = items?.observe { [weak self] (changes) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView.
                tableView.beginUpdates()
                // It's important to be sure to always update a table in this order:
                // deletions, insertions, then updates. Otherwise, you could be unintentionally
                // updating at the wrong index!
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0) }),
                    with: .automatic)
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                    with: .automatic)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                    with: .automatic)
                tableView.endUpdates()
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialiseData()
    }
    
    @IBAction func addItem(_ sender: Any) {
        // Init error label
        errorLabel.text = ""
        
        // Trim item field
        itemField.text = itemField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check item has been provided
        if (itemField.text == "") {
            // Item name blank - show error
            errorLabel.text = "Please enter a Shopping List item and press Add"
        } else {
            // Set Item object
            let item = Item(partition: self.partitionValue!, name: itemField.text!, created_by: user_name ?? "New Task")
            
            // Get current Realm items
            let realmItems = realm?.objects(Item.self)
            
            // Loop through Real Items checking if new Item is a duplicate of an existing
            for realmItem in realmItems! {
                if(realmItem.name.uppercased() == item.name.uppercased()) {
                    errorLabel.text = "Shopping list item already exists"
                    return
                }
            }
                        
            // DEMO_COMMENT_6
            // Any writes to the Realm must occur in a write block.
            try! realm?.write {
                // Add the Item to the Realm
                realm?.add(item)
                itemField.text = ""
            }
        }
    }
    
    // function allows swipe and delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        // User can swipe to delete items.
        guard let item = items?[indexPath.row] else { return }

        // All modifications to a realm must happen in a write block.
        // DEMO_COMMENT_6
        try! realm?.write {
            // Delete the Task.
            realm?.delete(item)
        }
    }
    
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let item = self.items?[indexPath.row]
        var actions = [UIContextualAction]()
        
        // if item status is not "To Buy"
        if (item?.statusEnum != .ToBuy) {
            // Add swipe right action to set status to "To Buy"
            let action = UIContextualAction(style: .normal, title:  " To Buy ", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                    
                    // DEMO_COMMENT_6
                    try! self.realm?.write {
                        item?.statusEnum = .ToBuy
                        item?.updated_by = self.user_name
                        item?.updated = Date()

                    }
                    success(true)
                })
                //action.image = UIImage(named: "basket1")
                action.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
                actions.append(action)
                
        }
        
        // if item status is not "Purchased"
        if (item?.statusEnum != .Purchased) {
            // Add swipe right action to set status to "Purchased"
            let action = UIContextualAction(style: .normal, title:  " Purchased ", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                    
                    // DEMO_COMMENT_6
                    try! self.realm?.write {
                        item?.statusEnum = .Purchased
                        item?.updated_by = self.user_name
                        item?.updated = Date()
                    }
                    success(true)
                })
                //action.image = UIImage(named: "")
                action.backgroundColor = #colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1)
                actions.append(action)
                
        }
        
        // if item status is not "No Stock"
        if (item?.statusEnum != .NoStock) {
            // Add swipe right action to set status to "No Stock"
            let action = UIContextualAction(style: .normal, title:  " No Stock ", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                    
                    // DEMO_COMMENT_6
                    try! self.realm?.write {
                        item?.statusEnum = .NoStock
                        item?.updated_by = self.user_name
                        item?.updated = Date()
                    }
                    success(true)
                })
                //action.image = UIImage(named: "out-of-stock")
                action.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
                actions.append(action)
                
        }
        
        return UISwipeActionsConfiguration(actions: actions)
    }
    
    // function displays action menu on click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // User selected an item in the table. We will present a list of actions that the user can perform on this task.
        let item = items?[indexPath.row]

        // Create the AlertController and add its actions.
        let actionSheet: UIAlertController = UIAlertController(title: item?.name, message: "Select an action", preferredStyle: .actionSheet)
        
        // Add Cancel Option
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                // Cancels Action - no further code required
        })
        
        // Amend Action Implementation
        actionSheet.addAction(UIAlertAction(title: "Amend", style: .destructive) { _ in
            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "itemUpdateViewController") as! itemUpdateViewController
            vc.modalPresentationStyle = .fullScreen
            vc.realm = self.realm
            vc.item = item
            self.present(vc, animated:true)
        })

// Removed as options moved to swipe right - Leaving for reference
//        // If Item is not in "Not Purchased" state then allow option to set to this
//        if (item?.statusEnum != .ToBuy) {
//            actionSheet.addAction(UIAlertAction(title: "Not Purchased", style: .default) { _ in
//                // Any modifications to managed objects must occur in a write block.
//                // When we modify the Items's state, that change is automatically reflected in the realm.
//                try! self.realm?.write {
//                    item?.statusEnum = .ToBuy
//                    }
//                })
//        }
//
//        // If Item is not in "Out of Stock" state then allow option to set to this
//        if (item?.statusEnum != .NoStock) {
//            actionSheet.addAction(UIAlertAction(title: "Out of Stock", style: .default) { _ in
//                // Any modifications to managed objects must occur in a write block.
//                // When we modify the Items's state, that change is automatically reflected in the realm.
//                try! self.realm?.write {
//                    item?.statusEnum = .NoStock
//                    }
//                })
//        }
//
//        // If Item is not in "Purchasd" state then allow option to set to this
//        if (item?.statusEnum != .Purchased) {
//            actionSheet.addAction(UIAlertAction(title: "Purchased", style: .default) { _ in
//                // Any modifications to managed objects must occur in a write block.
//                // When we modify the Items's state, that change is automatically reflected in the realm.
//                try! self.realm?.write {
//                        item?.statusEnum = .Purchased
//                    }
//                })
//        }

        // Show the actions list.
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    deinit {
        // Always invalidate any notification tokens when you are done with them.
        notificationToken?.invalidate()
    }
    
    // function reurns cell to display
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // set item object
        let item = items?[indexPath.row]
        // set cell for display
        let cell = tableView.dequeueReusableCell(withIdentifier: "myProtoCell") as! tableCell
        // set item name
        let item_name = item!.name as String
        // set cell label text
        cell.cellLbl.text = "\(item_name)"
        // set date format for display
        formatter1.dateFormat = "HH:mm E, d MMM y"

        // switch determines what to display in cell
        switch (item?.statusEnum) {
        case .ToBuy:
            cell.cellImg.image = UIImage(named:"basket1")
            let created = formatter1.string(from:(item?.created)!)
            cell.cellLbl2.text = "- To Buy"
            cell.cellLbl2.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            cell.cellLbl3.text = "\((item?.created_by)!), \(created)"
            cell.cellLbl3.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        case .NoStock:
            cell.cellImg.image = UIImage(named:"basket2")
            let updated = formatter1.string(from:(item?.created)!)
            cell.cellLbl2.text = "- Out of Stock"
            cell.cellLbl2.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            cell.cellLbl3.text = "\((item?.updated_by)!), \(updated)"
            cell.cellLbl3.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        case .Purchased:
            cell.cellImg.image = UIImage(named:"basket3")
            let updated = formatter1.string(from:(item?.created)!)
            cell.cellLbl2.text = "- Purchased"
            cell.cellLbl2.textColor = #colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1)
            cell.cellLbl3.text = "\((item?.updated_by)!), \(updated)"
            cell.cellLbl3.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        case .none:
            cell.cellImg = nil
        }
        return cell
    }
    
    // function reurns item count
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    // DEMO_COMMENT_8
    //Logout
    @IBAction func logOut(_ sender: Any) {
        app.logOut(completion: { (error) in
            DispatchQueue.main.sync {
                // Return to Login Screen
                let vc  = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated:true)
            }
        })
    }
    
}
