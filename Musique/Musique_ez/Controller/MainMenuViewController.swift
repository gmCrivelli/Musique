//
//  MainMenuViewController.swift
//  Musique_ez
//
//  Created by Rafael Prado on 28/11/17.
//  Copyright © 2017 Gustavo De Mello Crivelli. All rights reserved.
//

import UIKit

/// Controls the Main Menu functions
class MainMenuViewController: BasicViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    /// Whenever an activity button is tapped, performs the corresponding segue
    ///
    /// - Parameter sender: Button tapped
    @IBAction func goToActivity(_ sender: UIButton?){
        // Compares the sender tag and performs the segue for each case
        switch sender!.tag{
        case 1:
            performSegue(withIdentifier: "pulseSegue", sender: self)
        case 2:
            print("Testing")
        case 3:
            print("Testing")
        case 4:
            print("Testing")
        default:
            print("ERROR: Button doesn't exist")
        }
    }
}
