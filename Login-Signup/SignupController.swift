//
//  SignupController.swift
//  PenPaws
//
//  Created by Annshine Wu on 11/04/2018.
//  Copyright © 2018 Annshine Wu. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class SignupController: UIViewController {
    
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var warning: UILabel!

    var signupCheck = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        password.isSecureTextEntry = true
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func signUpPressed(_ sender: Any) {
        var databaseRef: DatabaseReference!
        databaseRef = Database.database().reference()
        
        guard let emailAddressVar = emailAddress.text else{
            print("Email Address Issue")
            return
        }
        guard password.text != nil else{
            print("Password Issue")
            return
        }
        guard let firstNameVar = firstName.text else{
            print("First Name Issue")
            return
        }
        guard let lastNameVar = lastName.text else{
            print("Last Name Issue")
            return
        }
        Auth.auth().createUser(withEmail: emailAddress.text!, password: password.text!) { (user, error) in
            if error != nil{
                print(error!)
                self.warning.text = error?.localizedDescription
                return
            }
            guard let uid = user?.uid else{
                return
            }
            let userReference = databaseRef.child("users").child(uid)
            let value = ["email": emailAddressVar, "firstName": firstNameVar, "lastName": lastNameVar, "follow": "","followedPost":"", "donation": "0"]
            userReference.updateChildValues(value, withCompletionBlock: { (error, ref) in
                if error  != nil{
                    print(error!)
                    return
                }
                self.signupCheck = true
                self.performSegue(withIdentifier: "Back", sender: nil)
                //self.dismiss(animated: true, completion:nil)
            })
        }
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
        if identifier == "Back" && signupCheck == false{
            return false
        }
        return true
    }
}
