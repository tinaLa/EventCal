//
//  InitialScreenViewController.swift
//  Eventcal
//
//  Created by Tina La on 8/7/17.
//  Copyright © 2017 Tina La. All rights reserved.
//

import UIKit

class InitialScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func unwindToInitial(_ segue: UIStoryboardSegue) {
        print("Returned to initial screen!")
    }

}
