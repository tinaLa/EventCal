//
//  FindFriendsTableViewCell.swift
//  Eventcal
//
//  Created by Tina La on 8/21/17.
//  Copyright © 2017 Tina La. All rights reserved.
//

import UIKit

class FindFriendsTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addButton.setTitle("Add", for: .normal)
        addButton.setTitle("Request Sent", for: .selected)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
