//
//  AboutViewController.swift
//  Musique_ez
//
//  Created by Rafael Prado on 06/12/17.
//  Copyright © 2017 DoM7. All rights reserved.
//

import UIKit

class AboutViewController: BasicViewController {

    @IBOutlet weak var topBar: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupShadows()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Setups shadows for the buttons
    fileprivate func setupShadows(){
        // Sets the parameters
        let opacity = Float(0.3)
        let color = UIColor.black.cgColor
        let radius = CGFloat(3)
        
        // Setups shadows for top bar
        topBar.layer.shadowOpacity = opacity
        topBar.layer.shadowRadius = radius
        topBar.layer.shadowOffset = CGSize(width: 0, height: 7)
        topBar.layer.shadowColor = color
    }
}
