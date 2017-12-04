//
//  Score.swift
//  Musique_ez
//
//  Created by Ederaldo Ratz on 30/11/2017.
//  Copyright © 2017 Gustavo De Mello Crivelli. All rights reserved.
//

import Foundation
import CoreData

class Score: NSManagedObject {
    
    @NSManaged public var sequence: String
    @NSManaged public var score: Int16
    
    @NSManaged public var music:MusicPulse?
    
    convenience init() {
        // get context
        let managedObjectContext: NSManagedObjectContext = CoreDataManager.sharedInstance.persistentContainer.viewContext
        
        // create entity description
        let entityDescription = NSEntityDescription.entity(forEntityName: "Score", in: managedObjectContext)
        
        // call super
        self.init(entity: entityDescription!, insertInto: nil)
    }
    
    // This initializer was created to solve a problem upon creating an object that initialized without a managedContext independently.
    convenience init(context: NSManagedObjectContext){
        
        // create entity description
        let entityDescription = NSEntityDescription.entity(forEntityName: "Score", in: context)
        
        // call super
        self.init(entity: entityDescription!, insertInto: context)
    }
}