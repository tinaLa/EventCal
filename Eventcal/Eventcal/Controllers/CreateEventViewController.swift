//
//  CreateEventViewController.swift
//  Eventcal
//
//  Created by Tina La on 8/3/17.
//  Copyright © 2017 Tina La. All rights reserved.
//

import UIKit
import GooglePlaces

class CreateEventViewController: UIViewController {

    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var eventTitleTextField: UITextField!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    
    let startDatePicker = UIDatePicker()
    let endDatePicker = UIDatePicker()
    let dateFormatter = DateFormatter()
    
    var placesClient: GMSPlacesClient!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createDatePickers()
        startDisplayDateAndTime()
        endDisplayDateAndTime()
        placesClient = GMSPlacesClient.shared()
    }
    
    @IBAction func eventTitleEntered(_ sender: Any) {
        if eventTitleTextField.text?.isEmpty == false {
            saveBarButton.isEnabled = true
        } else {
            saveBarButton.isEnabled = false
        }
    }
    
    // MARK: - Event Date and Time
    func createDatePickers() {
        // toolbars
        let startToolbar = UIToolbar()
        let endToolbar = UIToolbar()
        
        startToolbar.sizeToFit()
        endToolbar.sizeToFit()
        
        // setting bar buttons
        let startFlexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let startDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(startDoneButtonTapped))
        startToolbar.setItems([startFlexibleSpace, startDoneButton], animated: true)
        
        let endFlexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let endDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(endDoneButtonTapped))
        endToolbar.setItems([endFlexibleSpace, endDoneButton], animated: true)
        
        startDateTextField.inputAccessoryView = startToolbar
        startDateTextField.inputView = startDatePicker
        
        endDateTextField.inputAccessoryView = endToolbar
        endDateTextField.inputView = endDatePicker
    }
    
    func startDoneButtonTapped() {
        offsetEndDate()
        startDisplayDateAndTime()
        self.view.endEditing(true)
    }
    
    func startDisplayDateAndTime() {
        self.dateFormatter.dateStyle = .long
        self.dateFormatter.timeStyle = .short
        startDateTextField.text = self.dateFormatter.string(from: startDatePicker.date)
    }
    
    func endDoneButtonTapped() {
        endDisplayDateAndTime()
        self.view.endEditing(true)
    }
    
    func endDisplayDateAndTime() {
        endDateTextField.text = self.dateFormatter.string(from: endDatePicker.date)
    }
    
    func offsetEndDate() {
        endDatePicker.date = startDatePicker.date.addingTimeInterval(60.0 * 60.0)
        endDisplayDateAndTime()
    }
    
    // MARK: - Event Location
    @IBAction func locationTextFieldTapped(_ sender: Any) {
        locationManager.requestWhenInUseAuthorization()
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        getCurrentLocation { (coordinates) in
            guard let currentLatitude = coordinates?.latitude else { return }
            guard let currentLongitude = coordinates?.longitude else { return }
            
            let northeastBounds = CLLocationCoordinate2D(latitude: currentLatitude + 5.0, longitude: currentLongitude + 5.0)
            let southwestBounds = CLLocationCoordinate2D(latitude: currentLatitude - 5.0, longitude: currentLongitude - 5.0)
            
            autocompleteController.autocompleteBounds = GMSCoordinateBounds(coordinate: northeastBounds, coordinate: southwestBounds)
        }
        
        present(autocompleteController, animated: true, completion: nil)
    }
    
    func getCurrentLocation(completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                    completion(place.coordinate)
                }
            }
        })
    }
    
}

extension CreateEventViewController: GMSAutocompleteViewControllerDelegate {
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let placeName = place.name
        guard let placeAddress = place.formattedAddress else { return }
        
        dismiss(animated: true) {
            self.locationTextField.text = "\(placeName)"
            self.addressTextField.text = "\(placeAddress)"
        }
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: something went wrong with Google Places", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
