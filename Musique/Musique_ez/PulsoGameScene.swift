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

enum GameState : Int {
    case playing = 1
    case gameOver = 2
}

enum PlayerState : Int {
    case onFloor = 1
    case jumping = 2
}

enum SFX : Int {
    case bumbo = 0
    case caixa = 1
    case prato = 2
}

struct Music {
    
    static let configArray = [("funny_song",90,[false,true]),
                              ("dancing_on_green_grass",96,[false,true]),
                              ("splashing_around",102.5,[false,true])]
    
    var obstacleSpawns : [Bool] = []
    var bpm : Double
    var music : Sound
    
    init(url: URL, bpm: Double) {
        self.bpm = bpm
        self.music = Sound(url: url)
    }
    
    func play(completion: @escaping () -> Void) {
        self.music.play(completion)
    }
    
    func getDuration() -> TimeInterval {
        return self.music.getDuration()
    }
}

class PulsoGameScene: SKScene, SKPhysicsContactDelegate {
    
    var worldNode: SKNode!
    
    weak public var viewControllerDelegate : GameFinishedDelegate!
    
    private var gameState : GameState!
    
    // Time control
    private var lastUpdateTime: TimeInterval = 0
    private var dt: TimeInterval = 0
    
    // Timing control (one step = half beat)
    private var multiplierBlinks : [Bool] = [false, true]
    private var multiplierTiming : Int = 0
    private var obstacleTiming : Int = 0
    
    // Player-related properties
    private var playerState : PlayerState = .onFloor
    private var playerAccel = CGPoint(x: 0, y: -6000)
    private var playerVel = CGPoint(x: 0, y: 0)
    private var playerOrigin : CGPoint!
    private var player : SKSpriteNode!
    private var playerWalkingFrames : [SKTexture]!
    private var playerHurtFrames : [SKTexture]!
    private var playerIsInvincible : Bool = false
    private var playerInvincibilityTime : TimeInterval = 0.5
    private var playerSoundArray : [SFX] = [.bumbo,.caixa,.bumbo,.caixa,.bumbo,.caixa,.bumbo,.prato]
    private var playerSound : Int = 3
    
    // Obstacle-related properties
    private var obstaclesParent : SKNode?
    private var baseMoveSpeedPerSecond = 1500.0
    private var moveSpeedPerSecond = 1500.0
    private var originalPosition : CGPoint?
    private var scoreCollider : SKNode!
    private var tutorialCollider : SKNode!
    
    //Paralax elements
    private var groundedScenarioObjects : SKNode?
    
    // Configure contact masks
    private let playerCategory : UInt32 = 0b1
    private let floorCategory : UInt32 = 0b10
    private let obstacleCategory : UInt32 = 0b100
    private let scoreCategory : UInt32 = 0b1000
    private let particleCategory : UInt32 = 0b10000
    
    // Preloaded actions
    private var metronomeSoundAction : SKAction!
    private var jumpAction : SKAction!
    private var spawnObstacleAction : SKAction!
    private var crashAction : SKAction!
    private var timerAction : SKAction!
    private var tutorialAction : SKAction!
    private var moveTimelineAction : SKAction!
    private var timedActions : [SKAction] = []
    private var jumpSfxArray : [SKAction] = []
    
    //Paralax Components
    private weak var cityFrontA : SKSpriteNode!
    private weak var cityFrontB : SKSpriteNode!
    private weak var cityBackA : SKSpriteNode!
    private weak var cityBackB : SKSpriteNode!
    private var originalScenarioPosition : CGPoint!
    private weak var housesTileMapA : SKTileMapNode!
    private weak var housesTileMapB : SKTileMapNode!
    private weak var streetA : SKSpriteNode!
    private weak var streetB : SKSpriteNode!
    
    private var screenEnd : CGFloat!
    
    //Tutorial components
    private var tutorialAlphaBlend : SKSpriteNode!
    private var tutorialPointingFinger : SKSpriteNode!
    
    // Labels and Interface
    private var endGameNode : EndGameNode?
    private var pauseGameNode : PauseGameNode?
    private var scoreLabel : SKLabelNode!
    private var multiplierLabel : SKLabelNode!
    private var pauseButton : SKSpriteNode!
    private var timeBody : SKSpriteNode!
    
    private var floorHeight: CGFloat!
    
    private var isGamePaused = false
    
    private var bgMusic: Music!
    
    var obstacleTextures : [SKTexture]!
    
