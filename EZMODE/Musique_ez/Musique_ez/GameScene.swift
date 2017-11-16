//
//  GameScene.swift
//  Musique_ez
//
//  Created by Gustavo De Mello Crivelli on 09/11/17.
//  Copyright © 2017 Gustavo De Mello Crivelli. All rights reserved.
//

import SpriteKit
import SpriteKitEasingSwift
import GameplayKit

enum PlayerState : Int {
    case onFloor = 1
    case jumping = 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var whatever: SKNode!

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
    private var playerIsInvincible : Bool = false
    private var playerInvincibilityTime : TimeInterval = 0.9
    
    // Obstacle-related properties
    private var obstaclesParent : SKNode?
    private var moveSpeedPerSecond = 500.0
    private var originalPosition : CGPoint?
    
    //Paralax elements
    private var flyingScenarioObjects : SKNode?
    private var groundedScenarioObjects : SKNode?
    
    // Configure contact masks
    private let playerCategory : UInt32 = 0b1
    private let floorCategory : UInt32 = 0b10
    private let obstacleCategory : UInt32 = 0b100
    
    // Preloaded actions
    private var jumpAction : SKAction!
    private var spawnObstacleAction : SKAction!
    private var crashAction : SKAction!
    
    private var forestNode : SKSpriteNode!
    private var originalForestPosition : CGPoint!
    private var tileMap : SKTileMapNode!
    
    // Labels and Interface
    
    private var floorHeight: CGFloat!

    private var bgMusic:Sound?
    private var gruntSound:Sound?
    
    private var score : Int!
    private var multiplier : Int!
    
    override func didMove(to view: SKView) {
        
        whatever = self.childNode(withName: "whatever")
        
        
        //Setup all music
        let filePath = URL(fileURLWithPath: Bundle.main.path(forResource: "The_Muffin_Man", ofType: "mp3")!)
        bgMusic = Sound(url: filePath, bpm: 90)
        
        let gruntPath = URL(fileURLWithPath: Bundle.main.path(forResource: "grunt1", ofType: "wav")!)
        gruntSound = Sound(url: gruntPath)
    
        //Configure background
        self.flyingScenarioObjects = childNode(withName: "Flying Scenario Objects")
        self.groundedScenarioObjects = childNode(withName: "Grounded Scenario Objects")
        
        self.forestNode = childNode(withName: "Background") as! SKSpriteNode
        originalForestPosition = CGPoint(x: 1000, y: forestNode.position.y)
        
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
        self.spawnObstacleAction = SKAction.repeatForever(obstacleSequence)
        
        let initialPosition = player.position
        let customJumpAction = SKAction.customAction(withDuration: 0.4, actionBlock: { (node, timeElapsed) in
            let t = CGFloat(Double.pi) * timeElapsed / 0.4

            node.position = CGPoint(x: initialPosition.x, y: initialPosition.y + 120 * sin(t))
            })
        
        let customJumpUp = SKEase.move(easeFunction: CurveType.curveTypeCubic, easeType: EaseType.easeTypeOut, time: 0.225, from: initialPosition, to: initialPosition + CGPoint(x: 0, y: 120))
        let customJumpDown = SKEase.move(easeFunction: CurveType.curveTypeCubic, easeType: EaseType.easeTypeIn, time: 0.225, from: initialPosition + CGPoint(x: 0, y: 120), to: initialPosition)
        let jumpSequence = SKAction.sequence([customJumpUp, customJumpDown])
        
        let rotateAction = SKAction.rotate(byAngle: -2 * CGFloat(Double.pi), duration: 0.45)
        self.jumpAction = SKAction.group([jumpSequence, rotateAction])
        
        let createFlyingObjectAction = SKAction.run {
            self.spawnScenarioObject(isGroundObject: false)
        }
        
        let createGroundedObjectAction = SKAction.run {
            self.spawnScenarioObject(isGroundObject: true)
        }
    
        let waitForNextGroundedScenarioObject = SKAction.wait(forDuration: 0.8)
        let groundedObjectsSequence = SKAction.sequence([createGroundedObjectAction, waitForNextGroundedScenarioObject])
        self.run(SKAction.sequence([SKAction.wait(forDuration: 0),SKAction.repeatForever(groundedObjectsSequence)]))

        let waitForNexFlyingtScenarioObject = SKAction.wait(forDuration: 8)
        let flyingObjectsSequence = SKAction.sequence([createFlyingObjectAction, waitForNexFlyingtScenarioObject])
        self.run(SKAction.sequence([SKAction.wait(forDuration: 0),SKAction.repeatForever(flyingObjectsSequence)]))
        
        let gruntAction = SKAction.playSoundFileNamed("grunt1.wav", waitForCompletion: false)
        
        let blinkAction = SKAction.fadeAlpha(to: 0.0, duration: playerInvincibilityTime / 6.0)
        let unblinkAction = SKAction.fadeAlpha(to: 1.0, duration: playerInvincibilityTime / 6.0)
        
        let blinkSequence = SKAction.sequence([blinkAction, unblinkAction, blinkAction, unblinkAction, blinkAction, unblinkAction])
        self.crashAction = SKAction.group([gruntAction, blinkSequence])
        
        // Setup obstacles
        self.obstaclesParent = childNode(withName: "Obstacles")
        
        // Setup physics
        self.view?.showsPhysics = true
        self.physicsWorld.contactDelegate = self
        
        // Start the game
        self.score = 0
        self.multiplier = 1
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
            !playerIsInvincible {
            playerIsInvincible = true
            player.run(crashAction) { self.playerIsInvincible = false }
        }
    }
    
