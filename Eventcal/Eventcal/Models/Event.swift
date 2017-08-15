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
    
    var dictValueFull: [String : Any] {
        return ["eventName" : name,
                "eventStartDate" : startDate,
                "eventAttendees" : attendees]
    }
    
    var dictValueLite: [String : Any] {
        return ["eventName" : name,
                "eventStartDate" : startDate]
    }
    
    init(eventName: String, eventStartDate: String) {
        self.name = eventName
        self.startDate = eventStartDate
        self.attendees = [String]()
        self.attendees.append(User.current.uid)
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let eventName = dict["eventName"] as? String,
            let eventStartDate = dict["eventStartDate"] as? String,
            let eventAttendees = dict["eventAttendees"] as? [String]
            else { return nil }
        
        self.key = snapshot.key
        self.name = eventName
        self.startDate = eventStartDate
        self.attendees = eventAttendees
    }
}
