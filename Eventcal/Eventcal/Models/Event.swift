//
//  Event.swift
//  Eventcal
//
//  Created by Tina La on 8/3/17.
//  Copyright © 2017 Tina La. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Event: NSObject {
    
    // MARK: - Event Variables
    var key: String?
    var name: String
    var startDate: String
    var attendees: [String]
    var locationName: String
    var locationAddress: String
    
    var dictValue: [String : Any] {
        return ["eventName" : name,
                "eventStartDate" : startDate,
                "eventAttendees" : attendees,
                "eventLocationName" : locationName,
                "eventLocationAddress" : locationAddress]
    }
    
    init(eventName: String, eventStartDate: String, eventLocationName: String, eventLocationAddress: String) {
        self.name = eventName
        self.startDate = eventStartDate
        self.attendees = [String]()
        self.attendees.append(User.current.uid)
        
        self.locationName = eventLocationName
        self.locationAddress = eventLocationAddress
    }
    
    init?(snapshot: DataSnapshot) {
        
        // required parameters
        guard let dict = snapshot.value as? [String : Any],
            let eventName = dict["eventName"] as? String,
            let eventStartDate = dict["eventStartDate"] as? String,
            let eventAttendees = dict["eventAttendees"] as? [String],
            let eventLocationName = dict["eventLocationName"] as? String,
            let eventAddressName = dict["eventLocationAddress"] as? String
            else { return nil }
        
        self.key = snapshot.key
        self.name = eventName
        self.startDate = eventStartDate
        self.attendees = eventAttendees
        
        // optional parameters
        self.locationName = eventLocationName
        self.locationAddress = eventAddressName
    }
}
