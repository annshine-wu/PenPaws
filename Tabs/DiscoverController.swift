//
//  DiscoverController.swift
//  PenPaws
//
//  Created by Annshine Wu on 11/04/2018.
//  Copyright © 2018 Annshine Wu. All rights reserved.
//

import UIKit
import Firebase
class DiscoverController: UICollectionViewController {
    let storage = Storage.storage().reference()
    var databaseRef: DatabaseReference!
    var discoverMenu =  ["0", "1", "2", "3","4","5","6","7","8","9","10","11","12","13","14"];

    override func viewDidLoad() {
        super.viewDidLoad()
        databaseRef = Database.database().reference()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return discoverMenu.count;
    }
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "discoverCell", for: indexPath) as! DiscoverCollectionViewCell
        
        let tempImageRef = storage.child(discoverMenu[indexPath.row]+".jpg");
        tempImageRef.getData(maxSize: 1*1000*1000) { (data,error ) in
            if error == nil{
               cell.imageCell.image = UIImage(data: data!)
            }else{
                print(error?.localizedDescription ?? "")
            }
        }
        _ = databaseRef.child("dogs").child(discoverMenu[indexPath.row]).observe(.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let dogName = value?["name"] as? String ?? ""
            cell.labelCell.text = dogName
            cell.buttonIdentifier.setTitle(self.discoverMenu[indexPath.row], for: .normal)
        }) { (error) in
            print(error.localizedDescription)
        }
        return cell
    }
    
    public override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! DiscoverCollectionViewCell
        let identifier = Int((cell.buttonIdentifier.titleLabel?.text!)!)
        let stringIdentifier = (cell.buttonIdentifier.titleLabel?.text!)!
        _ = databaseRef.child("dogs").child(stringIdentifier).observe(.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let adoptionStatus = value?["adopted"] as? Bool
            if(adoptionStatus == true){
                self.performSegue(withIdentifier: "toPersonalDogProfile", sender: identifier)
            }
            else{
                self.performSegue(withIdentifier: "toShelterDogProfile", sender: identifier)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toShelterDogProfile"){
            let secondScene = segue.destination as! DogProfileViewController
            secondScene.intIdentifier = sender as? Int ?? 0
        }
        if(segue.identifier == "toPersonalDogProfile"){
            let secondScene = segue.destination as! DogPersonalProfileViewController
            secondScene.intIdentifier = sender as? Int ?? 0
        }
    }
}