    func randomizeTexture(isGroundObject: Bool) -> SKTexture{
        var textures = [SKTexture]()
        
        if(isGroundObject){
            textures.append(SKTexture(imageNamed: "foliagePack_007"))
            textures.append(SKTexture(imageNamed: "foliagePack_008"))
            textures.append(SKTexture(imageNamed: "foliagePack_012"))
        }else{
            textures.append(SKTexture(imageNamed: "Nuvem"))
            textures.append(SKTexture(imageNamed: "Nuvem2"))
        }
        
        let randomNumber = Int(arc4random_uniform(UInt32(textures.count)))
        
        return textures[randomNumber]
    }
    
    func spawnScenarioObject(isGroundObject : Bool){
        if(isGroundObject){
            groundedScenarioObjects!.addChild(ScenarioObjectNode(isGroundObject: true, layer: 0, texture: randomizeTexture(isGroundObject: true)))
        } else {
            flyingScenarioObjects!.addChild(ScenarioObjectNode(isGroundObject: false, layer: 0, texture: randomizeTexture(isGroundObject: false)))
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
        
        forestNode.position = CGPoint(x: forestNode.position.x - (actualOffset / 7), y: forestNode.position.y)
        if forestNode.position.x <= 320{
            forestNode.position = originalForestPosition
        }
        
        moveScenarioObjects(flyingScenarioObjects!, atLayer: 8)
        moveScenarioObjects(groundedScenarioObjects!, atLayer: 3)
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
    
    func moveScenarioObjects(_ objects: SKNode, atLayer: Double){
        
        let movementSpeed = CGFloat(moveSpeedPerSecond / atLayer * dt)
        
        let objs = objects.children
        
        for obj in objs{
            obj.position = CGPoint(x:obj.position.x - movementSpeed, y: obj.position.y)
            if(obj.position.x < 2 * (self.tileMap?.frame.minX)! - obj.frame.width){
                // Removes the object from the parent node to avoid excessive memory use
                obj.removeFromParent()
            }
        }
        
    }
    
    @objc func addObstacle() -> Void{
        
        let goalPosition = whatever.position.x //self.playerOrigin.x + 70
        let r1 = (120.0 / Double(bgMusic!.bpm!)) * moveSpeedPerSecond + Double(goalPosition)
        let offset = CGFloat(r1) - self.obstaclesParent!.position.x
        
        // Adds a new obstacle to the parent node
        self.obstaclesParent?.addChild(ObstacleNode(offset: offset))
        print(obstaclesParent?.position.x, offset)
        print(playerOrigin.x)
        
        self.moveSpeedPerSecond *= 1.01
    }
}
