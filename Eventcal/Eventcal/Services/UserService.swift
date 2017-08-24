//
//  UserService.swift
//
//  Created by Mariano Montori on 7/24/17.
//  Copyright © 2017 Mariano Montori. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct UserService {
    static func create(_ firUser: FIRUser, firstName: String, lastName: String, completion: @escaping (User?) -> Void) {
        let userAttrs: [String : Any] = ["firstName": firstName,
                                         "lastName": lastName,
                                         "eventsHosting": [],
                                         "eventsAttending": []]
        
        let ref = Database.database().reference().child("users").child(firUser.uid)
        ref.setValue(userAttrs) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let user = User(snapshot: snapshot)
                completion(user)
            })
        }
    }
    
    static func show(forUID uid: String, completion: @escaping (User?) -> Void) {
        let ref = Database.database().reference().child("users").child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let user = User(snapshot: snapshot) else {
                return completion(nil)
            }
            
            completion(user)
        })
    }
    
    static func fetchEvents(forUID uid: String, completion: @escaping ([Event]) -> Void) {
        let ref = Database.database().reference().child("eventsHosting").child(uid)
        var events = [Event]()
        
        ref.observeSingleEvent(of: .value, with: { (snapshots) in
            guard let snapshots = snapshots.children.allObjects as? [DataSnapshot] else {
                return completion([])
            }
            
            for snapshot in snapshots {
                guard let event = Event(snapshot: snapshot) else {
                    print("something went wrong with fetching events")
                    return
                }
                events.append(event)
            }
            completion(events)
        })
    }
    
    static func deleteUser(forUID uid: String, success: @escaping (Bool) -> Void) {
        let ref = Database.database().reference().child("users")
        let object = [uid : NSNull()]
        ref.updateChildValues(object) { (error, ref) -> Void in
            if let error = error {
                print("error : \(error.localizedDescription)")
                return success(false)
            }
            return success(true)
        }
    }
    
    static func usersExcludingCurrentUser(completion: @escaping ([User]) -> Void) {
        let currentUser = User.current
        let ref = Database.database().reference().child("users")
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                return completion([])
            }
            
            let users =
                snapshot
                    .flatMap(User.init)
                    .filter { $0.uid != currentUser.uid }
            
            let dispatchGroup = DispatchGroup()
            users.forEach { (user) in
                dispatchGroup.enter()

                FriendService.isUserRequested(user) { (isRequested) in
                    user.isRequested = isRequested
                }
                
                FriendService.hasUserRequested(user) { (hasRequested) in
                    user.hasRequested = hasRequested
                }
                
                FriendService.isUserFriend(user) { (isFriend) in
                    user.isFriend = isFriend
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main, execute: {
                completion(users)
            })
        })
    }
}
