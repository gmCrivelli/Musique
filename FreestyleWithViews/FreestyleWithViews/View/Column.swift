//
//  Column.swift
//  FreestyleWithViews
//
//  Created by Rafael Prado on 27/10/17.
//  Copyright © 2017 DoM7. All rights reserved.
//

import UIKit

/// Delegate protocol to handle the notes matrix update process
protocol NoteMatrixUpdateDelegate{
    func updateMatrix(with array: [Bool], onColumn index: Int)
}

class Column: UIStackView {
    
    // Image name constants
    let greenIcon = UIImage(named: "green")
    let redIcon = UIImage(named: "red")
    
    // NoteMatrixDelegate instance
    var matrixDelegate:NoteMatrixUpdateDelegate?
    
    // Array holds current state of the column
    var buttonArray = [false,false,false,false,false,false,false,false,false,false]
    
    /// Whenever a button is pressed, changes its visual state and the position on the array corresponding to it.
    ///
    /// - Parameter sender: Button receiving tap.
    @IBAction func buttonTap(_ sender: UIButton) {
        let index = sender.tag
        let currentState = self.buttonArray[index]
        
        // Changes image for normal button state
        sender.setImage((!currentState ? greenIcon:redIcon), for: .normal)
        // Alters the array condition for the button.
        self.buttonArray[index] = !currentState
        // Calls the delegate method to update the matrix
        self.matrixDelegate?.updateMatrix(with: self.buttonArray, onColumn: self.tag)
    }
}