    private var score : Int! {
        didSet {
            scoreLabel.text = String(format: "%06d", score!)
        }
    }
    
    private var multiplierArray = [-1,1,2,4,8,16]
    private var multiplier : Int!
    
    private var totalObstaclesJumped : Float = 0
    private var obstaclesJumpedInaRow : Int = 0
    private let neededForMultiplier : Int = 5
    private var obstaclesTotal : Float = 0
    
    //Pause nodes
    private var pauseScreenNode : SKNode!
    private var pauseOffset : Double = 0
    private var startCountdownNode : SKLabelNode!
    
    //Point where objects and obstacles unspawn from the scene
    var unspawnPoint : CGFloat!
    
    var musicPulse : MusicPulse!
    
    override func didMove(to view: SKView) {
        
        // Do all setup separately
        setupAll()
        startGame()
    }
    
    // MARK: Setups
    
    func setupAll() {
        
        setupInitialValues()
        setupMusic()
        setupNodes()
        setupAnimations()
        setupActions()
        setupWhatever()
    }
    
    func setupInitialValues() {
        
        self.totalObstaclesJumped = 0
        self.obstaclesJumpedInaRow = 0
        self.obstaclesTotal = 0
        self.timedActions = []
        self.multiplier = 1
        self.moveSpeedPerSecond = 1500.0
        self.gameState = .playing
        self.obstacleTextures = [SKTexture]()
        self.isGamePaused = false
    }
    
    func setupMusic() {
        // CHOOSE MUSIC:
        
        let filePath = URL(fileURLWithPath: Bundle.main.path(forResource: musicPulse.fileName , ofType: musicPulse.fileExtension)!)
        bgMusic = Music(url: filePath, bpm: musicPulse.bpm)
        bgMusic.obstacleSpawns = [false,true]
    }
    
