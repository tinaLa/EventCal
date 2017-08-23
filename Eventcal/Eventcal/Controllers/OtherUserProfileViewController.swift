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
        nameLabel.text = "\(user.firstName) \(user.lastName)"
        self.retrievePicture()
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
        
        addFriendButton.isEnabled = false
        
        FriendService.setIsRequested(!user.isRequested, fromCurrentUserTo: user) { (success) in
            defer {
                self.addFriendButton.isEnabled = true
            }
            guard success else { return }
            user.isRequested = !user.isRequested
        }
    }
}
