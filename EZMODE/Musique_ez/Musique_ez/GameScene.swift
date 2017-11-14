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
    private var playerHasBeenHit : Bool = false
    private var playerInvincibilityTime : TimeInterval = 0.1
    private var timeUntilInvincibilityEnds : TimeInterval = 0.0
    
    // Obstacle-related properties
    private var obstaclesParent : SKNode?
    private let moveSpeedPerSecond = 400.0
    private var originalPosition:CGPoint?
    
    // Configure contact masks
    private let playerCategory : UInt32 = 0b1
    private let floorCategory : UInt32 = 0b10
    private let obstacleCategory : UInt32 = 0b100
    
    // Preloaded actions
    private var jumpAction : SKAction!
    private var spawnObstacleAction : SKAction!
    private var crashAction : SKAction!
    
    
    private var tileMap : SKTileMapNode!
    
    private var floorHeight: CGFloat!

    private var bgMusic:Sound?
    private var gruntSound:Sound?
    
    override func didMove(to view: SKView) {
        
        //Setup all music
        let filePath = URL(fileURLWithPath: Bundle.main.path(forResource: "The_Muffin_Man", ofType: "mp3")!)
        bgMusic = Sound(url: filePath, bpm: 90)
        
        let gruntPath = URL(fileURLWithPath: Bundle.main.path(forResource: "grunt1", ofType: "wav")!)
        gruntSound = Sound(url: gruntPath)
    
        //Configure background
        
        // Get player node from scene and store it for use later
        self.player = self.childNode(withName: "Player") as? SKSpriteNode
        self.player.physicsBody?.categoryBitMask = playerCategory
        self.player.physicsBody?.collisionBitMask = 0 //floorCategory
        self.player.physicsBody?.contactTestBitMask = floorCategory | obstacleCategory
        self.player.physicsBody?.restitution = 0
        self.player.physicsBody?.affectedByGravity = false
        
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
        
        // Setup ground
        self.tileMap = self.childNode(withName: "Tile Map Node") as? SKTileMapNode
        self.tileMap.physicsBody = SKPhysicsBody(
                rectangleOf: CGSize(width: tileMap.mapSize.width * tileMap.xScale,
                                    height: tileMap.mapSize.height * tileMap.yScale))
        self.tileMap.physicsBody?.affectedByGravity = false
        self.tileMap.physicsBody?.isDynamic = false
        self.tileMap.physicsBody?.categoryBitMask = floorCategory
        self.tileMap.physicsBody?.fieldBitMask = 0
        self.tileMap.physicsBody?.restitution = 0
        
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -22)
        originalPosition = tileMap.position
        
        // Setup actions
        let createObstacleAction = SKAction.run { [weak self] in
            self?.addObstacle()
        }
        let waitForNext = SKAction.wait(forDuration: 60.0 / Double(bgMusic!.bpm!))
        let obstacleSequence = SKAction.sequence([createObstacleAction, waitForNext])
        self.spawnObstacleAction = SKAction.sequence([SKAction.wait(forDuration: 30.0/Double(bgMusic!.bpm!)),SKAction.repeatForever(obstacleSequence)])
        
        let upAction = SKAction.moveBy(x: 0, y: 140, duration: 0.3)
        let upDownSequence = SKAction.sequence([upAction, upAction.reversed()])
        let rotateAction = SKAction.rotate(byAngle: -2 * CGFloat(M_PI), duration: 0.6)
        self.jumpAction = SKAction.group([upDownSequence, rotateAction])
        
        let gruntAction = SKAction.playSoundFileNamed("grunt.wav", waitForCompletion: false)
        let blinkAction = SKAction.fadeAlpha(to: 0.0, duration: 0.2)
        let unblinkAction = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
        
        let blinkSequence = SKAction.sequence([blinkAction, unblinkAction, blinkAction, unblinkAction])
        self.crashAction = SKAction.group([gruntAction, blinkSequence])
        
        // Setup obstacles
        self.obstaclesParent = childNode(withName: "Obstacles")
        
        // Setup physics
        self.view?.showsPhysics = true
        self.physicsWorld.contactDelegate = self
        
        // Start the game
        self.run(spawnObstacleAction)
        startWalking()
        
        bgMusic?.play{
            // Completion block for when music ends
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
            //player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 100))
            player.run(jumpAction) {
                self.playerState = .onFloor
                self.startWalking()
            }
        }
    }
    
    func move(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = velocity * CGFloat(dt)
        //print("Amount to move: \(amountToMove)")
        sprite.position += amountToMove
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        // Player collides with obstacle
        if (contact.bodyA.categoryBitMask == playerCategory) &&
            (contact.bodyB.categoryBitMask == obstacleCategory) &&
            !playerHasBeenHit {
            playerHasBeenHit = true
            player.run(crashAction) { self.playerHasBeenHit = false }
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
        
        // Reset player horizontal position, to be safe
        player.position = CGPoint(x: playerOrigin.x, y: player.position.y)
        
        // Calculate actual distance elapsed since last update
        let actualOffset = CGFloat(moveSpeedPerSecond * dt)
        
        // Move the ground
        tileMap.position = CGPoint(x: (tileMap.position.x) - actualOffset, y: (tileMap.position.y))
        // In case the ground has reached a limit distance, returns it to the initial position
        if tileMap.position.x <= 0 {
            tileMap.position = originalPosition!
        }
        
        // Move obstacles
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
