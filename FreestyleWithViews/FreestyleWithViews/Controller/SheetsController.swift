//
//  SheetsController.swift
//  FreestyleWithViews
//
//  Created by Rafael Prado on 27/10/17.
//  Copyright © 2017 DoM7. All rights reserved.
//

import UIKit

/// Passes on the noteMatrix so the delegate can manage it.
protocol SheetManagerDelegate {
    func updateSheets(_ noteMatrix: [[Bool]])
}

/// Controls the embedded view, handling the columns for each page.
class SheetsController: UIViewController {
    
    // Outlet collection containing all columns on the Sheet
    @IBOutlet var columnArray: [Column]!
    
    var matrixDelegate:SheetManagerDelegate?
    
    // Matrix to be filled with the notes that are going to be played
    var notesMatrix:[[Bool]] = [[Bool]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fills matrixDelegate variable for each column and fills the notes matrix
        for col in columnArray{
            col.matrixDelegate = self
            notesMatrix.append(col.buttonArray)
        }
    }
}

// MARK: - NoteMatrixUpdateDelegate protocol implementation
extension SheetsController:NoteMatrixUpdateDelegate{
    
    /// Updates the state of the matrix every time a new note is selected/deselected
    ///
    /// - Parameter array: Current column state.
    /// - Parameter index: Index of column to be updated.
    func updateMatrix(with array: [Bool], onColumn index: Int ) {
        notesMatrix[index] = array
        self.matrixDelegate?.updateSheets(notesMatrix)
    }
}
