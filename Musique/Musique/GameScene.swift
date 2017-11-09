//
//  GameScene.swift
//  Musique
//
//  Created by Gustavo De Mello Crivelli on 01/11/17.
//  Copyright © 2017 Gustavo De Mello Crivelli. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var entityManager : EntityManager!
    
    override func didMove(to view: SKView) {
        setupEntities()
    }

    func setupEntities() {
//        entityManager = EntityManager(scene: self)
//        entityManager.delegateGameScene = self
//        
//        let patternInstantiator = PatternInstantiator(entityManager: entityManager)
//        
//        var actionSequence = [SKAction]()
//        
//        for (t, pc) in patternInstantiator.patternArray {
//            
//            let waitAction = SKAction.wait(forDuration: t)
//            
//            let cannonAction = SKAction.run {
//                self.run(SKAction.sequence(pc.sequence))
//            }
//            
//            actionSequence.append(waitAction)
//            actionSequence.append(cannonAction)
//        }
//        
//        self.run(SKAction.sequence(actionSequence))
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
