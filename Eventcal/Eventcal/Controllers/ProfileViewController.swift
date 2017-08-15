//
//  ProfileViewController.swift
//  Eventcal
//
//  Created by Tina La on 8/14/17.
//  Copyright © 2017 Tina La. All rights reserved.
//

import UIKit
import FirebaseStorage

class ProfileViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var profilePictureView: UIImageView!
    
    let photoHelper = PhotoHelper()

    
    // MARK: - Side Menu Stuff
    func sideMenu() {
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rearViewRevealWidth = 275
            
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenu()
        nameLabel.text = "\(User.current.firstName) \(User.current.lastName)"
        
        photoHelper.completionHandler = { image in
            PFPService.addProfilePicture(for: image)
            
        }
        
        let uid = User.current.uid
        PFPService.retreiveURL(uid: uid) { (urlString) in
            guard let urlString = urlString else {
                return
            }
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
    
    @IBAction func editProfileTapped(_ sender: Any) {
        photoHelper.presentActionSheet(from: self)
    }
}
