//
//  PFPService.swift
//  Eventcal
//
//  Created by Tina La on 8/14/17.
//  Copyright © 2017 Tina La. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

struct PFPService {

    static func addProfilePicture(for image: UIImage) {
        let uid = User.current.uid
        let imageRef = Storage.storage().reference().child("profile_pictures/\(uid)/pfp.jpg")
        StorageService.uploadImage(image, at: imageRef) { (downloadURL) in
            guard let downloadURL = downloadURL else {
                return
            }
            
            let urlString = downloadURL.absoluteString
            let databaseRef = Database.database().reference().child("pfp_url").child(uid)
            databaseRef.setValue(urlString)
        }
    }
    
    static func retreiveURL(uid: String, completion: @escaping (String?) -> Void) {
        let uid = User.current.uid
        let urlRef = Database.database().reference().child("pfp_url").child(uid)
        urlRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let pfp = snapshot.value as? String else {
                print("was unable to retreive pfp url")
                return completion(nil)
            }
            completion(pfp)
        })
    }
    
}
