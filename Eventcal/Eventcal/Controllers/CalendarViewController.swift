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
    
    // MARK: - Outlets and Date Formatter
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var calendarMonth: UILabel!
    @IBOutlet weak var calendarYear: UILabel!
    
    let formatter = DateFormatter()
    
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
    

    // MARK: - viewDidLoad and segues
    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenu()
        setUpCalendar()
        embeddedSegue()
    }
    
    @IBAction func saveEventDetails(segue: UIStoryboardSegue) {
        let targetController = segue.source as! CreateEventViewController
        
        guard let eventName = targetController.eventTitleTextField.text else { return }
        let eventDate = targetController.datePicker.date
        
        self.formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let eventDateString = self.formatter.string(from: eventDate)
        
        EventService.create(eventName: eventName, eventDate: eventDateString)
    }
    
    func embeddedSegue() {
        func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "toEventList" {
                let destinationViewController = segue.destination as! EventsListTableViewController
                destinationViewController.selectedDate = calendarView.selectedDates[0]
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCreateEvent" {
            let destinationNavigationController = segue.destination as! UINavigationController
            let targetController = destinationNavigationController.topViewController as! CreateEventViewController
            targetController.datePicker.date = calendarView.selectedDates[0]
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
        
        self.formatter.dateFormat = "yyyy"
        self.calendarYear.text = self.formatter.string(from: date)
        
        self.formatter.dateFormat = "MMMM"
        self.calendarMonth.text = self.formatter.string(from: date)
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
}

extension CalendarViewController: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = formatter.date(from: "2017 01 01")!
        let endDate = formatter.date(from: "2017 12 31")!
        
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
