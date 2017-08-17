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

    @IBOutlet weak var eventTitleTextField: UITextField!
    @IBOutlet weak var dateAndTimeTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    
    let datePicker = UIDatePicker()
    var placesClient: GMSPlacesClient!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createDatePicker()
        displayDateAndTime()
        placesClient = GMSPlacesClient.shared()
    }
    
    // MARK: - Event Date and Time
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
            self.locationTextField.text = "\(placeName) \(placeAddress)"
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
