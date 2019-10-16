//
//  MonthlySubscriptionsTableViewController.swift
//  PenPaws
//
//  Created by Annshine Wu on 22/04/2018.
//  Copyright © 2018 Annshine Wu. All rights reserved.
//

import UIKit
import Firebase
class MonthlySubscriptionsTableViewController: UIViewController {
    var databaseRef: DatabaseReference!
    @IBOutlet weak var monthlyLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = Auth.auth().currentUser;
        databaseRef = Database.database().reference()
        let userReference = databaseRef.child("users").child((user?.uid)!)
        _ = userReference.child("follow").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary ?? [:]
            var stringAdd = ""
            if(value != [:]){
                for (dogID, donationValue) in value{
                    var dogXID = dogID as! String
                    let lowerBound = String.Index(encodedOffset: 1)
                    let upperBound = String.Index(encodedOffset: dogXID.count)
                    dogXID = String(dogXID[lowerBound..<upperBound])
                    let monthAmount = (donationValue as? NSDictionary ?? [:]).value(forKey: "month") as? Int ?? 0
                    if(monthAmount > 0){
                        _ = self.databaseRef.child("dogs").child(dogXID).observeSingleEvent(of: .value, with: {(snapshot) in
                            let information = snapshot.value as? NSDictionary
                            stringAdd += information!["name"] as? String ?? ""
                            stringAdd += ": "
                            stringAdd += String(monthAmount)
                            stringAdd += "\n"
                            self.monthlyLabel.text = stringAdd
                        })
                    }
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}
