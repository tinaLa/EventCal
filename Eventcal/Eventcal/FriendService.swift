//
//  FriendService.swift
//  Eventcal
//
//  Created by Tina La on 8/21/17.
//  Copyright © 2017 Tina La. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct FriendService {
    
    static func sendFriendRequest(_ user: User, success: @escaping (Bool) -> Void) {
        let currentUID = User.current.uid
        let requestData = ["requests_received/\(user.uid)/\(currentUID)" : true,
                          "requests_sent/\(currentUID)/\(user.uid)" : true]
        
        let ref = Database.database().reference()
        ref.updateChildValues(requestData) { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
            }
            success(error == nil)
        }
    }
    
    static func deleteFriendRequest(_ user: User, success: @escaping (Bool) -> Void) {
        let currentUID = User.current.uid
        let requestData = ["requests_received/\(user.uid)/\(currentUID)" : NSNull(),
                           "requests_sent/\(currentUID)/\(user.uid)" : NSNull()]
        
        let ref = Database.database().reference()
        ref.updateChildValues(requestData) { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
            }
            success(error == nil)
        }
    }
    
    static func acceptFriendRequest(_ user: User, success: @escaping (Bool) -> Void) {
        let currentUID = User.current.uid
        let friendData = ["friends/\(user.uid)/\(currentUID)" : true,
                          "friends/\(currentUID)/\(user.uid)" : true]
        
        let ref = Database.database().reference()
        ref.updateChildValues(friendData) { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
            }
            deleteFriendRequest(user, success: success)
        }
    }
    
    static func deleteFriend(_ user: User, success: @escaping (Bool) -> Void) {
        let currentUID = User.current.uid
        let friendData = ["friends/\(user.uid)/\(currentUID)" : NSNull(),
                          "friends/\(currentUID)/\(user.uid)" : NSNull()]
        
        let ref = Database.database().reference()
        ref.updateChildValues(friendData) { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
            }
            success(error == nil)
        }
    }
}
