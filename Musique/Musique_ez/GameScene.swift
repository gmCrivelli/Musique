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
    private var playerInvincibilityTime : TimeInterval = 0.5
    private var playerSoundArray : [Int] = [0,1,0,1,0,1,0,2]
    private var playerSound : Int = 0
    
    // Obstacle-related properties
    private var obstaclesParent : SKNode?
    private var baseMoveSpeedPerSecond = 1500.0
    private var moveSpeedPerSecond = 1500.0
    private var originalPosition : CGPoint?
    private var scoreCollider : SKNode!
    private var tutorialCollider : SKNode!
    
    //Paralax elements
    private var flyingScenarioObjects : SKNode?
    private var groundedScenarioObjects : SKNode?
    
    // Configure contact masks
    private let playerCategory : UInt32 = 0b1
    private let floorCategory : UInt32 = 0b10
    private let obstacleCategory : UInt32 = 0b100
    private let scoreCategory : UInt32 = 0b1000
    private let particleCategory : UInt32 = 0b10000
    
    // Preloaded actions
    private var jumpAction : SKAction!
    private var spawnObstacleAction : SKAction!
    private var crashAction : SKAction!
    private var timerAction : SKAction!
    private var timedActions : [SKAction] = []
    private var jumpSfxArray : [SKAction] = []
    
    //Paralax Components
    private var paralaxScenarioNodeA1 : SKSpriteNode!
    private var paralaxScenarioNodeA2 : SKSpriteNode!
    private var paralaxScenarioNodeB1 : SKSpriteNode!
    private var paralaxScenarioNodeB2 : SKSpriteNode!
    private var originalScenarioPosition : CGPoint!
    private var tileMap : SKTileMapNode!
    
    private var screenEnd : CGFloat!
    
    //Tutorial components
    private var tutorialAlphaBlend : SKSpriteNode!
    private var tutorialPointingFinger : SKSpriteNode!
    
    // Labels and Interface
    private var scoreLabel : SKLabelNode!
    private var multiplierLabel : SKLabelNode!
    
    private var floorHeight: CGFloat!
    
    private var isGamePaused = false

    private var bgMusic:Sound?
    private var gruntSound:Sound?
    
    var obstacleTextures = [SKTexture]()
    
    private var score : Int! {
        didSet {
            scoreLabel.text = String(format: "%06d", score!)
        }
    }
    
    private var multiplierArray = [-1,1,2,4,8,16]
    private var multiplier : Int!
    
    private var totalObstaclesJumped : Int = 0
    private var obstaclesJumpedInaRow : Int = 0
    private let neededForMultiplier : Int = 5
    
    //Point where objects and obstacles unspawn from the scene
    var unspawnPoint : CGFloat!
    
    override func didMove(to view: SKView) {
        
        //Setup all music
        let filePath = URL(fileURLWithPath: Bundle.main.path(forResource: "The_Muffin_Man", ofType: "mp3")!)
        bgMusic = Sound(url: filePath, bpm: 90)
        
        let gruntPath = URL(fileURLWithPath: Bundle.main.path(forResource: "grunt1", ofType: "wav")!)
        gruntSound = Sound(url: gruntPath)
    
        //Configure background
        self.flyingScenarioObjects = childNode(withName: "Flying Scenario Objects")
        self.groundedScenarioObjects = childNode(withName: "Grounded Scenario Objects")
        
        self.paralaxScenarioNodeA1 = childNode(withName: "ParalaxScenarioA1") as! SKSpriteNode
        self.paralaxScenarioNodeA2 = childNode(withName: "ParalaxScenarioA2") as! SKSpriteNode
        
        self.paralaxScenarioNodeB1 = childNode(withName: "ParalaxScenarioB1") as! SKSpriteNode
        self.paralaxScenarioNodeB2 = childNode(withName: "ParalaxScenarioB2") as! SKSpriteNode
        
        self.tutorialPointingFinger = childNode(withName: "tutorialFinger") as! SKSpriteNode
        
        screenEnd = CGFloat((scene?.size.width)!)
        unspawnPoint = -(scene?.size.width)! - ((scene?.size.width)! / 2)
        
        obstacleTextures.append(SKTexture(imageNamed: "Hidrante"))
        obstacleTextures.append(SKTexture(imageNamed: "Lixo"))
        
        self.scoreCollider = childNode(withName: "scoreCollider") as! SKSpriteNode
        self.scoreCollider.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        self.scoreCollider.physicsBody?.categoryBitMask = scoreCategory
        self.scoreCollider.physicsBody?.collisionBitMask = 0
        self.scoreCollider.physicsBody?.contactTestBitMask = obstacleCategory
        self.scoreCollider.physicsBody?.affectedByGravity = false
        
        // Configure HUD
        self.scoreLabel = childNode(withName: "score") as! SKLabelNode
        self.multiplierLabel = childNode(withName: "multiplier") as! SKLabelNode
        
        // Get player node from scene and store it for use later
        self.player = self.childNode(withName: "Player") as? SKSpriteNode
        self.player.physicsBody?.categoryBitMask = playerCategory
        self.player.physicsBody?.collisionBitMask = 0 //floorCategory
        self.player.physicsBody?.contactTestBitMask = floorCategory | obstacleCategory
        self.player.physicsBody?.restitution = 0
        self.player.physicsBody?.affectedByGravity = false
        
        self.playerOrigin = self.player.position
        
        let playerAnimatedAtlas = SKTextureAtlas(named: "Heroi")
        var walkFrames = [SKTexture]()
        
        let numImages = playerAnimatedAtlas.textureNames.count
        
        for i in 1 ..< numImages {
            let playerTextureName = "Heroi\(i)"
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
        
        ///MARK: Setup actions
        
        // Synchronizer for a few actions
        let triggerAction = SKAction.run { [weak self] in
            for action in self!.timedActions {
                self?.run(action)
            }
        }
        let waitForNext = SKAction.wait(forDuration: 60.0 / Double(bgMusic!.bpm!))
        self.timerAction = SKAction.sequence([waitForNext, triggerAction])
        
        let multiplierAction = SKAction.run { [weak self] in
            self?.multiplierLabel.text = "\(self?.multiplierArray[(self?.multiplier!)!] ?? 1)x"
            
            let scaleAction = SKEase.scale(easeFunction: .curveTypeQuadratic , easeType: .easeTypeOut, time: 60.0 / Double((self?.bgMusic?.bpm)!), from: CGFloat(sqrt(sqrt(Double((self?.multiplier!)! + 1)))), to: 1.0)
            
            self?.multiplierLabel.run(scaleAction)
        }
        self.timedActions.append(multiplierAction)
        
        //Tutorial action
        let goDownAction = SKAction.move(by: CGVector(dx: 0, dy: -40), duration: 60.0 / Double(bgMusic!.bpm!))
        let goUpAction = SKAction.move(by: CGVector(dx: 0, dy: 40), duration: 0.0)
        let tutorialBounce = SKAction.sequence([goUpAction, goDownAction])
        let tutorialSequence = SKAction.sequence([SKAction.repeat(tutorialBounce, count: 10),
                                                  SKAction.fadeOut(withDuration: 0.4)])
        
        let createObstacleAction = SKAction.run { [weak self] in
            self?.addObstacle()
        }

        let obstacleSequence = SKAction.sequence([createObstacleAction, waitForNext])
        self.spawnObstacleAction = SKAction.repeatForever(obstacleSequence)
        
        let initialPosition = player.position
        let customJumpAction = SKAction.customAction(withDuration: 0.4, actionBlock: { (node, timeElapsed) in
            let t = CGFloat(Double.pi) * timeElapsed / 0.4

            node.position = CGPoint(x: initialPosition.x, y: initialPosition.y + 120 * sin(t))
            })
        
        let customJumpUp = SKEase.move(easeFunction: CurveType.curveTypeCubic, easeType: EaseType.easeTypeOut, time: 0.225, from: initialPosition, to: initialPosition + CGPoint(x: 0, y: (self.scene?.size.height)! / 7))
        let customJumpDown = SKEase.move(easeFunction: CurveType.curveTypeCubic, easeType: EaseType.easeTypeIn, time: 0.225, from: initialPosition + CGPoint(x: 0, y: (self.scene?.size.height)! / 7), to: initialPosition)
        let jumpSequence = SKAction.sequence([customJumpUp, customJumpDown])
        
        let rotateAction = SKAction.rotate(byAngle: -2 * CGFloat(Double.pi), duration: 0.45)
        self.jumpAction = SKAction.group([jumpSequence, rotateAction])
        
        let createFlyingObjectAction = SKAction.run {
            self.spawnScenarioObject(isGroundObject: false)
        }
        
        let createGroundedObjectAction = SKAction.run {
            self.spawnScenarioObject(isGroundObject: true)
        }
    
        let waitForNextGroundedScenarioObject = SKAction.wait(forDuration: 0.6)
        let groundedObjectsSequence = SKAction.sequence([createGroundedObjectAction, waitForNextGroundedScenarioObject])
        self.run(SKAction.sequence([SKAction.wait(forDuration: 0),SKAction.repeatForever(groundedObjectsSequence)]))
        
        // Sound actions
        
        let gruntAction = SKAction.playSoundFileNamed("grunt1.wav", waitForCompletion: false)
        
        let bumboAction = SKAction.playSoundFileNamed("bumbo.wav", waitForCompletion: false)
        let caixaAction = SKAction.playSoundFileNamed("caixa.wav", waitForCompletion: false)
        let pratoAction = SKAction.playSoundFileNamed("prato.wav", waitForCompletion: false)
        self.jumpSfxArray = [bumboAction, caixaAction, pratoAction]
        
        // Visual effects actions
        
        let blinkAction = SKAction.fadeAlpha(to: 0.0, duration: playerInvincibilityTime / 4.0)
        let unblinkAction = SKAction.fadeAlpha(to: 1.0, duration: playerInvincibilityTime / 4.0)
        
        let blinkSequence = SKAction.sequence([blinkAction, unblinkAction, blinkAction, unblinkAction])
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
        self.tutorialPointingFinger.run(tutorialSequence)
        self.run(SKAction.repeatForever(timerAction))
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
            player.run(jumpAction) {
                self.playerState = .onFloor
                self.startWalking()
            }
            self.run(jumpSfxArray[playerSoundArray[playerSound]])
            print("Player Sound: \(playerSound)")
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
            
            self.moveSpeedPerSecond = self.baseMoveSpeedPerSecond
            self.multiplier = 1
            self.obstaclesJumpedInaRow = 0
            playerIsInvincible = true
            player.run(crashAction) { self.playerIsInvincible = false }
            (contact.bodyB.node as! ObstacleNode).wasHit = 1 
        }
        
        // Obstacle collides with scoreCollider
        if (contact.bodyA.categoryBitMask ==  obstacleCategory) &&
            (contact.bodyB.categoryBitMask == scoreCategory) {
            
            // Update player sound
            self.playerSound = (self.playerSound + 1) % 8
            
            // Compute score and other player-related effects
            if (contact.bodyA.node as! ObstacleNode).wasHit == 0 {
                (contact.bodyA.node as! ObstacleNode).wasHit = 2
                self.obstaclesJumpedInaRow += 1
                self.totalObstaclesJumped += 1
                self.score = self.score + self.multiplierArray[self.multiplier] * (contact.bodyA.node as! ObstacleNode).baseScore
                
                self.multiplier = min(5, (obstaclesJumpedInaRow / 5) + 1)
            }
        }
        
        // Player collides with particleCollider
        if (contact.bodyA.categoryBitMask == playerCategory) &&
            (contact.bodyB.categoryBitMask == particleCategory) {
            
            let emitter = SKEmitterNode(fileNamed: "SparkParticle")
            contact.bodyB.node?.addChild(emitter!)
            emitter?.run(SKAction.sequence([SKAction.wait(forDuration: 1.0), SKAction.removeFromParent()]))
        }
        
    }
    
    func randomizeTexture(isGroundObject: Bool) -> SKTexture{
        var textures = [SKTexture]()
        
        if(isGroundObject){
            textures.append(SKTexture(imageNamed: "Bricks"))

        }else{
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
        
        paralaxScenarioNodeA1.position = CGPoint(x: paralaxScenarioNodeA1.position.x - (actualOffset / 7), y: paralaxScenarioNodeA1.position.y)
        paralaxScenarioNodeA2.position.x = paralaxScenarioNodeA1.position.x
        paralaxScenarioNodeB1.position = CGPoint(x: paralaxScenarioNodeB1.position.x - (actualOffset / 7), y: paralaxScenarioNodeB1.position.y)
        paralaxScenarioNodeB2.position.x = paralaxScenarioNodeB1.position.x
        
        if paralaxScenarioNodeA1.position.x <= 0{
            paralaxScenarioNodeA1.position.x = paralaxScenarioNodeB1.position.x + paralaxScenarioNodeA1.size.width
            paralaxScenarioNodeA2.position.x = paralaxScenarioNodeB2.position.x + paralaxScenarioNodeA2.size.width
        }
        
        if paralaxScenarioNodeB1.position.x <= 0{
            paralaxScenarioNodeB1.position.x = paralaxScenarioNodeA1.position.x + paralaxScenarioNodeB1.size.width
            paralaxScenarioNodeB2.position.x = paralaxScenarioNodeA2.position.x + paralaxScenarioNodeB2.size.width
        }
    
        moveScenarioObjects(flyingScenarioObjects!, atLayer: 8)
        moveScenarioObjects(groundedScenarioObjects!, atLayer: 3)
        
        // Move obstacles
        if let obstaculos = obstaclesParent?.children {
            // For each obstacle
            for obs in obstaculos{
                let obs = obs as! ObstacleNode
                // Updates the obstacle position at the same rate as the ground
                obs.update(dt)
                //obs.position = CGPoint(x: obs.position.x - actualOffset, y: obs.position.y)
                // In case the obstacle has reached the outside of the screen
                if(obs.position.x < unspawnPoint){
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
            if(obj.position.x < unspawnPoint){
                // Removes the object from the parent node to avoid excessive memory use
                obj.removeFromParent()
            }
        }
        
    }
    
    @objc func addObstacle() -> Void{
        
        let goalPosition = self.playerOrigin.x + (scene?.size.width)!
        let r1 = (120.0 / Double(bgMusic!.bpm!)) * moveSpeedPerSecond + Double(goalPosition)
        let offset = CGFloat(r1) - self.obstaclesParent!.position.x
        
        // Adds a new obstacle to the parent node
        let random = Int(arc4random_uniform(UInt32(obstacleTextures.count)))
        self.obstaclesParent?.addChild(ObstacleNode(speedPerSec: self.moveSpeedPerSecond, offset: offset, texture: obstacleTextures[random]))
        print(obstaclesParent?.position.x, offset)
        print(playerOrigin.x)
        
        self.moveSpeedPerSecond *= 1.01
    }
}
