//
//  EventsListTableViewController.swift
//  Eventcal
//
//  Created by Tina La on 8/8/17.
//  Copyright © 2017 Tina La. All rights reserved.
//

import UIKit

class EventsListTableViewController: UITableViewController {

    // MARK: - Global variables and viewDidLoad
    let dateFormatter = DateFormatter()
    var selectedDate = Date()
    
    var eventsArray = [Event]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserService.fetchEvents(forUID: User.current.uid) { (events) in
            let todaysEvents = self.filterEventsForToday(events: events)
            self.eventsArray = todaysEvents
        }
        
        /*let eventObjects = eventIDsToEvents(eventIDs: events)
        eventsForToday = filterEventsForToday(events: eventObjects)*/
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventsListTableViewCell", for: indexPath) as! EventListTableViewCell
        
        let index = indexPath.row
        let event = eventsArray[index]
        self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        cell.eventsTitleLabel.text = event.name
        cell.eventDateLabel.text = event.startDate
        
        return cell
    }
    
    // MARK: - Helper functions
    
    func filterEventsForToday(events: [Event]) -> [Event] {
        self.dateFormatter.dateFormat = "yyyy-MM-dd"
        var eventsForToday = [Event]()
        
        for event in events {
            let eventDate = event.startDate
            let todaysDate = self.dateFormatter.string(from: selectedDate)
            if eventDate.range(of: todaysDate) != nil {
                eventsForToday.append(event)
            }
        }
        
        return eventsForToday
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
