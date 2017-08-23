//
//  User.swift
//
//  Created by Mariano Montori on 7/24/17.
//  Copyright © 2017 Mariano Montori. All rights reserved.
//
import Foundation
import UIKit
import FirebaseDatabase.FIRDataSnapshot
import FBSDKCoreKit

class User : NSObject {
    
    // User variables
    let uid : String
    let firstName : String
    let lastName : String
    
    var dictValue: [String : Any] {
        return ["firstName" : firstName,
                "lastName" : lastName]
    }
    
    var isRequested = false
    var hasRequested = false
    var isFriend = false
    
    // Standard User init()
    init(uid: String, firstName: String, lastName: String) {
        self.uid = uid
        self.firstName = firstName
        self.lastName = lastName
        super.init()
    }
    
    // User init using Firebase snapshots
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let firstName = dict["firstName"] as? String,
            let lastName = dict["lastName"] as? String
            else { return nil }
        self.uid = snapshot.key
        self.firstName = firstName
        self.lastName = lastName
    }
    
    // UserDefaults   // bug may be here :)
    required init?(coder aDecoder: NSCoder) {
        guard let uid = aDecoder.decodeObject(forKey: "uid") as? String,
            let firstName = aDecoder.decodeObject(forKey: "firstName") as? String,
            let lastName = aDecoder.decodeObject(forKey: "lastName") as? String
            else { return nil }
        
        self.uid = uid
        self.firstName = firstName
        self.lastName = lastName
        super.init()
    }
    
    
    //User singleton for currently logged user
    private static var _current: User?
    
    static var current: User {
        guard let currentUser = _current else {
            fatalError("Error: current user doesn't exist")
        }
        
        return currentUser
    }
    
    class func setCurrent(_ user: User, writeToUserDefaults: Bool = false) {
        if writeToUserDefaults {
            let data = NSKeyedArchiver.archivedData(withRootObject: user)
            
            UserDefaults.standard.set(data, forKey: "currentUser")
        }
        
        _current = user
    }
    
    /*class func getFacebookFirstName() -> String? {
        var firstName: String?
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields" : "first_name"]).start { (connection, result, error) in
            if error != nil {
                print("failed to start graph request")
                return
            }
            let dict = result as! [String: Any]
            if let fetchName = dict["first_name"] {
                firstName = String(describing: fetchName)
            }
            print(firstName!)
        }
        return firstName
    }
    
    class func getFacebookLastName() -> String? {
        var lastName: String?
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields" : "last_name"]).start { (connection, result, error) in
            if error != nil {
                print("failed to start graph request")
                return
            }
            
            lastName = String(describing: result)
        }
        return lastName
    }*/

}

extension User: NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(uid, forKey: "uid")
        aCoder.encode(firstName, forKey: "firstName")
        aCoder.encode(lastName, forKey: "lastName")
    }
}
