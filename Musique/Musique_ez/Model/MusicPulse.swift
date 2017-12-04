//
//  Music.swift
//  Musique_ez
//
//  Created by Ederaldo Ratz on 30/11/2017.
//  Copyright © 2017 Gustavo De Mello Crivelli. All rights reserved.
//

import Foundation
import CoreData

class MusicPulse: NSManagedObject {
    
    @NSManaged public var name: String
    @NSManaged public var highScore: Int16
    @NSManaged public var bpm: Double
    @NSManaged public var fileExtension: String
    @NSManaged public var fileName: String
    @NSManaged public var id: Int16
    @NSManaged public var lastScore: Int16
    
    convenience init() {
        // get context
        let managedObjectContext: NSManagedObjectContext = CoreDataManager.sharedInstance.persistentContainer.viewContext
        
        // create entity description
        let entityDescription = NSEntityDescription.entity(forEntityName: "Music", in: managedObjectContext)
        
        // call super
        self.init(entity: entityDescription!, insertInto: nil)
    }
    
    // This initializer was created to solve a problem upon creating an object that initialized without a managedContext independently.
    convenience init(context: NSManagedObjectContext){
        
        // create entity description
        let entityDescription = NSEntityDescription.entity(forEntityName: "Music", in: context)
        
        // call super
        self.init(entity: entityDescription!, insertInto: context)
    }
}
