//
//  Target.swift
//  choraGabe
//
//  Created by Gustavo De Mello Crivelli on 06/07/17.
//  Copyright © 2017 Gustavo De Mello Crivelli. All rights reserved.
//

import Foundation
import GameplayKit

class Obstacle: GameObject {

    /// MARK: Components that make up Obstacle:
    //  MoveComponent (from GameObject)
    //  SpriteComponent (from GameObject)
    //  TypeComponent
    //  PhysicsComponent
    
    var obstacleType : ObstacleType!
    //var relatedEntity: GKEntity?
    
    init(obstacleType: ObstacleType, location: CGPoint, entityManager: EntityManager) {
        super.init(name: obstacleType.getName(), location: location, entityManager: entityManager)
        
        self.obstacleType = obstacleType
        addComponent(TypeComponent(obstacleType: obstacleType))
        
        setInitialVelocity(velocity: float2(-50, 0))
        setInitialAccel(accel: float2(0, 0))
    }
    
    func setInitialVelocity(velocity: float2) {
        if let moveComponent = self.component(ofType: MoveComponent.self) {
            moveComponent.setVelocity(velocity: velocity)
        }
    }
    
    func setInitialAccel(accel: float2) {
        if let moveComponent = self.component(ofType: MoveComponent.self) {
            moveComponent.setAccel(accel: accel)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

