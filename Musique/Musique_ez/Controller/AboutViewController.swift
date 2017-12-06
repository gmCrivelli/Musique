//
//  AboutViewController.swift
//  Musique_ez
//
//  Created by Rafael Prado on 06/12/17.
//  Copyright © 2017 DoM7. All rights reserved.
//

import UIKit

class AboutViewController: BasicViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true, completion: nil)
    }

}
