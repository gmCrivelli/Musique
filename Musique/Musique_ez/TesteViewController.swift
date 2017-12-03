//
//  TesteViewController.swift
//  Musique_ez
//
//  Created by Rafael Prado on 01/12/17.
//  Copyright © 2017 Gustavo De Mello Crivelli. All rights reserved.
//

import UIKit

class TesteViewController: UIViewController {
    
    var music: MusicPulse?
    
    @IBOutlet weak var scoreField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let mus = music{
            print(mus)
        }else{
            print("não carregou essa merda direito!")
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func okayTap(_ sender: UIButton) {
        let reading = Int(self.scoreField.text!)!
        let score = Int(music!.highestscore)
        if (score < reading){
            self.music?.highestscore = Int16(reading)
        }
        
        let scoreToSave = Score()
        scoreToSave.score = Int16(score)
        let seq = (music?.score.count)!+1
        scoreToSave.sequence = Int16(seq)
        
        ScoreServices.createScore(score: scoreToSave, in: music!, nil)
        MusicServices.updateMusic(music: music!, { (error) in
            if error != nil{
                print(error)
            }
            self.dismiss(animated: true, completion: nil)
            })
    }
}
