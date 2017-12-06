//
//  EndScreenViewController.swift
//  
//
//  Created by Carlos Marcelo Tonisso Junior on 12/3/17.
//

import UIKit
import AVFoundation

class EndScreenViewController: BasicViewController {
    
    @IBOutlet weak var scoreLabel: UILabel!
    var player : AVAudioPlayer?
    
    var score : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scoreLabel.text = score + "%"
        
        rollTheDrums()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func rollTheDrums(){
        
        guard let url = Bundle.main.url(forResource: "drum_roll", withExtension: "wav") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            guard let player = player else { return }
            
            player.play()
            
            print("\(player.duration)")
            
            animateResult(duration: player.duration)
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func animateResult(duration:Double) {
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
