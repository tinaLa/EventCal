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
    var date: String
    var host: User
    
    init(eventName: String, eventDate: String) {
        self.name = eventName
        self.date = eventDate
        self.host = User.current
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let eventName = dict["eventName"] as? String,
            let eventDate = dict["eventDate"] as? String,
            let hostDict = dict["eventHost"] as? [String: String],
            let hostUID = hostDict["hostUID"],
            let hostFirstName = hostDict["hostFirstName"],
            let hostLastName = hostDict["hostLastName"]
            else { return nil }
        
        self.key = snapshot.key
        self.name = eventName
        self.date = eventDate
        self.host = User(uid: hostUID, firstName: hostFirstName, lastName: hostLastName)
    }
    
    var dictValue: [String : Any] {
        let hostDict = ["hostUID" : host.uid,
                        "hostFirstName" : host.firstName,
                        "hostLastName" : host.lastName]
        
        return ["eventName" : name,
                "eventDate" : date,
                "eventHost" : hostDict]
    }
}
