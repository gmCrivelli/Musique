//
//  EntityManager.swift
//  choraGabe
//
//  Created by Gustavo De Mello Crivelli on 06/07/17.
//  Copyright © 2017 Gustavo De Mello Crivelli. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class EntityManager {
    
    lazy var componentSystems: [GKComponentSystem] = {
        let moveSystem = GKComponentSystem(componentClass: MoveComponent.self)
        return [moveSystem]
    }()
    
    var entities = Set<GKEntity>()
    var toRemove = Set<GKEntity>()
    let scene: SKScene
    var isPaused = false
    
    static var _zPosition : CGFloat = 0.00001
    static var zPosition : CGFloat {
        get {
            let aux = _zPosition
            _zPosition += 0.00001
            return aux
        }
        set {
            _zPosition = newValue
        }
    }
    
    init(scene: SKScene) {
        self.scene = scene
    }
    
    func add(_ entity: GKEntity) {
        entities.insert(entity)
        
        for componentSystem in componentSystems {
            componentSystem.addComponent(foundIn: entity)
        }
    }
    
    func remove(_ entity: GKEntity) {
        if let spriteNode = entity.component(ofType: SpriteComponent.self)?.node {
            spriteNode.removeFromParent()
        }
        
        entities.remove(entity)
        toRemove.insert(entity)
    }
    
    func update(_ deltaTime: CFTimeInterval) {
        
        for componentSystem in componentSystems {
            componentSystem.update(deltaTime: deltaTime)
        }
        
        for currentRemove in toRemove {
            for componentSystem in componentSystems {
                componentSystem.removeComponent(foundIn: currentRemove)
            }
        }
        toRemove.removeAll()
    }
    
    func spawnObstacle(obstacleType: ObstacleType, location: CGPoint) {
        
        let obstacle = Obstacle(obstacleType: obstacleType, location: location, entityManager: self)
        
        //target.setInitialVelocity(velocity: initialVelocity)
        //target.setInitialAccel(accel: initialAccel)
        
        if let spriteComponent = obstacle.component(ofType: SpriteComponent.self) {
            spriteComponent.node.position = location
            spriteComponent.node.zPosition = EntityManager.zPosition
        }
        
        if let moveComponent = obstacle.component(ofType: MoveComponent.self) {
            moveComponent.setVelocity(velocity: float2(x: -50, y: 0))
        }
        
        add(obstacle)
    }
    
    func getEntities(for obstacleType: ObstacleType?) -> [GKEntity] {
        if let type = obstacleType {
            return entities.flatMap{ entity in
                if let typeComponent = entity.component(ofType: TypeComponent.self) {
                    if typeComponent.obstacleType == type {
                        return entity
                    }
                }
                return nil
            }
        }
        else {
            return Array(entities)
        }
    }
    
    func getMoveComponents(for obstacleType: ObstacleType?) -> [MoveComponent] {
        let entitiesToMove = getEntities(for: obstacleType)
        var moveComponents = [MoveComponent]()
        for entity in entitiesToMove {
            if let moveComponent = entity.component(ofType: MoveComponent.self) {
                moveComponents.append(moveComponent)
            }
        }
        return moveComponents
    }
    
}

