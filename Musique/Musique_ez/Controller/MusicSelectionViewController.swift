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
    
    let songs = ["Funny Song", "Dancing on Green Grass", "Splashing Around"]
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Add 
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let gameViewController = segue.destination as! GameViewController
        
        
    }
}

extension MusicSelectionViewController: HorizontalScrollDelegate{
    func scroll(to position: Int){
        if(position>=0 && position<self.songs.count){
            let index = IndexPath(row: position, section: 0)
            self.collectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
        }
    }
}

extension MusicSelectionViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.songs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MusicCell", for: indexPath) as! MusicCollectionViewCell
        
        cell.nameLabel.text = self.songs[indexPath.row]
        
        cell.playButton.tag = indexPath.row
        cell.nextButton.tag = indexPath.row+1
        cell.previousButton.tag = indexPath.row-1
        
        cell.scrollDelegate = self
        
        return cell
    }
}


