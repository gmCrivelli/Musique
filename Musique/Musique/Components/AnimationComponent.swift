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

class AnimationComponent : GKComponent {
    
    weak var entityManager : EntityManager!
    var textureAtlas : SKTextureAtlas!
    var frames : [SKTexture]!
    
    let node : SKSpriteNode
    
    init(atlasNamed: String, textureNamed: String, location: CGPoint, entityManager: EntityManager) {
        self.entityManager = entityManager
        textureAtlas.textureNamed(atlasNamed)
        
        let numImages = textureAtlas.textureNames.count
        for i in 1 ..< numImages / 2 {
            let finalTextureName = "\(textureNamed)\(i)"
            frames.append(textureAtlas.textureNamed(finalTextureName))
        }
        
        let firstFrame = frames[0]
        self.node = SKSpriteNode(texture: firstFrame)
        self.node.position = location
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animate() {
        node.run(SKAction.repeatForever(
            SKAction.animate(with: frames,
                             timePerFrame: 0.1,
                             resize: false,
                             restore: true)),
                 withKey:"animationFrames")
    }
    
}
