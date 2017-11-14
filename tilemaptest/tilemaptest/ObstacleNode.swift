//
//  ObstacleNode.swift
//  tilemaptest
//
//  Created by Rafael Prado on 08/11/17.
//  Copyright © 2017 DoM7. All rights reserved.
//

import SpriteKit
import GameplayKit

class ObstacleNode: SKSpriteNode {
    init(){
        super.init(texture: nil, color: .gray, size: CGSize(width: 50, height: 50))
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = 4
        self.physicsBody?.collisionBitMask = 2
        self.physicsBody?.contactTestBitMask = 0
        self.physicsBody?.fieldBitMask = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
}
