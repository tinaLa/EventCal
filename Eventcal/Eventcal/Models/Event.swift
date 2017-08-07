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
    var date: Date
    
    init(eventName: String, eventDate: Date) {
        self.name = eventName
        self.date = eventDate
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let eventName = dict["eventName"] as? String,
            let eventDate = dict["eventDate"] as? Date
            else { return nil }
        self.key = snapshot.key
        self.name = eventName
        self.date = eventDate
    }
}
