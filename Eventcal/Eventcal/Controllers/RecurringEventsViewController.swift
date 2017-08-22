//
//  RecurringEventsViewController.swift
//  Eventcal
//
//  Created by Tina La on 8/14/17.
//  Copyright © 2017 Tina La. All rights reserved.
//

import UIKit

class RecurringEventsViewController: UIViewController {

    // MARK: - Side Menu Stuff
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
}
