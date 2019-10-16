//
//  DogProfileViewController.swift
//  PenPaws
//
//  Created by Annshine Wu on 12/04/2018.
//  Copyright © 2018 Annshine Wu. All rights reserved.
//

import UIKit
import Firebase
class DogProfileViewController: UIViewController {

    @IBOutlet weak var dogName: UILabel!
    @IBOutlet weak var dogPicture: UIImageView!
    @IBOutlet weak var dogIntroduction: UILabel!
    @IBOutlet weak var dogAge: UILabel!
    @IBOutlet weak var dogBreed: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var dogShelterID: UIButton!
    @IBOutlet weak var dogShelter: UIButton!
    var name: String = ""
    
    public var intIdentifier: Int = 0
    let storage = Storage.storage().reference()
    var databaseRef: DatabaseReference!
    
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
            self.dogIntroduction.text = value?["introduction"] as? String ?? ""
            let intAge = value?["age"] as? Int ?? 0
            self.dogAge.text =  String(intAge)
            self.dogBreed.text = value?["breed"] as? String ?? ""
            self.dogShelterID.setTitle(String(value?["shelterID"] as? Int ?? 0), for: .normal)
            self.dogShelter.setTitle(value?["shelter"] as? String ?? "",for: .normal)
            if(value?.object(forKey: dogIdentifier) == nil){
                self.followButton.setTitle("FOLLOW", for: .normal)
            }
            else{
                self.followButton.setTitle("UNFOLLOW", for: .normal)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        let user = Auth.auth().currentUser;
        let userReference = databaseRef.child("users").child((user?.uid)!).child("follow")
        _ = userReference.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if(value?.object(forKey: "x" + dogIdentifier) == nil){
                self.followButton.setTitle("FOLLOW", for: .normal)
            }
            else{
                self.followButton.setTitle("UNFOLLOW", for: .normal)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func followDog(_ sender: UIButton) {
        let dogIdentifier = String(intIdentifier);
        let user = Auth.auth().currentUser;
        let userReference = databaseRef.child("users").child((user?.uid)!).child("follow")
        _ = userReference.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let tempKey = "x" + dogIdentifier
            if(value?.object(forKey: tempKey) == nil){
                self.followButton.setTitle("UNFOLLOW", for: .normal)
                let value = ["x" + dogIdentifier : 0]
                userReference.updateChildValues(value, withCompletionBlock: { (error, ref) in
                    if error  != nil{
                        print(error!)
                    }
                })
            }
            else{
                self.followButton.setTitle("FOLLOW", for: .normal)
                userReference.child("x"+dogIdentifier).removeValue()
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toDonation"){
            let secondScene = segue.destination as! DonationViewController
            secondScene.intIdentifier = self.intIdentifier
        }
        if(segue.identifier == "toShelter"){
            let secondScene = segue.destination as! ShelterViewController
            secondScene.shelterID = Int((dogShelterID!.titleLabel?.text!)!)!
        }
    }
    
}
