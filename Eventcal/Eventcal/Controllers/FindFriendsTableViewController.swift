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
    
    var users = [User]()
    
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
            self.users = users
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FindFriendsCell", for: indexPath) as! FindFriendsTableViewCell
        configure(cell: cell, atIndexPath: indexPath)
        return cell
    }

    func configure(cell: FindFriendsTableViewCell, atIndexPath indexPath: IndexPath) {
        let user = users[indexPath.row]
        cell.nameLabel.text = "\(user.firstName) \(user.lastName)"
    }

}
