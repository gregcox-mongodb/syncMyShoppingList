//
//  ViewController.swift
//  syncMyShoppingList
//
//  Created by Greg Cox on 14/07/2020.
//  Copyright © 2020 Greg Cox. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var ListDetailStackView: UIStackView!
    @IBOutlet weak var listNameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Set focus on username field
        self.usernameField.becomeFirstResponder()
    }

    func setLoading(_ loading: Bool) {
        if loading {
            activityIndicator.startAnimating();
            errorLabel.text = "";
        } else {
            activityIndicator.stopAnimating();
        }
        usernameField.isEnabled = !loading
        passwordField.isEnabled = !loading
        signInButton.isEnabled = !loading
        signUpButton.isEnabled = !loading
    }
    
    func validate(_ listDetail:Bool) -> Bool {
        usernameField.text = usernameField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        passwordField.text = passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if (usernameField.text == "") {
            errorLabel.text = "Username must be provided"
            return true
        } else if (passwordField.text == "") {
            errorLabel.text = "Password must be provided"
            return true
        } else {
            return true
        }
    }
    
    @IBAction func signIn(_ sender: Any) {
        signIn()
    }
    
    @IBAction func signUp(_ sender: Any) {
        if (validate(true)) {
            setLoading(true)
            app.usernamePasswordProviderClient().registerEmail(usernameField.text!, password: passwordField.text!, completion: {[weak self](error) in
                // Completion handlers are not necessarily called on the UI thread.
                // This call to DispatchQueue.main.sync ensures that any changes to the UI,
                // namely disabling the loading indicator and navigating to the next page,
                // are handled on the UI thread:
                DispatchQueue.main.sync {
                    self!.setLoading(false);
                    guard error == nil else {
                        print("Signup failed: \(error!)")
                        self!.errorLabel.text = "Signup failed: \(error!.localizedDescription)"
                        return
                    }
                    print("Signup successful!")

                    // Registering just registers. Now we need to sign in,
                    // but we can reuse the existing username and password.
                    self!.errorLabel.text = "Signup successful! Signing in..."
                    
                    self!.signIn()
                }
            })
        }
    }

    func signIn() {
        setLoading(true);

        app.login(withCredential: AppCredentials(username: usernameField.text!, password: passwordField.text!)) { [weak self](user, error) in
            // Completion handlers are not necessarily called on the UI thread.
            // This call to DispatchQueue.main.sync ensures that any changes to the UI,
            // namely disabling the loading indicator and navigating to the next page,
            // are handled on the UI thread:

            DispatchQueue.main.sync {
                self!.setLoading(false);
                guard error == nil else {
                    // Auth error: user already exists? Try logging in as that user.
                    print("Login failed: \(error!)");
                    self!.errorLabel.text = "Login failed: \(error!.localizedDescription)"
                    return
                }
                
                self!.usernameField.text = ""
                self!.passwordField.text = ""
                
                // See if there is a List ID associated
                if (user?.customData?["list"] != nil) {
                    // Obtain List ID Value
                        //guard let partition_id = user?.customData?["list"]!!.stringValue! else {return}
                    guard let listdata = user?.customData?["list"], let partition_id = listdata?.stringValue! else {return}
                    // Configure Realm User Object with Partition Value (List ID)
                    let projectRealm = try! Realm(configuration: user!.configuration(partitionValue: partition_id))
                    // Navigate to shopping list screen, passing the Realm
                    let vc  = self?.storyboard?.instantiateViewController(withIdentifier: "shoppingListViewController") as! shoppingListViewController
                    vc.realm = projectRealm
                    vc.modalPresentationStyle = .fullScreen
                    self?.present(vc, animated:true)
                } else {
                    // A list has not yet been configured so load screen to capture
                    let vc  = self?.storyboard?.instantiateViewController(withIdentifier: "setListViewController") as! setListViewController
                    vc.modalPresentationStyle = .fullScreen
                    self?.present(vc, animated:true)
                }

            }
        };
    }
    

}

