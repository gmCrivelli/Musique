//
//  Fence.swift
//  Musique
//
//  Created by Gustavo De Mello Crivelli on 06/11/17.
//  Copyright © 2017 Gustavo De Mello Crivelli. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class Fence: Obstacle {
    
    /// MARK: Components that make up Fence:
    //  MoveComponent (from GameObject)
    //  SpriteComponent (from GameObject)
    //  TypeComponent (from Obstacle)
    //  PhysicsComponent (from Obstacle)
    
    init(location: CGPoint, entityManager: EntityManager) {
        super.init(obstacleType: .fence, location: location, entityManager: entityManager)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
