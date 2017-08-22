//
//  DisplayEventViewController.swift
//  Eventcal
//
//  Created by Tina La on 8/17/17.
//  Copyright © 2017 Tina La. All rights reserved.
//

import UIKit

class DisplayEventViewController: UIViewController {
    
    var eventKey: String?
    var event: Event?
    
    let dateFormatter = DateFormatter()
    
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventStartDateLabel: UILabel!
    @IBOutlet weak var eventEndDateLabel: UILabel!
    @IBOutlet weak var eventLocationNameLabel: UILabel!
    @IBOutlet weak var eventLocationAddressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        guard let eventKey = eventKey else { return }
        
        EventService.show(eventID: eventKey) { (event) in
            if let event = event {
                self.event = event
                self.eventNameLabel.text = event.name
                self.eventStartDateLabel.text = event.startDate
                self.eventEndDateLabel.text = event.endDate
                self.eventLocationNameLabel.text = event.locationName
                self.eventLocationAddressLabel.text = event.locationAddress
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let event = event else { return }
        
        if segue.identifier == "editEvent" {
            let navigationController = segue.destination as! UINavigationController
            let editEventController = navigationController.topViewController as! EditEventViewController
            
            self.dateFormatter.dateFormat = "EEEE MMMM dd, yyyy - hh:mm a"
            guard let eventStartDate = self.dateFormatter.date(from: event.startDate) else { return }
            guard let eventEndDate = self.dateFormatter.date(from: event.endDate) else { return }
            
            editEventController.event = event
            editEventController.startDatePicker.date = eventStartDate
            editEventController.endDatePicker.date = eventEndDate
        }
    }
    
    @IBAction func cancelToEventPage(segue: UIStoryboardSegue) { }
    
    @IBAction func saveEventDetails(segue: UIStoryboardSegue) {
        let targetController = segue.source as! EditEventViewController
        
        guard let event = event else { return }
        guard let eventName = targetController.eventTitleTextField.text else { return }
        guard let eventKey = event.key else { return }
        let eventStartDate = targetController.startDatePicker.date
        let eventEndDate = targetController.endDatePicker.date
        let eventLocationName = targetController.locationTextField.text ?? ""
        let eventLocationAddress = targetController.addressTextField.text ?? ""
        
        self.dateFormatter.dateFormat = "EEEE MMMM dd, yyyy - hh:mm a"
        let eventStartDateString = self.dateFormatter.string(from: eventStartDate)
        let eventEndDateString = self.dateFormatter.string(from: eventEndDate)
        
        EventService.update(eventID: eventKey, eventName: eventName, eventStartDate: eventStartDateString, eventEndDate: eventEndDateString, eventLocationName: eventLocationName, eventLocationAddress: eventLocationAddress)
    }
}
