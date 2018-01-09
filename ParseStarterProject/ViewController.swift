/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class ViewController: UIViewController {

    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var toggle: UISwitch!
    @IBOutlet var enterButton: UIButton!
    @IBOutlet var switchButton: UIButton!
    @IBOutlet var driverLabel: UILabel!
    @IBOutlet var riderLabel: UILabel!
    
    var switchMode = true
    
    
    
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alert) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func enterAction(_ sender: Any) {
        if usernameTextField.text == "" && passwordTextField.text == "" {
            createAlert(title: "Error in form", message: "Please enter an email and password!")
        } else {
            if switchMode{
                
                
                
                // Sign Up Mode
                let user = PFUser()
                user.username = usernameTextField.text
                user.password = passwordTextField.text
                user["isDriver"] = self.toggle.isOn
                
                
                user.signUpInBackground(block: { (success, error) in
                    if error != nil {
                        
                        var displayErrorMessage = "Please try again later"
                        if let errorMessage = (error! as NSError).userInfo["error"] as? String{
                            displayErrorMessage = errorMessage
                        }
                    
                    self.createAlert(title: "Sign Up Error", message: displayErrorMessage)
                    
                    } else {
                        
                        // Sign Up Mode
                        
                        if (PFUser.current()!["isDriver"] as? Bool)! {
                            
                            self.performSegue(withIdentifier: "showRequestList", sender: self)
                            
                        } else {
                            
                            self.performSegue(withIdentifier: "showRiderMap", sender: self)
                        }
                        
                    
                    }})
                
                
                
            } else {
                
                // Log In Mode
                PFUser.logInWithUsername(inBackground: usernameTextField.text!, password: passwordTextField.text!, block: { (user, error) in
                    if error != nil {
                        
                        var displayErrorMessage = "Please try again later"
                        if let errorMessage = (error! as NSError).userInfo["error"] as? String{
                            displayErrorMessage = errorMessage
                        }
                        
                        self.createAlert(title: "Sign Up Error", message: displayErrorMessage)
                        
                    } else {
                        
                        if (PFUser.current()!["isDriver"] as? Bool)! {
                            
                            self.performSegue(withIdentifier: "showRequestList", sender: self)
                        
                        } else {
                            
                            self.performSegue(withIdentifier: "showRiderMap", sender: self)
                            }
                        
                    }
                })
            
                
            }
        }
        
        
    }
    
    @IBAction func switchAction(_ sender: Any) {
        
        if switchMode {
            // Log In Mode
            
            enterButton.setTitle("Log In", for: [])
            switchButton.setTitle("Switch To Sign Up", for: [])
            riderLabel.isHidden = true
            driverLabel.isHidden = true
            toggle.isHidden = true
            print("Log In Mode")
            
        } else {
            // Sign Up Mode
            
            enterButton.setTitle("Sign Up", for: [])
            switchButton.setTitle("Switch To Log In", for: [])
            riderLabel.isHidden = false
            driverLabel.isHidden = false
            toggle.isHidden = false
            print("Sign Up Mode")
        }
        
        switchMode = !switchMode
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let isDriver = (PFUser.current()?["isDriver"] as? Bool) {
            if isDriver{
                
                self.performSegue(withIdentifier: "showRequestList", sender: self)
                
            } else {
                
                self.performSegue(withIdentifier: "showRiderMap", sender: self)
            }
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
//        let testObject = PFObject(className: "TestObject2")
//
//        testObject["foo"] = "bar"
//
//        testObject.saveInBackground { (success, error) -> Void in
//
//            // added test for success 11th July 2016
//
//            if success {
//
//                print("Object has been saved.")
//
//            } else {
//
//                if error != nil {
//
//                    print (error)
//
//                } else {
//
//                    print ("Error")
//                }
//
//            }
//
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
