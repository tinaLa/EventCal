//
//  FriendRequestTableViewController.swift
//  Eventcal
//
//  Created by Tina La on 8/21/17.
//  Copyright © 2017 Tina La. All rights reserved.
//

import UIKit

class FriendRequestTableViewController: UITableViewController {

    var request_uids = [String]()
    var requests = [User]() {
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
        super.viewWillAppear(true)
        FriendService.fetchFriendRequests { (requests) in
            guard let requests = requests else { return }
            self.requests = requests
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewProfile" {
            let destinationViewController = segue.destination as! OtherUserProfileViewController
            let indexPath = tableView.indexPathForSelectedRow!
            let selectedUser = requests[indexPath.row]
            destinationViewController.user = selectedUser
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRequestCell", for: indexPath) as! FriendRequestTableViewCell
        cell.delegate = self
        configure(cell: cell, atIndexPath: indexPath)
        return cell
    }
    
    func configure(cell: FriendRequestTableViewCell, atIndexPath indexPath: IndexPath) {
        let user = requests[indexPath.row]
        cell.nameLabel.text = "\(user.firstName) \(user.lastName)"
    }
}

extension FriendRequestTableViewController: FriendRequestTableViewCellDelegate {
    func didTapAddButton(_ addButton: UIButton, on cell: FriendRequestTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        addButton.isUserInteractionEnabled = false
        let newFriend = requests[indexPath.row]
        
        FriendService.acceptFriendRequest(newFriend) { (success) in
            self.requests.remove(at: indexPath.row)
        }

    }
}
