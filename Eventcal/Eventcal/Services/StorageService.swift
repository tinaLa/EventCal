//
//  StorageService.swift
//  Eventcal
//
//  Created by Tina La on 8/14/17.
//  Copyright © 2017 Tina La. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

struct StorageService {
    
    static func uploadImage(_ image: UIImage, at reference: StorageReference, completion: @escaping (URL?) -> Void) {

        guard let imageData = UIImageJPEGRepresentation(image, 0.1) else {
            print("couldn't convert image to data")
            return completion(nil)
        }
        
        reference.putData(imageData, metadata: nil, completion: { (metadata, error) in
            
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            
            completion(metadata?.downloadURL())
        })
    }
}
