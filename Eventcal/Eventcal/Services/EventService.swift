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
    static func create(for event: Event, eventName: String, eventDate: Date, success: @escaping (Bool) -> Void) {
        guard let key = event.key else {
            return success(false)
        }
        
        let eventAttrs: [String : Any] = ["name": eventName, "date": eventDate]
        
        let ref = Database.database().reference().child("events").child(key)
        ref.setValue(eventAttrs) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return success(false)
            } else {
                return success(true)
            }
        }
    }
}
