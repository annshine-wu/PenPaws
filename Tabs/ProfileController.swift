//
//  ProfileController.swift
//  PenPaws
//
//  Created by Annshine Wu on 11/04/2018.
//  Copyright © 2018 Annshine Wu. All rights reserved.
//

import Foundation
import UIKit
import Firebase
class ProfileController: UIViewController {
    var databaseRef: DatabaseReference!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var userDonation: UILabel!
    
    @IBOutlet weak var labelCount: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseRef = Database.database().reference()
        let user = Auth.auth().currentUser;
        let userReference = databaseRef.child("users").child((user?.uid)!)
        _ = userReference.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let firstName = value?["firstName"] as? String ?? ""
            let lastName = value?["lastName"] as? String ?? ""
            self.userName.text = firstName + " " + lastName
            self.userEmail.text = value?["email"] as? String ?? ""
            self.userDonation.text = (String)(value?["donation"] as? Int ?? 0)
        }) { (error) in
            print(error.localizedDescription)
        }
        var count = 0
        userReference.child("follow").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let followValue = value as? Int ?? -1
            if (followValue == -1){
                let followList  = value ?? [:]
                if(followList != [:]){
                    for (dogID, donationValue) in followList{
                        var dogXID = dogID as! String
                        let lowerBound = String.Index(encodedOffset: 1)
                        let upperBound = String.Index(encodedOffset: dogXID.count)
                        dogXID = String(dogXID[lowerBound..<upperBound])
                        let monthAmount = (donationValue as? NSDictionary ?? [:]).value(forKey: "month") as? Int ?? 0
                        if(monthAmount > 0){
                            count = count + 1
                        }
                    }
                }
            }
            self.labelCount.text = String(count)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func logOutAction(sender: AnyObject) {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Login")
                present(vc, animated: true, completion: nil)
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
}
