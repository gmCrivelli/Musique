//
//  Player.swift
//  Musique
//
//  Created by Gustavo De Mello Crivelli on 08/11/17.
//  Copyright © 2017 Gustavo De Mello Crivelli. All rights reserved.
//

import Foundation
import GameplayKit


class Player : GameObject {
    
    /// MARK: Components that make up the player:
    //  MoveComponent (from GameObject)
    //  SpriteComponent (from GameObject)
    //  InputComponent
    //  StateComponent
    //  ScoreComponent
    
    /// MARK: Properties
    
    init(location: CGPoint, entityManager : EntityManager) {
        super.init(name: "player", location: location, entityManager: entityManager)
    
        addComponent(InputComponent())
        
        // Collision component
        if let spriteComponent = self.component(ofType: SpriteComponent.self) {
            addComponent(PhysicsComponent(hitbox: spriteComponent.node.frame, collisionType: .player, collisionMask: 0b10))
        }
        
        if let moveComponent = self.component(ofType: MoveComponent.self) {
            moveComponent.setAccel(accel: float2(x: 0, y: -2))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
