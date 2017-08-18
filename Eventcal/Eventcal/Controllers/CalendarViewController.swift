//
//  CalendarViewController.swift
//  Eventcal
//
//  Created by Tina La on 8/1/17.
//  Copyright © 2017 Tina La. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarViewController: UIViewController {
    
    // MARK: - Outlets and global variables
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var calendarMonth: UILabel!
    @IBOutlet weak var eventTableView: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    let dateFormatter = DateFormatter()
    
    var eventsArray = [Event]() {
        didSet { eventTableView.reloadData() }
    }
    
    // MARK: - Present side menu
    func presentSideMenu() {
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rearViewRevealWidth = 275
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    // MARK: - viewDidLoad and segues
    override func viewDidLoad() {
        super.viewDidLoad()
        presentSideMenu()
        setUpCalendar()
    }
    
    @IBAction func cancelToCalendar(segue: UIStoryboardSegue) { }
    
    @IBAction func saveEventDetails(segue: UIStoryboardSegue) {
        let targetController = segue.source as! CreateEventViewController
        
        guard let eventName = targetController.eventTitleTextField.text else { return }
        let eventStartDate = targetController.startDatePicker.date
        let eventEndDate = targetController.endDatePicker.date
        let eventLocationName = targetController.locationTextField.text ?? ""
        let eventLocationAddress = targetController.addressTextField.text ?? ""
        
        self.dateFormatter.dateFormat = "EEEE MMMM dd, yyyy - hh:mm a"
        let eventStartDateString = self.dateFormatter.string(from: eventStartDate)
        let eventEndDateString = self.dateFormatter.string(from: eventEndDate)
        
        EventService.create(eventName: eventName, eventStartDate: eventStartDateString, eventEndDate: eventEndDateString, eventLocationName: eventLocationName, eventLocationAddress: eventLocationAddress)
        
        setUpEventTableView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCreateEvent" {
            let destinationNavigationController = segue.destination as! UINavigationController
            let targetController = destinationNavigationController.topViewController as! CreateEventViewController
            
            var selectedStart = calendarView.selectedDates[0]
            self.dateFormatter.dateFormat = "MMMM dd, yyyy"
            if self.dateFormatter.string(from: selectedStart) == self.dateFormatter.string(from: Date()) {
                selectedStart = Date()
            }
            let defaultEnd = selectedStart.addingTimeInterval(60.0 * 60.0)
            
            targetController.startDatePicker.date = selectedStart
            targetController.endDatePicker.date = defaultEnd
            targetController.endDatePicker.minimumDate = selectedStart.addingTimeInterval(60.0)
        }
        
        else if segue.identifier == "displayEventDetails" {
            let indexPath = eventTableView.indexPathForSelectedRow!
            let event = eventsArray[indexPath.row]
            let displayEventViewController = segue.destination as! DisplayEventViewController
            displayEventViewController.event = event
        }
    }
    
    // MARK: - Calendar UI Configuration
    func setUpCalendar() {
        
        // setting initial displayed month and selecting today's date
        calendarView.scrollToDate(Date(), animateScroll: false)
        calendarView.selectDates([Date()])
        
        // adjusting spacing for each date cell
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        // calling helper function to fill in month and year
        calendarView.visibleDates { (visibleDates) in
            self.setUpCalendarViews(from: visibleDates)
        }
        
    }
    
    func setUpCalendarViews(from visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first!.date
        
        self.dateFormatter.dateFormat = "MMMM yyyy"
        self.calendarMonth.text = self.dateFormatter.string(from: date)
    }
    
    // MARK: - Cell Configuration
    func configureCells(cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? CustomCell else { return }
        handleCellSelection(cell: validCell, cellState: cellState)
        handleCellTextColor(cell: validCell, cellState: cellState)
        handleCellVisibility(cell: validCell, cellState: cellState)
    }
    
    func handleCellSelection(cell: CustomCell, cellState: CellState) {
        if cellState.isSelected {
            cell.selectedView.isHidden = false
        } else {
            cell.selectedView.isHidden = true
        }
    }
    
    func handleCellTextColor(cell: CustomCell, cellState: CellState) {
        if cellState.isSelected {
            cell.dateLabel.textColor = .black
        } else if cellState.dateBelongsTo == .thisMonth {
                cell.dateLabel.textColor = .white
        }
    }
    
    func handleCellVisibility(cell: CustomCell, cellState: CellState) {
        if cellState.dateBelongsTo == .thisMonth {
            cell.isHidden = false
        } else {
            cell.isHidden = true
        }
    }
    
    // MARK: - Setting up event table view
    func setUpEventTableView() {
        calendarView.visibleDates { (visibleDates) in
            UserService.fetchEvents(forUID: User.current.uid) { (events) in
                let todaysEvents = self.sortEventsForMonth(events: events, from: visibleDates)
                self.eventsArray = todaysEvents
            }
        }
    }
    
    func sortEventsForMonth(events: [Event], from visibleDates: DateSegmentInfo) -> [Event] {
        var eventsForToday = [Event]()
        
        for event in events {
            let eventDate = event.startDate
            let todaysDateObject = visibleDates.monthDates.first!.date
            
            self.dateFormatter.dateFormat = "MMMM"
            let todaysDate = self.dateFormatter.string(from: todaysDateObject)
            
            if eventDate.range(of: todaysDate) != nil {
                if eventsForToday.count == 0 {
                    eventsForToday.append(event)
                } else {
                    eventsForToday = insertInChronologicalOrder(newEvent: event, events: eventsForToday)
                }
            }
        }
        
        return eventsForToday
    }
    
    func insertInChronologicalOrder(newEvent: Event, events: [Event]) -> [Event] {
        self.dateFormatter.dateFormat = "EEEE MMMM dd, yyyy - hh:mm a"
        var newEventArray = events
        var eventAdded = false
        let newEventDate = self.dateFormatter.date(from: newEvent.startDate)
        
        for i in 0..<events.count {
            let currentEvent = events[i]
            
            guard let currentEventDate = self.dateFormatter.date(from: currentEvent.startDate) else {
                print("something went wrong with date conversion")
                return []
            }
            
            if newEventDate?.compare(currentEventDate) == ComparisonResult.orderedAscending {
                newEventArray.insert(newEvent, at: i)
                eventAdded = true
                break
            }
            
        }
        
        if eventAdded == false {
            newEventArray.append(newEvent)
        }
        
        return newEventArray
    }
}

