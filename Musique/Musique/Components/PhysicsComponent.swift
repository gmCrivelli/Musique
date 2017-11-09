//
//  PhysicsComponent.swift
//  Musique
//
//  Created by Gustavo De Mello Crivelli on 08/11/17.
//  Copyright © 2017 Gustavo De Mello Crivelli. All rights reserved.
//

import Foundation
import GameplayKit

enum CollisionType : Int {
    case player = 1
    case obstacle = 2
}

class PhysicsComponent : GKComponent {
    
    /// MARK: Properties
    private var hitbox : CGRect!
    private var collisionType : CollisionType!
    private var collisionMask : Int!
    
    func getHitbox() -> CGRect {
        return hitbox
    }
    
    func getMask() -> Int {
        return collisionMask
    }
    
    init(hitbox: CGRect, collisionType: CollisionType, collisionMask: Int) {
        super.init()
        self.hitbox = hitbox
        self.collisionType = collisionType
        self.collisionMask = collisionMask
    }
    
    func checkCollision(with component: PhysicsComponent) -> Bool {
        if self.collisionMask & component.collisionType.rawValue == 0 {
            return false
        }
        return hitbox.intersects(component.hitbox)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
