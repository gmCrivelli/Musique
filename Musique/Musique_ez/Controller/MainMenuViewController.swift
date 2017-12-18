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

    /// Array referencing all buttons from the menu
    @IBOutlet var menuButtons: [UIButton]!
    @IBOutlet weak var topBar: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup button shadows
        setupShadows()
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
            performSegue(withIdentifier: "aboutSegue", sender: self)
        }
    }
    
    /// Setups shadows for the buttons
    fileprivate func setupShadows(){
        // Sets the parameters
        let opacity = Float(0.3)
        let offset = CGSize(width: -7, height: 7)
        let color = UIColor.black.cgColor
        let radius = CGFloat(3)
        
        // Applies parameters for each button
        for button in self.menuButtons{
            button.layer.shadowOpacity = opacity
            button.layer.shadowRadius = radius
            button.layer.shadowOffset = offset
            button.layer.shadowColor = color
        }
        
        // Setups shadows for top bar
        topBar.layer.shadowOpacity = opacity
        topBar.layer.shadowRadius = radius
        topBar.layer.shadowOffset = CGSize(width: 0, height: 7)
        topBar.layer.shadowColor = color
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.landscapeLeft, .landscapeRight]
    }
}
