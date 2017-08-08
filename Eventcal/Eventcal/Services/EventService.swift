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
    static func create(eventName: String, eventDate: String) {
        
        // write to events branch in database
        let event = Event(eventName: eventName, eventDate: eventDate)
        let eventAttrs: [String : Any] = event.dictValue
        let ref = Database.database().reference().child("events").childByAutoId()
        ref.updateChildValues(eventAttrs)
        
        // write to user branch in database
        let user = User.current
        user.eventsHosting.append(ref.key)
        let userRef = Database.database().reference().child("users").child(user.uid)
        let userAttrs: [String : Any] = user.dictValue
        userRef.updateChildValues(userAttrs)
        
    }
}
