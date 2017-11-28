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
    
    @IBAction func goToActivity(_ sender: UIButton?){
        switch sender!.tag{
        case 1:
            performSegue(withIdentifier: "pulseSegue", sender: self)
        default:
            print("ERROR: Button doesn't exist")
        }
    }
}
