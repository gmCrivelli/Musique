//
//  MainViewController.swift
//  FreestyleWithViews
//
//  Created by Rafael Prado on 28/10/17.
//  Copyright © 2017 DoM7. All rights reserved.
//

import UIKit
import AVFoundation

/// Controls the whole dashboard. Responsible for reading the sheets matrix and playing the song.
/// Also holds all instruments sheets and uses them to play the full song.
class MainViewController: UIViewController {
    
    var matrix:[[Bool]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embed"{
            let sheet = segue.destination as! SheetsController
            sheet.matrixDelegate = self
        }
    }
    
    @IBAction func playSong(_ sender: UIButton) {
        if let matrix = self.matrix{
            for chord in matrix{
                GuitarScale.playChord(chord)
            }
        }
    }
}

extension MainViewController:SheetManagerDelegate{
    func updateSheets(_ noteMatrix: [[Bool]]) {
        self.matrix = noteMatrix
    }
}
