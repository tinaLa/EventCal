//
//  FriendsTableViewController.swift
//  Eventcal
//
//  Created by Tina La on 8/21/17.
//  Copyright © 2017 Tina La. All rights reserved.
//

import UIKit

class FriendsTableViewController: UITableViewController {
    
    var friends = [User]() {
        didSet { tableView.reloadData() }
    }


    @IBOutlet weak var menuButton: UIBarButtonItem!
    
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
    }

    override func viewWillAppear(_ animated: Bool) {
        FriendService.fetchFriends(uid: User.current.uid) { (friends) in
            self.friends = friends
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewProfile" {
            let destinationViewController = segue.destination as! OtherUserProfileViewController
            let indexPath = tableView.indexPathForSelectedRow!
            let selectedUser = friends[indexPath.row]
            destinationViewController.user = selectedUser
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyFriendsCell", for: indexPath) as! FriendsTableViewCell
        configure(cell: cell, atIndexPath: indexPath)
        return cell
    }
    
    func configure(cell: FriendsTableViewCell, atIndexPath indexPath: IndexPath) {
        let user = friends[indexPath.row]
        cell.nameLabel.text = "\(user.firstName) \(user.lastName)"
    }
}
