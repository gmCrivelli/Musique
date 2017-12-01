//
//  ScoreDAO.swift
//  Musique_ez
//
//  Created by Ederaldo Ratz on 01/12/2017.
//  Copyright © 2017 Gustavo De Mello Crivelli. All rights reserved.
//

import Foundation
import CoreData

class ScoreDAO {
    
    /// Method responsible for saving a Score into database
    /// - parameters:
    ///     - objectToBeSaved: Score to be saved on database
    /// - throws: if an error occurs during saving an object into database (Errors.DatabaseFailure)
    static func create(_ objectToBeSaved: Score) throws {
        do {
            // add object to be saved to the context
            CoreDataManager.sharedInstance.persistentContainer.viewContext.insert(objectToBeSaved)
            
            // persist changes at the context
            try CoreDataManager.sharedInstance.persistentContainer.viewContext.save()
        }
        catch {
            throw Errors.DatabaseFailure
        }
    }
    
    /// Method responsible for updating a Progress Score into database
    /// - parameters:
    ///     - objectToBeUpdated: score to be updated on database
    /// - throws: if an error occurs during updating an object into database (Errors.DatabaseFailure)
    static func update(_ objectToBeUpdated: Score) throws {
        do {
            // persist changes at the context
            try CoreDataManager.sharedInstance.persistentContainer.viewContext.save()
        }
        catch {
            throw Errors.DatabaseFailure
        }
    }
    
    /// Method responsible for deleting a Progress Score from database
    /// - parameters:
    ///     - objectToBeSaved: score to be saved on database
    /// - throws: if an error occurs during deleting an object into database (Errors.DatabaseFailure)
    static func delete(_ objectToBeDeleted: Score) throws {
        do {
            // delete element from context
            CoreDataManager.sharedInstance.persistentContainer.viewContext.delete(objectToBeDeleted)
            
            // persist the operation
            try CoreDataManager.sharedInstance.persistentContainer.viewContext.save()
        }
        catch {
            throw Errors.DatabaseFailure
        }
    }
    
    /// Method responsible for gettings all Progress Score from database
    /// - returns: a list of score score from database
    /// - throws: if an error occurs during getting an object from database (Errors.DatabaseFailure)
    static func findAll() throws -> [Score] {
        // list of seasons to be returned
        var scoreList:[Score]
        
        do {
            // creating fetch request
            let request:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Score")
            
            // perform search
            scoreList = try CoreDataManager.sharedInstance.persistentContainer.viewContext.fetch(request) as! [Score]
        }
        catch {
            throw Errors.DatabaseFailure
        }
        
        return scoreList
    }
    
}


