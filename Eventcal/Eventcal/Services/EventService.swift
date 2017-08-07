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
        
        let event = Event(eventName: eventName, eventDate: eventDate)
        
        let eventAttrs: [String : Any] = event.dictValue
        
        let ref = Database.database().reference().child("events").childByAutoId()
        
        ref.updateChildValues(eventAttrs)
    }
}
