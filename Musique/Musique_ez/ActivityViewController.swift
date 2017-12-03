//
//  ActivityViewController.swift
//  Musique_ez
//
//  Created by Rafael Prado on 01/12/17.
//  Copyright © 2017 Gustavo De Mello Crivelli. All rights reserved.
//

import UIKit

class ActivityViewController: UIViewController {

    var songArray: [MusicPulse]?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        MusicServices.getAllMusic { (error, songs) in
            self.songArray = songs
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "teste"){
            let dest = segue.destination as! TesteViewController
            
            dest.music = self.songArray![0]
        }
    }
}
