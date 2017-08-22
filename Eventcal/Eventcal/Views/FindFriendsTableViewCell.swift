//
//  FindFriendsTableViewCell.swift
//  Eventcal
//
//  Created by Tina La on 8/21/17.
//  Copyright © 2017 Tina La. All rights reserved.
//

import UIKit

protocol FindFriendsTableViewCellDelegate: class {
    func didTapAddButton(_ followButton: UIButton, on cell: FindFriendsTableViewCell)
}

class FindFriendsTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    weak var delegate: FindFriendsTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        addButton.setTitle("Add", for: .normal)
        addButton.setTitle("Request Sent", for: .selected)
    }
    
    @IBAction func addFriend(_ sender: UIButton) {
        delegate?.didTapAddButton(sender, on: self)
    }
}
