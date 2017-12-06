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
    // Array that holds data brougth from the database
    var musicArray: [MusicPulse]?
    // Collection View Outlet property
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Sets the collection view delegate and dataSource properties to self
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        // Fetches all Music entities on the bank
        MusicServices.getAllMusic { (error, response) in
            if (error == nil){
                // Inserts the return value into the array
                self.musicArray = response
                // Reloads data from the collectionView
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
    
    /// Pops to previous view controller
    ///
    /// - Parameter sender: button that fired action
    @IBAction func goBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    /// Prepares parameters to be passed on to the next view controller
    ///
    /// - Parameters:
    ///   - segue: segue being performed
    ///   - sender: object that fires the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If the segue is leading to the Game View Controller...
        if(segue.identifier == "gameSceneSegue"){
            // Gets the destination as the exxpected type
            let gameViewController = segue.destination as! GameViewController
            // Casts the sender down as a button
            let buttonSender = sender as! UIButton
            // Sets the music property on the destination to hold the selected song
            gameViewController.chosenMusic = musicArray![buttonSender.tag]
        }
    }
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.landscapeLeft, .landscapeRight]
    }
    
}


// MARK: - Horizontal Scroll Delegate
extension MusicSelectionViewController: HorizontalScrollDelegate{
    
    /// Scrolls the collection view to provided item at index
    ///
    /// - Parameter position: index to which the view should scroll
    func scroll(to position: Int){
        // Checks if the position is within the limits
        if(position>=0 && position<self.musicArray!.count){
            // Creates an Index Path object
            let index = IndexPath(row: position, section: 0)
            // Scrolls the collection to the item at index
            self.collectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
        }
    }
}

// MARK: - UICollectionView DataSource and Delegate
extension MusicSelectionViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    /// Returns the number of items to be placed on the CollectionView
    ///
    /// - Parameters:
    ///   - collectionView: collectionView to which the cell belongs
    ///   - section: section being evaluated
    /// - Returns: number of items in section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.musicArray?.count ?? 0
    }
    
    /// Returns the cell to be used at a given position
    ///
    /// - Parameters:
    ///   - collectionView: collectionView to which the cell belongs
    ///   - indexPath: indexPath in which the cell will be positioned
    /// - Returns: the cell itself
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Loads the cell from a reusable model and casts it to the class that will be used
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MusicCell", for: indexPath) as! MusicCollectionViewCell
        // Gets the corresponding song from the music array
        let music = self.musicArray![indexPath.row]
        
        // Sets the cell name label
        cell.nameLabel.text = music.name
        // Sets both score labels to the values loaded
        cell.bestScore.text = String(music.highScore)
        cell.lastScore.text = String(music.lastScore)
        // Sets the button tag properties to next and previous indexes
        cell.nextButton.tag = indexPath.row+1
        cell.previousButton.tag = indexPath.row-1
        
        print(cell.nameLabel.text, cell.previousButton.tag, cell.nextButton.tag, self.musicArray!.count)
        
        // Checks if the button should be displayed.
        cell.previousButton.isHidden = (cell.previousButton.tag < 0)
        
        cell.nextButton.isHidden = (cell.nextButton.tag > self.musicArray!.count-1)
        
        
        // Sets the tag of the play button to identify the music being selected
        cell.playButton.tag = indexPath.row
        // Sets the cell scrollDelegate property to self
        cell.scrollDelegate = self
        
        return cell
    }
}


