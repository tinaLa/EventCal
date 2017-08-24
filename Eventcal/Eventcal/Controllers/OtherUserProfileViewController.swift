//
//  OtherUserProfileViewController.swift
//  Eventcal
//
//  Created by Tina La on 8/22/17.
//  Copyright © 2017 Tina La. All rights reserved.
//

import UIKit

class OtherUserProfileViewController: UIViewController {

    var user: User?
    
    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addFriendButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        guard let user = user else { return }
        
        self.retrievePicture()
        nameLabel.text = "\(user.firstName) \(user.lastName)"
        
        addFriendButton.isSelected = user.isRequested || user.isFriend
        
        if user.hasRequested {
            addFriendButton.setTitle("Accept friend request", for: .normal)
            addFriendButton.setTitle("Unfriend", for: .selected)
        }
        else if user.isFriend {
            addFriendButton.setTitle("Add friend", for: .normal)
            addFriendButton.setTitle("Unfriend", for: .selected)
        }
        else {
            addFriendButton.setTitle("Add friend", for: .normal)
            addFriendButton.setTitle("Request Sent", for: .selected)
        }
        
    }
    
    func retrievePicture() {
        guard let user = user else { return }
        let uid = user.uid
        PFPService.retreiveURL(uid: uid) { (urlString) in
            guard let urlString = urlString else { return }
            
            let url = URL(string: urlString)
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                if error != nil {
                    print(error!)
                    return
                }
                DispatchQueue.main.async {
                    self.profilePictureView.image = UIImage(data: data!)
                }
            }).resume()
        }
    }
    
    @IBAction func addFriend(_ sender: Any) {
        guard let user = user else { return }
        
        addFriendButton.isSelected = !addFriendButton.isSelected
        addFriendButton.isEnabled = false
        
        if user.hasRequested {
            FriendService.acceptFriendRequest(user) { (success) in
                defer {
                    self.addFriendButton.isEnabled = true
                }
                guard success else { return }
                user.isFriend = !user.isFriend
            }
        } else if user.isFriend {
            FriendService.deleteFriend(user) { (success) in
                defer {
                    self.addFriendButton.isEnabled = true
                }
                guard success else { return }
                user.isFriend = !user.isFriend
            }
        } else {
            FriendService.setIsRequested(!user.isRequested, fromCurrentUserTo: user) { (success) in
                defer {
                    self.addFriendButton.isEnabled = true
                }
                guard success else { return }
                user.isRequested = !user.isRequested
            }
        }
        
    }
}
