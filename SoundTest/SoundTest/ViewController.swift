//
//  ViewController.swift
//  SoundTest
//
//  Created by Rafael Prado on 15/11/17.
//  Copyright © 2017 DoM7. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let song = URL(fileURLWithPath: Bundle.main.path(forResource: "The_Muffin_Man", ofType: ".mp3")!)
    var musicPlayer:Sound?
    
    @IBOutlet weak var bpmLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        musicPlayer = Sound(url: song)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func play(_ sender: UIButton) {
        self.musicPlayer?.play()
        let _ = BPMAnalyzer.core.getBpmFrom(song, completion: { (bpm) in
            self.bpmLabel.text = String(describing: bpm)
        })
    }
    
    @IBAction func pause(_ sender: Any) {
        self.musicPlayer?.pause()
    }
    
    @IBAction func stop(_ sender: Any) {
        self.musicPlayer?.stop()
    }
}

