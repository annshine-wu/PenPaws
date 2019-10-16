//
//  FeedTableViewCell.swift
//  PenPaws
//
//  Created by Annshine Wu on 15/04/2018.
//  Copyright © 2018 Annshine Wu. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postCaption: UILabel!
    @IBOutlet weak var postDogName: UIButton!
    @IBOutlet weak var postDogIdentifier: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
