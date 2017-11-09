//
//  GameScene.swift
//  Musique_ez
//
//  Created by Gustavo De Mello Crivelli on 09/11/17.
//  Copyright © 2017 Gustavo De Mello Crivelli. All rights reserved.
//

import SpriteKit
import GameplayKit

enum PlayerState : Int {
    case onFloor = 1
    case jumping = 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Time control
    private var lastUpdateTime: TimeInterval = 0
    private var dt: TimeInterval = 0
    
    // Player-related properties
    private var playerState : PlayerState = .onFloor
    private var playerAccel = CGPoint(x: 0, y: -6000)
    private var playerVel = CGPoint(x: 0, y: 0)
    private var playerOrigin : CGPoint!
    private var player : SKSpriteNode!
    
    
    // Configure contact masks
    let playerCategory : UInt32 = 0b1
    let floorCategory : UInt32 = 0b10
    let obstacleCategory : UInt32 = 0b100
    
    private var tileMap : SKTileMapNode!
    
    private var floorHeight: CGFloat!
    
    override func didMove(to view: SKView) {
        
        //Start music
        
        //Configure background
        
        // Get player node from scene and store it for use later
        self.player = self.childNode(withName: "Player") as? SKSpriteNode
        self.player.physicsBody?.categoryBitMask = playerCategory
        self.player.physicsBody?.collisionBitMask = floorCategory
        self.player.physicsBody?.contactTestBitMask = floorCategory | obstacleCategory
        self.player.physicsBody?.restitution = 0
        
        self.playerOrigin = self.player.position
        
        self.tileMap = self.childNode(withName: "Tile Map Node") as? SKTileMapNode
        self.tileMap.physicsBody = SKPhysicsBody(
                rectangleOf: CGSize(width: tileMap.mapSize.width * tileMap.xScale,
                                    height: tileMap.mapSize.height * tileMap.yScale))
        self.tileMap.physicsBody?.affectedByGravity = false
        self.tileMap.physicsBody?.isDynamic = false
        self.tileMap.physicsBody?.categoryBitMask = floorCategory
        self.tileMap.physicsBody?.restitution = 0
        
//        run(SKAction.repeatForever(SKAction.sequence(
//            [SKAction.run() { [weak self] in self?.spawnObstacle() },
//             SKAction.wait(forDuration: 2.0)])))
        self.view?.showsPhysics = true
        self.physicsWorld.contactDelegate = self
    }
    
    func jump() {
        if playerState == .onFloor {
            playerState = .jumping
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 100))
            player.run(SKAction.rotate(byAngle: -1.5 * CGFloat(M_PI), duration: 1))
        }
    }
    
    func move(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = velocity * CGFloat(dt)
        //print("Amount to move: \(amountToMove)")
        sprite.position += amountToMove
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        // Player collides with floor
        if (contact.bodyA.categoryBitMask == playerCategory) &&
            (contact.bodyB.categoryBitMask == floorCategory) &&
            playerState == .jumping {
            
            playerState = .onFloor
            //player.removeAllActions()
            //player.zRotation = 0
            //player.position = playerOrigin
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        
        player.position = CGPoint(x: playerOrigin.x, y: player.position.y)
        
        if playerState == .onFloor {
            return
        }
    }
}
