//
//  EventService.swift
//  Eventcal
//
//  Created by Tina La on 8/4/17.
//  Copyright © 2017 Tina La. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct EventService {
    
    static func create(eventName: String, eventStartDate: String, eventEndDate: String, eventLocationName: String, eventLocationAddress: String) {
        
        let event = Event(eventName: eventName, eventStartDate: eventStartDate, eventEndDate: eventEndDate, eventLocationName: eventLocationName, eventLocationAddress: eventLocationAddress)
        let eventAttrs: [String : Any] = event.dictValue
        
        // write to eventInfo branch in database
        let eventInfoRef = Database.database().reference().child("eventInfo").childByAutoId()
        let eventID = eventInfoRef.key
        eventInfoRef.updateChildValues(eventAttrs)
        
        // write to eventsHosting branch in database
        let user = User.current
        let eventsHostingRef = Database.database().reference().child("eventsHosting").child(user.uid).child(eventID)
        eventsHostingRef.updateChildValues(eventAttrs)
        
    }
    
    // test this
    static func show(eventID: String, completion: @escaping (Event?) -> Void) {
        let eventRef = Database.database().reference().child("eventInfo").child(eventID)
        eventRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let event = Event(snapshot: snapshot) else {
                return completion(nil)
            }
            completion(event)
        })
    }
    
    static func update(eventID: String, eventName: String, eventStartDate: String, eventEndDate: String, eventLocationName: String, eventLocationAddress: String) {
        
        let event = Event(eventName: eventName, eventStartDate: eventStartDate, eventEndDate: eventEndDate, eventLocationName: eventLocationName, eventLocationAddress: eventLocationAddress)
        let eventAttrs: [String : Any] = event.dictValue
        
        // write to eventInfo branch in database
        let eventInfoRef = Database.database().reference().child("eventInfo").child(eventID)
        eventInfoRef.updateChildValues(eventAttrs)
        
        // write to eventsHosting branch in database
        let user = User.current
        let eventsHostingRef = Database.database().reference().child("eventsHosting").child(user.uid).child(eventID)
        eventsHostingRef.updateChildValues(eventAttrs)
    }
}
