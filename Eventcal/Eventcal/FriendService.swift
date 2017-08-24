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
        let requestData = [
            "requests_received/\(user.uid)/\(currentUID)" : NSNull(),
            "requests_received/\(currentUID)/\(user.uid)" : NSNull(),
            "requests_sent/\(user.uid)/\(currentUID)" : NSNull(),
            "requests_sent/\(currentUID)/\(user.uid)" : NSNull(),
        ]
        
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
    
    static func hasUserRequested(_ user: User, byCurrentUserWithCompletion completion: @escaping (Bool) -> Void) {
        let currentUID = User.current.uid
        let ref = Database.database().reference().child("requests_sent").child(user.uid)
        
        ref.queryEqual(toValue: nil, childKey: currentUID).observeSingleEvent(of: .value, with: { (snapshot) in
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
    
    private static func fetchRequestUIDs(success: @escaping ([String]?) -> Void) {
        let currentUID = User.current.uid
        let ref = Database.database().reference().child("requests_received").child(currentUID)
        var requests = [String]()
        
        ref.observeSingleEvent(of: .value, with: { (snapshots) in
            guard let snapshots = snapshots.children.allObjects as? [DataSnapshot] else {
                return success([])
            }
            
            for snapshot in snapshots {
                let user_uid = snapshot.key
                requests.append(user_uid)
            }
            
            success(requests)
        })
    }
    
    static func fetchFriendRequests(success: @escaping ([User]?) -> Void) {
        FriendService.fetchRequestUIDs { (uids) in
            guard let uids = uids else { return }
            var requests = [User]()
            
            let dispatchGroup = DispatchGroup()
            uids.forEach { (uid) in
                dispatchGroup.enter()
                
                UserService.show(forUID: uid, completion: { (user) in
                    guard let user = user else { return }
                    user.hasRequested = !user.hasRequested
                    requests.append(user)
                    dispatchGroup.leave()
                })
            }
            
            dispatchGroup.notify(queue: .main, execute: {
                success(requests)
            })
        }
    }
    
    private static func fetchFriendUIDs(uid: String, success: @escaping ([String]?) -> Void) {
        let ref = Database.database().reference().child("friends").child(uid)
        var friends = [String]()
        
        ref.observeSingleEvent(of: .value, with: { (snapshots) in
            guard let snapshots = snapshots.children.allObjects as? [DataSnapshot] else {
                return success([])
            }
            for snapshot in snapshots {
                let user_uid = snapshot.key
                friends.append(user_uid)
            }
            success(friends)
        })
    }
    
    static func fetchFriends(uid: String, success: @escaping ([User]) -> Void) {
        FriendService.fetchFriendUIDs(uid: uid) { (uids) in
            guard let uids = uids else { return }
            var friends = [User]()
            
            let dispatchGroup = DispatchGroup()
            uids.forEach { (uid) in
                dispatchGroup.enter()
                
                UserService.show(forUID: uid, completion: { (user) in
                    guard let user = user else { return }
                    user.isFriend = true
                    friends.append(user)
                    dispatchGroup.leave()
                })
            }
            
            dispatchGroup.notify(queue: .main, execute: {
                success(friends)
            })
        }
    }
}
