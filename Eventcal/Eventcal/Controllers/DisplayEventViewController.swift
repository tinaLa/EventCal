//
//  DisplayEventViewController.swift
//  Eventcal
//
//  Created by Tina La on 8/17/17.
//  Copyright © 2017 Tina La. All rights reserved.
//

import UIKit

class DisplayEventViewController: UIViewController {
    
    var event: Event?
    
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventLocationNameLabel: UILabel!
    @IBOutlet weak var eventLocationAddressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let event = event {
            eventNameLabel.text = event.name
            eventDateLabel.text = event.startDate
            eventLocationNameLabel.text = event.locationName
            eventLocationAddressLabel.text = event.locationAddress
        }
    }
}
