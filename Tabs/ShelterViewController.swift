//
//  ShelterViewController.swift
//  PenPaws
//
//  Created by Annshine Wu on 22/04/2018.
//  Copyright © 2018 Annshine Wu. All rights reserved.
//

import UIKit
import Firebase
class ShelterViewController: UIViewController {
    public var shelterID = 0
    var databaseRef: DatabaseReference!
    
    @IBOutlet weak var shelterName: UILabel!
    @IBOutlet weak var shelterLocation: UILabel!
    @IBOutlet weak var shelterPhoneNumber: UILabel!
    @IBOutlet weak var shelterWebsite: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseRef = Database.database().reference()
        _ = databaseRef.child("shelters").child(String(shelterID)).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.shelterName.text = value!["name"] as? String ?? ""
            self.shelterLocation.text = value!["location"] as? String ?? ""
            self.shelterPhoneNumber.text = value!["phoneNumber"] as? String ?? ""
            self.shelterWebsite.text = value!["website"] as? String ?? ""
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
