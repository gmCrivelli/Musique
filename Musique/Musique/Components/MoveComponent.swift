//
//  MoveComponent.swift
//  choraGabe
//
//  Created by Gustavo De Mello Crivelli on 06/07/17.
//  Copyright © 2017 Gustavo De Mello Crivelli. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class MoveComponent : GKComponent {
    
    weak var entityManager : EntityManager!
    var velocity : float2!
    var accel : float2!
    
    var lifeTime : Double = 0
    
    init(entityManager: EntityManager) {
        super.init()
        self.entityManager = entityManager
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setVelocity(velocity: float2) {
        self.velocity = velocity
    }
    
    func setAccel(accel: float2) {
        self.accel = accel
    }
    
    override func update(deltaTime seconds: TimeInterval) {
    
        super.update(deltaTime: seconds)
        
        lifeTime += seconds
    
        guard let entity = entity,
            let spriteComponent = entity.component(ofType: SpriteComponent.self) else {
                return
        }
        spriteComponent.node.position = CGPoint(x: spriteComponent.node.position.x + CGFloat(velocity.x) * CGFloat(seconds),
                                                y: spriteComponent.node.position.y + CGFloat(velocity.y) * CGFloat(seconds))
        velocity = float2(x: velocity.x + accel.x * Float(seconds),
                             y: velocity.y + accel.y * Float(seconds))
        
        if lifeTime > 1.5 && !entityManager.scene.intersects(spriteComponent.node) {
            entityManager.remove(entity)
            return
        }
        
        guard let physicsComponent = entity.component(ofType: PhysicsComponent.self) else { return }
        
        
        
        
    }
    
}
