//
//  DonationViewController.swift
//  PenPaws
//
//  Created by Annshine Wu on 13/04/2018.
//  Copyright © 2018 Annshine Wu. All rights reserved.
//

import UIKit
import Firebase
class DonationViewController: UIViewController {

    @IBOutlet weak var dogName: UILabel!
    @IBOutlet weak var donationInput: UITextField!
    @IBOutlet weak var donationMonthly: UITextField!
    @IBOutlet weak var dogPicture: UIImageView!
    
    public var intIdentifier: Int = 0
    let storage = Storage.storage().reference()
    var databaseRef: DatabaseReference!
    var name: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseRef = Database.database().reference()
        let dogIdentifier = String(intIdentifier);
        let tempImageRef = storage.child(dogIdentifier + ".jpg");
        tempImageRef.getData(maxSize: 1*1000*1000) { (data,error ) in
            if error == nil{
                self.dogPicture.image = UIImage(data: data!)
            }else{
                print(error?.localizedDescription ?? "")
            }
        }
        _ = databaseRef.child("dogs").child(dogIdentifier).observe(.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.name = value?["name"] as? String ?? ""
            self.dogName.text = self.name
        }) { (error) in
            print(error.localizedDescription)
        }
        // Do any additional setup after loading the view.
    }
    @IBAction func confirmPayment(_ sender: Any){
        let dogIdentifier = String(intIdentifier);
        let donationString: String = (donationInput?.text)!
        var donationAmount: Int = Int(donationString) ?? -1
        var donationMonthAmount: Int = Int((donationMonthly?.text)!) ?? -1
        var donationTotal: Int = donationAmount
        if(donationAmount > 0 || donationMonthAmount > 0){
            let user = Auth.auth().currentUser;
            let userReference = databaseRef.child("users").child((user?.uid)!)
            _ = userReference.child("follow").child("x"+dogIdentifier).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                if(donationAmount < 0){
                    donationAmount = 0
                }
                if(value?.object(forKey: "single") != nil){
                    let previouslyDonated = value?.object(forKey: "single") as? Int ?? 0
                    donationAmount += previouslyDonated
                }
                if(donationMonthAmount < 0){
                    donationMonthAmount = value?.object(forKey: "month") as? Int ?? 0
                }
                let added = ["single": donationAmount, "month": donationMonthAmount] as [String : Any]
                userReference.child("follow").child("x"+dogIdentifier).updateChildValues(added, withCompletionBlock: { (error, ref) in
                    if error  != nil{
                        print(error!)
                    }
                })
            }) { (error) in
                print(error.localizedDescription)
            }
            _ = userReference.observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                if(value?.object(forKey: "donation") != nil){
                    let previouslyDonated = value?.object(forKey: "donation") as? Int ?? 0
                    donationTotal += previouslyDonated
                }
                let added = ["donation": donationTotal]
                userReference.updateChildValues(added, withCompletionBlock: { (error, ref) in
                    if error  != nil{
                        print(error!)
                    }
                })
            }) { (error) in
                print(error.localizedDescription)
            }
            
            navigationController?.popViewController(animated: true)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
