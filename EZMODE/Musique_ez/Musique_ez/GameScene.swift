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
    private var playerWalkingFrames : [SKTexture]!

    private var obstaclesParent : SKNode?
    private let moveSpeedPerSecond = 400.0
    private var originalPosition:CGPoint?
    
    // Configure contact masks
    let playerCategory : UInt32 = 0b1
    let floorCategory : UInt32 = 0b10
    let obstacleCategory : UInt32 = 0b100
    
    private var tileMap : SKTileMapNode!
    
    private var floorHeight: CGFloat!

    private var muffinMan:Sound?
    private var gruntSound:Sound?
    
    override func didMove(to view: SKView) {
        
        //Setup all music
        let filePath = URL(fileURLWithPath: Bundle.main.path(forResource: "The_Muffin_Man", ofType: "mp3")!)
        muffinMan = Sound(url: filePath, bpm: 90)
        
        let filePath = URL(fileURLWithPath: Bundle.main.path(forResource: "grunt", ofType: "m4a")!)
        gruntSound = Sound(url: filePath)
    
        //Configure background
        
        // Get player node from scene and store it for use later
        self.player = self.childNode(withName: "Player") as? SKSpriteNode
        self.player.physicsBody?.categoryBitMask = playerCategory
        self.player.physicsBody?.collisionBitMask = floorCategory
        self.player.physicsBody?.contactTestBitMask = floorCategory | obstacleCategory
        self.player.physicsBody?.restitution = 0
        
        self.playerOrigin = self.player.position
        
        let playerAnimatedAtlas = SKTextureAtlas(named: "Caipora")
        var walkFrames = [SKTexture]()
        
        let numImages = playerAnimatedAtlas.textureNames.count
        
        for i in 1 ..< numImages {
            let playerTextureName = "Caipora\(i)"
            walkFrames.append(playerAnimatedAtlas.textureNamed(playerTextureName))
        }
        
        playerWalkingFrames = walkFrames
        
        player.texture = playerWalkingFrames[0]
        
        self.tileMap = self.childNode(withName: "Tile Map Node") as? SKTileMapNode
        self.tileMap.physicsBody = SKPhysicsBody(
                rectangleOf: CGSize(width: tileMap.mapSize.width * tileMap.xScale,
                                    height: tileMap.mapSize.height * tileMap.yScale))
        self.tileMap.physicsBody?.affectedByGravity = false
        self.tileMap.physicsBody?.isDynamic = false
        self.tileMap.physicsBody?.categoryBitMask = floorCategory
        self.tileMap.physicsBody?.restitution = 0
        
        print(self.physicsWorld.gravity)
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -22)
        
        originalPosition = tileMap.position
        
        self.obstaclesParent = childNode(withName: "Obstacles")
//        run(SKAction.repeatForever(SKAction.sequence(
//            [SKAction.run() { [weak self] in self?.spawnObstacle() },
//             SKAction.wait(forDuration: 2.0)])))
        
        let createObstacleAction = SKAction.run {
            self.addObstacle()
        }
        
        let waitForNext = SKAction.wait(forDuration: 60.0 / Double(muffinMan!.bpm!))
        let sequence = SKAction.sequence([createObstacleAction, waitForNext])
        self.run(SKAction.sequence([SKAction.wait(forDuration: 30.0/Double(muffinMan!.bpm!)),SKAction.repeatForever(sequence)]))
        
        self.view?.showsPhysics = true
        self.physicsWorld.contactDelegate = self
        
        startWalking()
        
        muffinMan?.play{
            // Completioni block for when music ends
            print("musica acabou")
        }
    }
    
    func startWalking() {
        
        player.run(SKAction.repeatForever(
            SKAction.animate(with: playerWalkingFrames, timePerFrame: 0.1)))
    }
    
    func jump() {
        if playerState == .onFloor {
            playerState = .jumping
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 100))
            player.run(SKAction.rotate(byAngle: -2.3 * CGFloat(M_PI), duration: 0.6))
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
            player.removeAllActions()
            player.run(SKAction.rotate(toAngle: 0, duration: 0))
            startWalking()
            //player.zRotation = 0
            //player.position = playerOrigin
        }
        
        // Player collides with obstacle
        if (contact.bodyA.categoryBitMask == playerCategory) &&
            (contact.bodyB.categoryBitMask == obstacleCategory) {
            
            self.gruntSound.play()
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
        
        let actualOffset = CGFloat(moveSpeedPerSecond * dt)
        
        tileMap.position = CGPoint(x: (tileMap.position.x) - actualOffset, y: (tileMap.position.y))
        // In case the ground has reached a limit distance, returns it to the initial position
        if tileMap.position.x <= 0 {
            tileMap.position = originalPosition!
        }
        
        if let obstaculos = obstaclesParent?.children{
            // For each obstacle
            for obs in obstaculos{
                // Updates the obstacle position at the same rate as the ground
                obs.position = CGPoint(x: obs.position.x - actualOffset, y: obs.position.y)
                // In case the obstacle has reached the outside of the screen
                if(obs.position.x < 2 * (self.tileMap?.frame.minX)! - obs.frame.width){
                    // Removes the object from the parent node to avoid excessive memory use
                    obs.removeFromParent()
                }
            }
        }
    }
    
    @objc func addObstacle() -> Void{
        // Adds a new obstacle to the parent node
        self.obstaclesParent?.addChild(ObstacleNode())
    }
}
