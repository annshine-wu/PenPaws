//
//  PopUpViewController.swift
//  PenPaws
//
//  Created by Annshine Wu on 22/04/2018.
//  Copyright © 2018 Annshine Wu. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController {
    public var intIdentifier: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toDonation"){
            let secondScene = segue.destination as! DonationViewController
            secondScene.intIdentifier = self.intIdentifier
        }
    }
}
