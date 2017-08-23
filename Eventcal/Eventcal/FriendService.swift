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
    
    static func setIsRequested(_ isRequested: Bool, fromCurrentUserTo newFriend: User, success: @escaping (Bool) -> Void) {
        if isRequested {
            sendFriendRequest(newFriend, success: success)
        } else {
            deleteFriendRequest(newFriend, success: success)
        }
    }
    
    static func isUserRequested(_ user: User, byCurrentUserWithCompletion completion: @escaping (Bool) -> Void) {
        let currentUID = User.current.uid
        let ref = Database.database().reference().child("requests_sent").child(currentUID)
        
        ref.queryEqual(toValue: nil, childKey: user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? [String : Bool] {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    static func isUserFriend(_ user: User, byCurrentUserWithCompletion completion: @escaping (Bool) -> Void) {
        let currentUID = User.current.uid
        let ref = Database.database().reference().child("friends").child(user.uid)
        
        ref.queryEqual(toValue: nil, childKey: currentUID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? [String : Bool] {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    static func fetchFriendRequests(success: @escaping ([User]) -> Void) {
        let currentUID = User.current.uid
        let ref = Database.database().reference().child("requests_received").child(currentUID)
        var requests = [User]()
        
        ref.observeSingleEvent(of: .value, with: { (snapshots) in
            guard let snapshots = snapshots.children.allObjects as? [DataSnapshot] else {
                return success([])
            }
            
            for snapshot in snapshots {
                guard let user = User(snapshot: snapshot) else {
                    print("something went wrong with fetching friend requests")
                    return
                }
                requests.append(user)
            }
            success(requests)
        })
    }
    
    static func fetchFriends(uid: String, success: @escaping ([User]) -> Void) {
        let ref = Database.database().reference().child("friends").child(uid)
        var friends = [User]()
        
        ref.observeSingleEvent(of: .value, with: { (snapshots) in
            guard let snapshots = snapshots.children.allObjects as? [DataSnapshot] else {
                return success([])
            }
            
            for snapshot in snapshots {
                guard let user = User(snapshot: snapshot) else {
                    print("something went wrong with fetching friends")
                    return
                }
                friends.append(user)
            }
            success(friends)
        })
    }
}
