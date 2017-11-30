//
//  BasicViewController.swift
//  Musique
//
//  Created by Rafael Prado on 28/11/17.
//  Copyright © 2017 Gustavo De Mello Crivelli. All rights reserved.
//

import UIKit

/// This class gives a basic background to every menu screen on the application.
class BasicViewController: UIViewController {
    
    // Image view for the overlay background image.
    fileprivate var background:UIImageView?
    // Default background color
    fileprivate let defaultColor = UIColor(red: 56/255, green: 146/255, blue: 105/255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets the background color to the default color
        self.view.backgroundColor = defaultColor
        
        // Initializes the ImageView and sets it to the size of the screen.
        self.background = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        // Sets the background image
        self.background?.image = UIImage(named: "Pattern")
        // Ensures the image view has a clear background color
        self.background?.backgroundColor = UIColor.clear
        // Adds the image view to the controller main view
        self.view.addSubview(background!)
        // Ensures the image is behind everything. This prevents the background image form overlapping other UI elements.
        self.view.sendSubview(toBack: background!)
    }
}
