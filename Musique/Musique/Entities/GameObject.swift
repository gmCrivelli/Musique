//
//  GameObject.swift
//  Musique
//
//  Created by Gustavo De Mello Crivelli on 06/07/17.
//  Copyright © 2017 Gustavo De Mello Crivelli. All rights reserved.
//

import Foundation
import GameplayKit

// Base class for EVERY game object, from player to obstacle to background
class GameObject: GKEntity {
    
    /// MARK: Components that make up GameObjects:
    //  MoveComponent
    //  SpriteComponent
    
    /// MARK: Properties
    var name : String!
    var position : CGPoint!
    
    weak var entityManager : EntityManager!
    
    // Initializer for basic properties and common components
    init(name: String, location: CGPoint, entityManager: EntityManager) {
        super.init()
        
        self.entityManager = entityManager
        addComponent(MoveComponent(entityManager: entityManager))
        
        self.name = name
        let spriteComponent = SpriteComponent(imageNamed: self.name, location: location)
        addComponent(spriteComponent)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