extension CalendarViewController: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        dateFormatter.dateFormat = "yyyy MM dd"
        dateFormatter.timeZone = Calendar.current.timeZone
        dateFormatter.locale = Calendar.current.locale
        
        let startDate = dateFormatter.date(from: "2017 01 01")!
        let endDate = dateFormatter.date(from: "2017 12 31")!
        
        let parameters = ConfigurationParameters(
            startDate: startDate,
            endDate: endDate,
            numberOfRows: 6,
            calendar: Calendar.current,
            generateInDates: .forAllMonths,
            generateOutDates: .tillEndOfRow,
            firstDayOfWeek: .sunday,
            hasStrictBoundaries: true)
        return parameters
    }
}

extension CalendarViewController: JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
        
        cell.dateLabel.text = cellState.text
        
        configureCells(cell: cell, cellState: cellState)
        
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCells(cell: cell, cellState: cellState)
        cell?.bounce()
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCells(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        return cellState.dateBelongsTo == .thisMonth
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setUpCalendarViews(from: visibleDates)
        setUpEventTableView()
    }
}

extension UIView {
    func bounce() {
        self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(
            withDuration: 0.5,
            delay: 0, usingSpringWithDamping: 0.3,
            initialSpringVelocity: 0.1,
            options: UIViewAnimationOptions.beginFromCurrentState,
            animations: {
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        )
    }
}

extension CalendarViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventsListTableViewCell", for: indexPath) as! EventListTableViewCell
        
        let index = indexPath.row
        let event = eventsArray[index]
        self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        cell.eventNameLabel.text = event.name
        cell.eventDateLabel.text = event.startDate
        
        return cell
    }
}

extension CalendarViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