    func setupNodes() {
        //Configure background
        self.worldNode = childNode(withName: "world")
        
        self.groundedScenarioObjects = worldNode.childNode(withName: "groundScenarioObjects")
        
        self.cityFrontA = worldNode.childNode(withName: "cityFrontA") as! SKSpriteNode
        self.cityFrontB = worldNode.childNode(withName: "cityFrontB") as! SKSpriteNode
        
        self.cityBackA = worldNode.childNode(withName: "cityBackA") as! SKSpriteNode
        self.cityBackB = worldNode.childNode(withName: "cityBackB") as! SKSpriteNode
        
        self.housesTileMapA = worldNode.childNode(withName: "housesTileMapA") as! SKTileMapNode
        self.housesTileMapB = worldNode.childNode(withName: "housesTileMapB") as! SKTileMapNode
        
        self.streetA = worldNode.childNode(withName: "streetA") as! SKSpriteNode
        self.streetB = worldNode.childNode(withName: "streetB") as! SKSpriteNode
        
        self.tutorialPointingFinger = worldNode.childNode(withName: "tutorialFinger") as! SKSpriteNode
        
        screenEnd = CGFloat((scene?.size.width)!)
        unspawnPoint = -(scene?.size.width)! - ((scene?.size.width)! / 2)
        
        obstacleTextures.append(SKTexture(imageNamed: "hidrant"))
        obstacleTextures.append(SKTexture(imageNamed: "trash"))
        
        self.pauseButton = worldNode.childNode(withName: "pauseButton") as! SKSpriteNode
        
        self.pauseScreenNode = childNode(withName: "pauseScreen")
        self.pauseScreenNode.isHidden = true
        
        self.startCountdownNode = pauseScreenNode.childNode(withName: "countdown") as! SKLabelNode
        
        self.scoreCollider = worldNode.childNode(withName: "scoreCollider") as! SKSpriteNode
        self.scoreCollider.physicsBody = SKPhysicsBody(circleOfRadius: 70)
        self.scoreCollider.physicsBody?.categoryBitMask = scoreCategory
        self.scoreCollider.physicsBody?.collisionBitMask = 0
        self.scoreCollider.physicsBody?.contactTestBitMask = obstacleCategory
        self.scoreCollider.physicsBody?.affectedByGravity = false
        
        // Configure HUD
        self.scoreLabel = worldNode.childNode(withName: "score") as! SKLabelNode
        self.multiplierLabel = worldNode.childNode(withName: "multiplier") as! SKLabelNode
        self.timeBody = worldNode.childNode(withName: "timebody") as! SKSpriteNode
        
        // Get player node from scene and store it for use later
        self.player = worldNode.childNode(withName: "Player") as? SKSpriteNode
        self.player.position = CGPoint(x: 336, y: 500)
        let ppb = SKPhysicsBody(circleOfRadius: player.size.height * 0.35)
        ppb.categoryBitMask = playerCategory
        ppb.collisionBitMask = 0 //floorCategory
        ppb.contactTestBitMask = floorCategory | obstacleCategory
        ppb.restitution = 0
        ppb.affectedByGravity = false
        self.player.physicsBody = ppb
        
        self.playerOrigin = self.player.position
        
        // Setup ground
        self.streetA.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: streetA.size.width, height: streetA.size.height))
        self.streetA.physicsBody?.affectedByGravity = false
        self.streetA.physicsBody?.isDynamic = false
        self.streetA.physicsBody?.categoryBitMask = floorCategory
        self.streetA.physicsBody?.fieldBitMask = 0
        self.streetA.physicsBody?.restitution = 0
        
        self.streetB.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: streetB.size.width, height: streetB.size.height))
        self.streetB.physicsBody?.affectedByGravity = false
        self.streetB.physicsBody?.isDynamic = false
        self.streetB.physicsBody?.categoryBitMask = floorCategory
        self.streetB.physicsBody?.fieldBitMask = 0
        self.streetB.physicsBody?.restitution = 0
        
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -22)
    }
    
    func setupAnimations() {
        
        let playerAnimatedAtlas = SKTextureAtlas(named: "Heroi")
        var walkFrames = [SKTexture]()
        for i in 1 ..< playerAnimatedAtlas.textureNames.count {
            walkFrames.append(playerAnimatedAtlas.textureNamed("Heroi\(i)"))
        }
        playerWalkingFrames = walkFrames
        
        let playerHurtAtlas = SKTextureAtlas(named: "HeroiFerido")
        var hurtFrames = [SKTexture]()
        for i in 1 ..< playerHurtAtlas.textureNames.count {
            hurtFrames.append(playerHurtAtlas.textureNamed("aff\(i)"))
        }
        playerHurtFrames = hurtFrames
        
        player.texture = playerWalkingFrames[0]
    }
    
    func setupActions() {
        // Synchronizer for a few actions
        let triggerAction = SKAction.run { [weak self] in
            for action in self!.timedActions {
                self?.run(action)
            }
        }
        let waitForNext = SKAction.wait(forDuration: 30.0 / bgMusic!.bpm)
        self.timerAction = SKAction.sequence([waitForNext, triggerAction])
        
        let multiplierAction = SKAction.run { [weak self] in
            self?.blinkMultiplier()
        }
        self.timedActions.append(multiplierAction)
        
        let createObstacleAction = SKAction.run { [weak self] in
            self?.addObstacle()
        }
        self.timedActions.append(createObstacleAction)
        
        //Tutorial action
        let goDownAction = SKAction.move(by: CGVector(dx: 0, dy: -40), duration: 60.0 / bgMusic!.bpm)
        let goUpAction = SKAction.move(by: CGVector(dx: 0, dy: 40), duration: 0.0)
        let tutorialBounce = SKAction.sequence([goUpAction, goDownAction])
        self.tutorialAction = SKAction.sequence([SKAction.repeat(tutorialBounce, count: 10),
                                                  SKAction.fadeOut(withDuration: 0.4)])
        
        // Player Movement actions
        let initialPosition = player.position
        let customJumpUp = SKEase.move(easeFunction: CurveType.curveTypeCubic, easeType: EaseType.easeTypeOut, time: 0.225, from: initialPosition, to: initialPosition + CGPoint(x: 0, y: (self.scene?.size.height)! / 7))
        let customJumpDown = SKEase.move(easeFunction: CurveType.curveTypeCubic, easeType: EaseType.easeTypeIn, time: 0.225, from: initialPosition + CGPoint(x: 0, y: (self.scene?.size.height)! / 7), to: initialPosition)
        let jumpSequence = SKAction.sequence([customJumpUp, customJumpDown])
        
        let rotateAction = SKAction.rotate(byAngle: -2 * CGFloat(Double.pi), duration: 0.45)
        self.jumpAction = SKAction.group([jumpSequence, rotateAction])
        
        let createGroundedObjectAction = SKAction.run {
            [weak self] in
            self?.spawnScenarioObject(isGroundObject: true)
        }
        
        let waitForNextGroundedScenarioObject = SKAction.wait(forDuration: 1.2)
        let groundedObjectsSequence = SKAction.sequence([createGroundedObjectAction, waitForNextGroundedScenarioObject])
        self.worldNode.run(SKAction.sequence([SKAction.wait(forDuration: 0),SKAction.repeatForever(groundedObjectsSequence)]))
        
        // Sound actions
        self.metronomeSoundAction = SKAction.playSoundFileNamed("metronome_low.wav", waitForCompletion: false)
        let gruntAction = SKAction.playSoundFileNamed("grunt1.wav", waitForCompletion: false)
        
        let bumboAction = SKAction.playSoundFileNamed("bumbo.wav", waitForCompletion: false)
        let caixaAction = SKAction.playSoundFileNamed("caixa.wav", waitForCompletion: false)
        let pratoAction = SKAction.playSoundFileNamed("prato.wav", waitForCompletion: false)
        self.jumpSfxArray = [bumboAction, caixaAction, pratoAction]
        
        // Visual effects actions
        let blinkAction = SKAction.fadeAlpha(to: 0.0, duration: playerInvincibilityTime / 4.0)
        let unblinkAction = SKAction.fadeAlpha(to: 1.0, duration: playerInvincibilityTime / 4.0)
        let hurtAnimationAction = SKAction.run({
            [weak self] in self?.animateHurt()
        })
        let unhurtAnimationAction = SKAction.run({
            [weak self] in self?.startWalking()
        })
        
        let blinkSequence = SKAction.sequence([blinkAction, unblinkAction, blinkAction, unblinkAction, unhurtAnimationAction])
        self.crashAction = SKAction.group([hurtAnimationAction, gruntAction, blinkSequence])
        
        // Timeline action
        self.moveTimelineAction = SKAction.moveTo(x: 2258, duration: self.bgMusic.getDuration())
    }
    
    func setupWhatever() {
        // Setup obstacles
        self.obstaclesParent = worldNode.childNode(withName: "Obstacles")
        
        // Setup physics
        self.view?.showsPhysics = false
        self.physicsWorld.contactDelegate = self
        
        // Setup pause node
        if let pNode = self.pauseGameNode {
            pNode.setup(rectOf: self.size)
        }
        else {
            
            let pauseGameScene = SKScene(fileNamed: "PausedGameScene")
            
            self.pauseGameNode = pauseGameScene?.childNode(withName: "root") as? PauseGameNode
            self.pauseGameNode!.removeFromParent()
            self.addChild(self.pauseGameNode!)
            self.pauseGameNode!.setup(rectOf: self.size)
        }
        
        // Setup end game
        if let egNode = self.endGameNode {
            egNode.setup(rectOf: self.size)
        }
        else {
            
            let endGameScene = SKScene(fileNamed: "EndGameScene")
            
            self.endGameNode = endGameScene?.childNode(withName: "root") as? EndGameNode
            self.endGameNode!.removeFromParent()
            self.addChild(self.endGameNode!)
            self.endGameNode!.setup(rectOf: self.size)
        }
    }
    
    func startGame() {
        
        print(Thread.isMainThread)
        
        // Start the game
        self.timeBody.run(SKAction.move(to: CGPoint(x: 480, y: 1961), duration: 0.0))
        self.score = 0
        self.isGamePaused = false
        self.tutorialPointingFinger.run(tutorialAction)
        self.worldNode.run(SKAction.repeatForever(timerAction), withKey: "synchronizerAction")
        self.timeBody.run(moveTimelineAction)
        startWalking()
        
        bgMusic?.play{ [weak self] in
            self?.endGame()
            
            print("musica acabou")
        }
        
    }
    
    // Process touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isGamePaused {
            if pauseGameNode!.menuButton.contains((touches.first?.location(in: pauseGameNode!))!) {
                self.viewControllerDelegate.returnToSelection()
            }
            else if pauseGameNode!.restartButton.contains((touches.first?.location(in: pauseGameNode!))!) {
                
                self.worldNode.isPaused = false
                
                self.bgMusic.music.stop()
                self.worldNode.removeAction(forKey: "synchronizerAction")
                self.obstaclesParent?.removeAllChildren()
                
                removeAllActions()
                self.worldNode.removeAllActions()
                
                setupAll()
                resumeGame(type: 2)
            }
            else if pauseGameNode!.continueButton.contains((touches.first?.location(in: pauseGameNode!))!) {
                resumeGame(type: 1)
            }
        }
            
        else if gameState == .playing {
            
            if pauseButton.contains((touches.first?.location(in: worldNode!))!) {
                pauseGame()
            }
            else {
                self.jump()
            }
        }
            
        else if gameState == .gameOver {
            if endGameNode!.homeButton.contains((touches.first?.location(in: endGameNode!))!) {
                self.viewControllerDelegate.returnToSelection()
            }
            else if endGameNode!.restartButton.contains((touches.first?.location(in: endGameNode!))!) {
                
                print(Thread.isMainThread)
                
                removeAllActions()
                self.worldNode.removeAllActions()
            
                setupAll()
                startGame()
            }
        }
    }
    
    //Pause the game and display the pause menu
    func pauseGame() {
        self.pauseGameNode!.isHidden = false
        self.pauseGameNode!.displayBox(duration: 0.5)
        self.worldNode.isPaused = true
        //obstaclesParent?.isPaused = true
        isGamePaused = true
        bgMusic.music.pause()
    }
    
    func resumeGame(type: Int) {
        
        pauseScreenNode.isHidden = false
        pauseGameNode?.isHidden = true
        
        var currentNumber = 3
        
        let changeValueAction = SKAction.run {
            [weak self] in
            self?.startCountdownNode.text = "\(currentNumber)"
            let scaleAction = SKEase.scale(easeFunction: .curveTypeQuadratic , easeType: .easeTypeOut, time: 60.0 / (self?.bgMusic?.bpm)!, from: 1.3, to: 1.0)
            self?.startCountdownNode.run(scaleAction)
            self?.run((self?.metronomeSoundAction)!)
            currentNumber -= 1
        }
        
        let waitAction = SKAction.wait(forDuration: 60.0 / (self.bgMusic?.bpm)!)
        
        let sequence = SKAction.sequence([changeValueAction, waitAction])
        
        let loopAction = SKAction.repeat(sequence, count: 3)
        
        if(type == 1) {
            self.run(loopAction) { [weak self] in
                self?.worldNode.isPaused = false
                self?.bgMusic.music.play()
                self?.isGamePaused = false
                self?.pauseScreenNode.isHidden = true
            }
        }
        else {
            self.run(loopAction) { [weak self] in
                self?.startGame()
                self?.worldNode.isPaused = false
                self?.bgMusic.music.play()
                self?.isGamePaused = false
                self?.pauseScreenNode.isHidden = true
            }
        }
    }
    
    //End the game and perform the segue to the end screen
    func endGame() {
        let obstaclesPercent = (self.totalObstaclesJumped / max(1, self.obstaclesTotal)) * 100
        
        self.worldNode.removeAction(forKey: "synchronizerAction")
        self.obstaclesParent?.removeAllChildren()
        
        self.gameState = .gameOver
        
        self.endGameNode!.displayBox(duration: 0.5)
        self.worldNode.run(SKAction.sequence([SKAction.wait(forDuration: 1), SKAction.run { [weak self] in
            self?.endGameNode!.animateAllWithSound(score: (self?.score)!,
                                                  jumpedObstacles: Int((self?.totalObstaclesJumped)!),
                                                  totalObstacles: Int((self?.obstaclesTotal)!),
                                                  finalRank: Int(obstaclesPercent),
                                                  duration: 2.7)
            }]))
        
        musicPulse.lastScore = Int16(obstaclesPercent)
        if musicPulse.lastScore > musicPulse.highScore{
            musicPulse.highScore = Int16(obstaclesPercent)
        }
        
        MusicServices.updateMusic(music: musicPulse, nil)
        
        print(self.score, self.totalObstaclesJumped, self.obstaclesTotal, obstaclesPercent)
    }
    
    func startWalking() {
        
        self.player.removeAction(forKey: "hurtAnimation")
        player.run(SKAction.repeatForever(
            SKAction.animate(with: playerWalkingFrames, timePerFrame: 0.1)), withKey: "walkAnimation")
    }
    
    func animateHurt() {
        
        self.player.removeAction(forKey: "walkAnimation")
        self.player.run(SKAction.repeatForever(
            SKAction.animate(with: playerHurtFrames, timePerFrame: 0.1)), withKey: "hurtAnimation")
    }
    
    func jump() {
        if playerState == .onFloor {
            playerState = .jumping
            player.run(jumpAction) {
                self.playerState = .onFloor
                self.startWalking()
            }
            self.worldNode.run(jumpSfxArray[playerSoundArray[playerSound].rawValue])
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
        if (contact.bodyB.categoryBitMask == playerCategory) &&
            (contact.bodyA.categoryBitMask == obstacleCategory) &&
            !playerIsInvincible {
            
            self.moveSpeedPerSecond = self.baseMoveSpeedPerSecond
            self.multiplier = 1
            self.obstaclesJumpedInaRow = 0
            playerIsInvincible = true
            player.run(crashAction) { [weak self] in self?.playerIsInvincible = false }
            (contact.bodyA.node as! ObstacleNode).wasHit = 1
        }
        
        // Obstacle collides with scoreCollider
        if (contact.bodyA.categoryBitMask == obstacleCategory) &&
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
            
            self.obstaclesTotal += 1
            
            //print("ObstaclesTotal: \(self.obstaclesTotal) \n ObstaclesJumped: \(self.totalObstaclesJumped)")
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
        
        let randomNumber = Int(arc4random_uniform(7)) + 1
        let randomString = "tree\(randomNumber)"
        
        return SKTexture(imageNamed: randomString)
    }
    
    func spawnScenarioObject(isGroundObject : Bool){
        if(isGroundObject){
            groundedScenarioObjects!.addChild(ScenarioObjectNode(isGroundObject: true, layer: 0, texture: randomizeTexture(isGroundObject: true)))
        } else {
//            flyingScenarioObjects!.addChild(ScenarioObjectNode(isGroundObject: false, layer: 0, texture: randomizeTexture(isGroundObject: false)))
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
        
        if !self.isGamePaused {
        
            // Reset player horizontal position, to be safe
            player.position = CGPoint(x: playerOrigin.x, y: player.position.y)
            
            // Calculate actual distance elapsed since last update
            let actualOffset = CGFloat(moveSpeedPerSecond * dt)
            
            moveBackgroundObjects(objectA: streetA, objectB: streetB, velocity: actualOffset)
            moveBackgroundObjects(objectA: housesTileMapA, objectB: housesTileMapB, velocity: actualOffset)
            moveBackgroundObjects(objectA: cityBackA, objectB: cityBackB, velocity: actualOffset / 8)
            moveBackgroundObjects(objectA: cityFrontA, objectB: cityFrontB, velocity: actualOffset / 7)
            
            moveScenarioObjects(groundedScenarioObjects!, atLayer: 1)
            
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
    
    func moveBackgroundObjects(objectA: SKNode, objectB: SKNode, velocity: CGFloat){
        objectA.position = CGPoint(x: (objectA.position.x) - velocity, y: objectA.position.y)
        objectB.position = CGPoint(x: (objectB.position.x) - velocity, y: objectB.position.y)
        
        if objectA.position.x <= 0{
            objectA.position.x = objectB.position.x + objectA.frame.width
        }

        if objectB.position.x <= 0{
            objectB.position.x = objectA.position.x + objectB.frame.width
        }
    }
    
    @objc func blinkMultiplier(){
        
        if multiplierBlinks[multiplierTiming] {
            self.multiplierLabel.text = "\(self.multiplierArray[self.multiplier])x"
            
            let scaleAction = SKEase.scale(easeFunction: .curveTypeQuadratic , easeType: .easeTypeOut, time: 60.0 / (self.bgMusic?.bpm)!, from: CGFloat(sqrt(sqrt(Double(self.multiplier) + 1))), to: 1.0)
            
            self.multiplierLabel.run(scaleAction)
        }
        multiplierTiming = (multiplierTiming + 1) % multiplierBlinks.count
    }
    
    @objc func addObstacle() -> Void{
        
        if bgMusic.obstacleSpawns[obstacleTiming] {
            let goalPosition = self.playerOrigin.x// + (scene?.size.width)!
            let r1 = (220.0 / (1.5 * Double(bgMusic!.bpm))) * moveSpeedPerSecond + Double(goalPosition)
            let offset = CGFloat(r1) - self.obstaclesParent!.position.x
            
            // Adds a new obstacle to the parent node
            let random = Int(arc4random_uniform(UInt32(obstacleTextures.count)))
            self.obstaclesParent?.addChild(ObstacleNode(speedPerSec: self.moveSpeedPerSecond, offset: offset, texture: obstacleTextures[random]))
            
            //self.moveSpeedPerSecond = min(self.moveSpeedPerSecond * 1.01, 1.6 * self.baseMoveSpeedPerSecond)
        }
        obstacleTiming = (obstacleTiming + 1) % bgMusic.obstacleSpawns.count
    }
    
    deinit {
        self.removeAllActions()
        self.removeAllChildren()
        print("called deinit")
    }
}

