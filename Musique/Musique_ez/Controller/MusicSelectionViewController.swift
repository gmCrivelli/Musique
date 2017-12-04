//
//  MusicSelectionViewController.swift
//  Musique_ez
//
//  Created by Rafael Prado on 28/11/17.
//  Copyright © 2017 DoM7. All rights reserved.
//

import UIKit

/// Manages the Music Selection screen before the Pulse activity
class MusicSelectionViewController: BasicViewController {
    
    var musicArray: [MusicPulse]?
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        MusicServices.getAllMusic { (error, response) in
            if (error == nil){
                self.musicArray = response
                self.collectionView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.collectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func goBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // Pass the music for the gameviewcontroller according to the button tag
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "gameSceneSegue"){
            let gameViewController = segue.destination as! GameViewController
            
            let buttonSender = sender as! UIButton
            
            gameViewController.chosenMusic = musicArray![buttonSender.tag]
        }
    }
}

extension MusicSelectionViewController: HorizontalScrollDelegate{
    func scroll(to position: Int){
        if(position>=0 && position<self.musicArray!.count){
            let index = IndexPath(row: position, section: 0)
            self.collectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
        }
    }
}

extension MusicSelectionViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.musicArray?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MusicCell", for: indexPath) as! MusicCollectionViewCell
        
        let music = self.musicArray![indexPath.row]
        
        cell.nameLabel.text = music.name
        
        cell.bestScore.text = String(music.highScore)
        cell.lastScore.text = String(music.lastScore)
        
        cell.playButton.tag = indexPath.row
        cell.nextButton.tag = indexPath.row+1
        cell.previousButton.tag = indexPath.row-1
        
        cell.scrollDelegate = self
        
        return cell
    }
}


