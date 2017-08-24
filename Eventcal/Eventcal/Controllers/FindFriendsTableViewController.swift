//
//  FindFriendsTableViewController.swift
//  Eventcal
//
//  Created by Tina La on 8/21/17.
//  Copyright © 2017 Tina La. All rights reserved.
//

import UIKit

class FindFriendsTableViewController: UITableViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var users = [User]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
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
        super.viewWillAppear(animated)
        
        UserService.usersExcludingCurrentUser { [unowned self] (users) in
            var filteredUsers = users.filter({ $0.isFriend == false && $0.hasRequested == false})
            
//            for i in 0..<users.count {
//                if users[i].hasRequested || users[i].isFriend {
//                    filteredUsers.remove(at: i)
//                }
//            }
//            
            self.users = filteredUsers
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewProfile" {
            let destinationViewController = segue.destination as! OtherUserProfileViewController
            let indexPath = tableView.indexPathForSelectedRow!
            let selectedUser = users[indexPath.row]
            destinationViewController.user = selectedUser
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FindFriendsCell", for: indexPath) as! FindFriendsTableViewCell
        cell.delegate = self
        configure(cell: cell, atIndexPath: indexPath)
        return cell
    }

    func configure(cell: FindFriendsTableViewCell, atIndexPath indexPath: IndexPath) {
        let user = users[indexPath.row]
        cell.nameLabel.text = "\(user.firstName) \(user.lastName)"
        cell.addButton.isSelected = user.isRequested
    }
}

extension FindFriendsTableViewController: FindFriendsTableViewCellDelegate {
    
    func didTapAddButton(_ addButton: UIButton, on cell: FindFriendsTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        addButton.isUserInteractionEnabled = false
        let newFriend = users[indexPath.row]
        
        FriendService.setIsRequested(!newFriend.isRequested, fromCurrentUserTo: newFriend) { (success) in
            defer { addButton.isUserInteractionEnabled = true }
            guard success else { return }
            newFriend.isRequested = !newFriend.isRequested
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
}
