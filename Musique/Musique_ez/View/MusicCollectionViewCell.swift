//
//  MusicCollectionViewCell.swift
//  Musique_ez
//
//  Created by Rafael Prado on 04/12/17.
//  Copyright © 2017 DoM7. All rights reserved.
//

import UIKit

protocol HorizontalScrollDelegate{
    func scroll(to position:Int)
}

class MusicCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bestScore: UILabel!
    @IBOutlet weak var lastScore: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    
    @IBOutlet weak var playButton: UIButton!
    
    var scrollDelegate:HorizontalScrollDelegate?
    
    @IBAction func playGame(_ sender: UIButton) {
    }
    
    @IBAction func nextMusic(_ sender: UIButton) {
        scrollDelegate?.scroll(to: sender.tag)
    }
    
    @IBAction func prevMusic(_ sender: UIButton) {
        scrollDelegate?.scroll(to: sender.tag)
    }
}
