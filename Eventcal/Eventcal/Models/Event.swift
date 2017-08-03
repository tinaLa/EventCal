//
//  Event.swift
//  Eventcal
//
//  Created by Tina La on 8/3/17.
//  Copyright © 2017 Tina La. All rights reserved.
//

import Foundation

class Event: NSObject {
    
    // MARK: - Event Variables
    var eventName: String
    var eventDate: Date
    
    init(eventName: String, eventDate: Date) {
        self.eventName = eventName
        self.eventDate = eventDate
    }
}
