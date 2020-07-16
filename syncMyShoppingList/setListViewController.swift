//
//  ViewContoller2.swift
//  syncMyShoppingList
//
//  Created by Greg Cox on 14/07/2020.
//  Copyright © 2020 Greg Cox. All rights reserved.
//

import UIKit
import RealmSwift

class setListViewController: UIViewController {

    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var listNameField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func setLoading(_ loading: Bool) {
        if loading {
            activityIndicator.startAnimating();
            errorLabel.text = "";
        } else {
            activityIndicator.stopAnimating();
        }
        listNameField.isEnabled = !loading
        continueButton.isEnabled = !loading
    }
    
    @IBAction func continuePressed(_ sender: Any) {
        // Show loader
        setLoading(true)
        // Trim input
        let listNameFieldValue = listNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check input has been provided
        if (listNameFieldValue != "") {
            // call Realm function "setUserList" to set list name
            app.functions.setUserList([.string(listNameField.text!)]) { _ , error in
               DispatchQueue.main.sync {
                // Hide Loader
                self.setLoading(false);
                
                // Check for error
                   guard error == nil else {
                        self.errorLabel.text = error?.localizedDescription
                        return
                   }
                
                // get current Realm User object
                let user = app.currentUser()
                // Configure Realm User Object with Partition Value (List ID)
                let projectRealm = try! Realm(configuration: user!.configuration(partitionValue: self.listNameField.text!))
                // Navigate to shopping list screen, passing the Realm
                let vc  = self.storyboard?.instantiateViewController(withIdentifier: "shoppingListViewController") as! shoppingListViewController
                vc.realm = projectRealm
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated:true)
                   
               }
           }
        } else {
            errorLabel.text = "List ID must be supplied to continue"
        }
    }

}
