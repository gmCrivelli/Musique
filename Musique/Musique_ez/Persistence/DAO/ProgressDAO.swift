//
//  ProgressDAO.swift
//  Musique_ez
//
//  Created by Ederaldo Ratz on 01/12/2017.
//  Copyright © 2017 Gustavo De Mello Crivelli. All rights reserved.
//

import Foundation
import CoreData

class ProgressDAO {
    
    /// Method responsible for saving a Music Score into database
    /// - parameters:
    ///     - objectToBeSaved: Pulse to be saved on database
    /// - throws: if an error occurs during saving an object into database (Errors.DatabaseFailure)
    static func create(_ objectToBeSaved: ProgressPulse) throws {
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
    
    /// Method responsible for updating a Music Score into database
    /// - parameters:
    ///     - objectToBeUpdated: season to be updated on database
    /// - throws: if an error occurs during updating an object into database (Errors.DatabaseFailure)
    static func update(_ objectToBeUpdated: ProgressPulse) throws {
        do {
            // persist changes at the context
            try CoreDataManager.sharedInstance.persistentContainer.viewContext.save()
        }
        catch {
            throw Errors.DatabaseFailure
        }
    }
    
    /// Method responsible for deleting a Music Score from database
    /// - parameters:
    ///     - objectToBeSaved: season to be saved on database
    /// - throws: if an error occurs during deleting an object into database (Errors.DatabaseFailure)
    static func delete(_ objectToBeDeleted: ProgressPulse) throws {
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
    
    /// Method responsible for gettings all Musics Score from database
    /// - returns: a list of musics from database
    /// - throws: if an error occurs during getting an object from database (Errors.DatabaseFailure)
    static func findAll() throws -> [ProgressPulse] {
        // list of seasons to be returned
        var progressList:[ProgressPulse]
        
        do {
            // creating fetch request
            let request:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Progress")
            
            // perform search
            progressList = try CoreDataManager.sharedInstance.persistentContainer.viewContext.fetch(request) as! [ProgressPulse]
        }
        catch {
            throw Errors.DatabaseFailure
        }
        
        return progressList
    }
    
}


