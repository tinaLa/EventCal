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
        
        FriendService.fetchFriendRequests { (requests) in
            self.request_uids = requests
            
            for uid in self.request_uids {
                UserService.show(forUID: uid, completion: { (user) in
                    guard let user = user else { return }
                    self.requests.append(user)
                })
            }
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
