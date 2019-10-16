//
//  LoginController.swift
//  PenPaws
//
//  Created by Annshine Wu on 11/04/2018.
//  Copyright © 2018 Annshine Wu. All rights reserved.
//

import Foundation
import UIKit
import Firebase
class LoginController: UIViewController {
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var warning: UILabel!
    var loginCheck = false
    @IBOutlet weak var login: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //login.layer.borderWidth = 1
        //login.layer.cornerRadius = 5
        password.isSecureTextEntry = true
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        guard emailAddress.text != "", password.text != "" else {return}
        
        Auth.auth().signIn(withEmail: emailAddress.text!, password: password.text!, completion: { (user, error) in
            
            if let error = error {
                self.warning.text = "The email and password does not match."
                print(error.localizedDescription)
            }
            else if user == user {
                self.loginCheck = true
                self.performSegue(withIdentifier: "Login", sender: nil)
            }
        })
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "Login" && loginCheck == false{
            return false
        }
        return true
    }
    
}
