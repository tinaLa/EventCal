//
//  FriendRequestTableViewCell.swift
//  Eventcal
//
//  Created by Tina La on 8/21/17.
//  Copyright © 2017 Tina La. All rights reserved.
//

import UIKit

class FriendRequestTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
