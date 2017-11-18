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
    
    // Stores if obstacle was hit to avoid subsequent hits
    // 0 = no hit
    // 1 = player hit (bad)
    // 2 = score collider hit
    public var wasHit : Int = 0
    public var baseScore : Int = 5
    public var obstacleSpeedPerSec : Double!
    
    init(speedPerSec: Double){
        super.init(texture: SKTexture(imageNamed: "foliagePack_056"), color: .gray, size: CGSize(width: 50, height: 60))
        self.obstacleSpeedPerSec = speedPerSec
        setupPhysics()
    }
    
    init(speedPerSec: Double, offset: CGFloat) {
        super.init(texture: SKTexture(imageNamed: "foliagePack_056"), color: .gray, size: CGSize(width: 50, height: 60))
        self.obstacleSpeedPerSec = speedPerSec
        setupPhysics()
        self.position = CGPoint(x: offset, y: 0)
    }
    
    init(speedPerSec: Double, offset: CGFloat, texture : SKTexture) {
        super.init(texture: texture, color: .gray, size: CGSize(width: texture.size().width / 5, height: texture.size().height / 5))
        self.obstacleSpeedPerSec = speedPerSec
        setupPhysics()
        self.position = CGPoint(x: offset, y: 0)
    }
    
    func setupPhysics() {
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width / 2, height: self.size.height / 2))
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = 4
        self.physicsBody?.collisionBitMask = 2
        self.physicsBody?.contactTestBitMask = 0b1001
        self.physicsBody?.fieldBitMask = 0
        
        //        let offsetX : CGFloat = self.frame.size.width * self.anchorPoint.x
        //        let offsetY : CGFloat = self.frame.size.height * self.anchorPoint.y
        //
        //        print(offsetX, offsetY)
        //
        //        let path = CGMutablePath()
        //
        //        path.move(to: CGPoint(x: 0 - offsetX, y: 0 - offsetY))
        //        path.move(to: CGPoint(x: 52 - offsetX, y: 57 - offsetY))
        //        path.move(to: CGPoint(x: 80 - offsetX, y: 0 - offsetY))
        //
        //        path.closeSubpath()
    }
    
    func update(_ dt : TimeInterval) {
        self.position = CGPoint(x: self.position.x - CGFloat(obstacleSpeedPerSec * dt), y: self.position.y)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
}
