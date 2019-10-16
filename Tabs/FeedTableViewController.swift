//
//  FeedTableViewController.swift
//  PenPaws
//
//  Created by Annshine Wu on 15/04/2018.
//  Copyright © 2018 Annshine Wu. All rights reserved.
//

import UIKit
import Firebase

class FeedTableViewController: UITableViewController {
    let storage = Storage.storage().reference()
    var databaseRef: DatabaseReference!
    let user = Auth.auth().currentUser
    var postDictionary: NSMutableDictionary = [:]
    var referencePost: NSDictionary = [:]
    var nextIdentifier = 0
    var closureFetch = 0
    var checkSum = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseRef = Database.database().reference()
        
    }
    
    override func viewDidAppear(_ animated: Bool){
        let userReference = databaseRef.child("users").child((user?.uid)!)
        postDictionary = [:]
        _ = userReference.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let followValue = value?.value(forKey: "follow") as? Int ?? -1
            if (followValue == -1){
                let followList  = value?.value(forKey: "follow") as? NSDictionary ?? [:]
                if(followList != [:]){
                    for (dogID, donationValue) in followList{
                        var dogXID = dogID as! String
                        let lowerBound = String.Index(encodedOffset: 1)
                        let upperBound = String.Index(encodedOffset: dogXID.count)
                        dogXID = String(dogXID[lowerBound..<upperBound])
                        _ = self.databaseRef.child("dogs").child(dogXID).child("posts").observe(.value, with: { (snapshotTwo) in
                            let tempPost = snapshotTwo.value as? NSDictionary
                            if(tempPost != nil){
                                for(postID, postValue) in tempPost!{
                                    let postIDString = postID as! String
                                    self.postDictionary[postIDString] = postValue
                                }
                            }
                            userReference.child("followedPost").removeValue()
                            userReference.child("followedPost").setValue(self.postDictionary as! [AnyHashable : Any], withCompletionBlock: { (error, ref) in
                                if error  != nil{
                                    print(error!)
                                }
                            })
                        }) { (error) in
                            print(error.localizedDescription)
                        }
                        if((donationValue as? NSDictionary ?? [:]).value(forKey: "single") as? Int ?? 0 > 0 || (donationValue as? NSDictionary ?? [:]).value(forKey: "month") as? Int ?? 0 > 0){
                            _ = self.databaseRef.child("dogs").child(dogXID).child("exclusivePosts").observe(.value, with: { (snapshotTwo) in
                                let tempPost = snapshotTwo.value as? NSDictionary
                                if(tempPost != nil){
                                    for(postID, postValue) in tempPost!{
                                        let postIDString = postID as! String
                                        self.postDictionary[postIDString] = postValue
                                    }
                                }
                                userReference.child("followedPost").updateChildValues(self.postDictionary as! [AnyHashable : Any], withCompletionBlock: { (error, ref) in
                                    if error  != nil{
                                        print(error!)
                                    }
                                })
                            }) { (error) in
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return 10
    }

    func comparePosts(s1:Any, s2:Any) -> Bool {
        var postIDString1 = s1 as! String
        let lowerBound1 = postIDString1.index(of: "-")
        let upperBound1 = String.Index(encodedOffset: postIDString1.count)
        postIDString1 = String(postIDString1[lowerBound1!..<upperBound1])
        var postIDString2 = s2 as! String
        let lowerBound2 = postIDString2.index(of: "-")
        let upperBound2 = String.Index(encodedOffset: postIDString2.count)
        postIDString2 = String(postIDString2[lowerBound2!..<upperBound2])
        return postIDString1 > postIDString2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! FeedTableViewCell
        let postListReference = databaseRef.child("users").child((user?.uid)!).child("followedPost")
        _ = postListReference.observeSingleEvent(of: .value, with: { (snapshot) in
            let postList = snapshot.value as? NSDictionary
            if(postList != nil){
                var sortedKeys = postList?.allKeys
                sortedKeys = sortedKeys?.sorted(by: self.comparePosts as (Any, Any) -> Bool)
                if(indexPath.row < (sortedKeys?.count)!){
                    let postValueDictionary = postList![sortedKeys![indexPath.row]] as! NSDictionary
                    let title  = postValueDictionary["title"] as? String ?? ""
                    cell.postTitle.text = title
                    let caption = postValueDictionary["caption"] as? String ?? ""
                    let author = postValueDictionary["author"] as? String ?? ""
                    cell.postCaption.text = caption
                    let identifier = postValueDictionary["identifier"] as? Int ?? 0
                    let stringIdentifier = String(identifier)
                    cell.postDogIdentifier.setTitle(stringIdentifier, for: .normal)
                    cell.postDogName.setTitle(author, for: .normal)
                    let imageName = postValueDictionary["image"] as? String ?? ""
                    let tempImageRef = self.storage.child(imageName + ".jpg");
                    tempImageRef.getData(maxSize: 1*1000*1000) { (data,error ) in
                        if error == nil{
                            cell.postImage.image = UIImage(data: data!)
                        }else{
                            print(error?.localizedDescription ?? "")
                        }
                    }
                }
                else{
                    cell.postTitle.text = ""
                    cell.postCaption.text = ""
                }
            }
        })
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FeedTableViewCell
        if (cell.postDogIdentifier.titleLabel?.text != "" && cell.postDogIdentifier.titleLabel?.text != nil) {
            let identifier = Int((cell.postDogIdentifier.titleLabel?.text!)!)
            let stringIdentifier = (cell.postDogIdentifier.titleLabel?.text!)!
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
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 357
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
