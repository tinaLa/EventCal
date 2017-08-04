//
//  CreateEventViewController.swift
//  Eventcal
//
//  Created by Tina La on 8/3/17.
//  Copyright © 2017 Tina La. All rights reserved.
//

import UIKit

class CreateEventViewController: UIViewController {

    @IBOutlet weak var eventTitleTextField: UITextField!
    @IBOutlet weak var dateAndTimeTextField: UITextField!
    
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createDatePicker()
        displayDateAndTime()
    }
    
    func createDatePicker() {
        
        // toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // bar button "done" for toolbar
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonTapped))
        
        toolbar.setItems([flexibleSpace, doneButton], animated: true)
        
        dateAndTimeTextField.inputAccessoryView = toolbar
        dateAndTimeTextField.inputView = datePicker
    }
    
    func doneButtonTapped() {
        displayDateAndTime()
        self.view.endEditing(true)
    }
    
    func displayDateAndTime() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        
        dateAndTimeTextField.text = dateFormatter.string(from: datePicker.date)
    }

}
