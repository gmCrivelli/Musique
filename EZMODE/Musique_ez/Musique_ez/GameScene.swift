
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
    
    // Obstacle-related properties
    private var obstaclesParent : SKNode?
    private var baseMoveSpeedPerSecond = 500.0
    private var moveSpeedPerSecond = 500.0
    private var originalPosition : CGPoint?
    private var scoreCollider : SKNode!
    
    //Paralax elements
    private var flyingScenarioObjects : SKNode?
    private var groundedScenarioObjects : SKNode?
    
    // Configure contact masks
    private let playerCategory : UInt32 = 0b1
    private let floorCategory : UInt32 = 0b10
    private let obstacleCategory : UInt32 = 0b100
    private let scoreCategory : UInt32 = 0b1000
    
    // Preloaded actions
    private var jumpAction : SKAction!
    private var spawnObstacleAction : SKAction!
    private var crashAction : SKAction!
    private var timerAction : SKAction!
    private var timedActions : [SKAction] = []
    
    private var paralaxScenarioNodeA : SKSpriteNode!
    private var paralaxScenarioNodeB : SKSpriteNode!
    private var originalScenarioPosition : CGPoint!
    private var tileMap : SKTileMapNode!
    
    private var screenEnd : CGFloat!
    
    // Labels and Interface
    private var scoreLabel : SKLabelNode!
    private var multiplierLabel : SKLabelNode!
    private var finger : SKSpriteNode!
    private var floorHeight: CGFloat!

    private var bgMusic:Sound?
    private var gruntSound:Sound?
    
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
    
    override func didMove(to view: SKView) {
        
        //Setup all music
        let filePath = URL(fileURLWithPath: Bundle.main.path(forResource: "The_Muffin_Man", ofType: "mp3")!)
        bgMusic = Sound(url: filePath, bpm: 90)
        
        let gruntPath = URL(fileURLWithPath: Bundle.main.path(forResource: "grunt1", ofType: "wav")!)
        gruntSound = Sound(url: gruntPath)
    
        //Configure background
        self.flyingScenarioObjects = childNode(withName: "Flying Scenario Objects")
        self.groundedScenarioObjects = childNode(withName: "Grounded Scenario Objects")
        
        self.paralaxScenarioNodeA = childNode(withName: "ParalaxScenario1") as! SKSpriteNode
        self.paralaxScenarioNodeB = childNode(withName: "ParalaxScenario2") as! SKSpriteNode
        
        screenEnd = CGFloat((scene?.size.width)! / 2)
        
        self.scoreCollider = childNode(withName: "scoreCollider") as! SKSpriteNode
        self.scoreCollider.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        self.scoreCollider.physicsBody?.categoryBitMask = scoreCategory
        self.scoreCollider.physicsBody?.collisionBitMask = 0
        self.scoreCollider.physicsBody?.contactTestBitMask = obstacleCategory
        self.scoreCollider.physicsBody?.affectedByGravity = false
        
        // Configure HUD
        self.scoreLabel = childNode(withName: "score") as! SKLabelNode
        self.multiplierLabel = childNode(withName: "multiplier") as! SKLabelNode
        self.finger = childNode(withName: "Finger") as! SKSpriteNode
        
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
        let goDownAction = SKAction.move(by: CGVector(dx: 0, dy: -40), duration: 0)
        let goUpAction = SKAction.move(by: CGVector(dx: 0, dy: 40), duration: 60.0 / Double(bgMusic!.bpm!))
        let tutorialBounce = SKAction.sequence([goDownAction, goUpAction])
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
        
        let customJumpUp = SKEase.move(easeFunction: CurveType.curveTypeCubic, easeType: EaseType.easeTypeOut, time: 0.225, from: initialPosition, to: initialPosition + CGPoint(x: 0, y: 120))
        let customJumpDown = SKEase.move(easeFunction: CurveType.curveTypeCubic, easeType: EaseType.easeTypeIn, time: 0.225, from: initialPosition + CGPoint(x: 0, y: 120), to: initialPosition)
        let jumpSequence = SKAction.sequence([customJumpUp, customJumpDown])
        
        let rotateAction = SKAction.rotate(byAngle: -2 * CGFloat(Double.pi), duration: 0.45)
        let jumpSoundAction = SKAction.playSoundFileNamed("jump.wav", waitForCompletion: false)
        self.jumpAction = SKAction.group([jumpSoundAction, jumpSequence, rotateAction])
        
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
        self.finger.run(tutorialSequence)
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
            if (contact.bodyA.node as! ObstacleNode).wasHit == 0 {
                (contact.bodyA.node as! ObstacleNode).wasHit = 2
                self.obstaclesJumpedInaRow += 1
                self.totalObstaclesJumped += 1
                self.score = self.score + self.multiplierArray[self.multiplier] * (contact.bodyA.node as! ObstacleNode).baseScore
                
                self.multiplier = min(5, (obstaclesJumpedInaRow / 5) + 1)
            }
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
        
        paralaxScenarioNodeA.position = CGPoint(x: paralaxScenarioNodeA.position.x - (actualOffset / 7), y: paralaxScenarioNodeA.position.y)
        paralaxScenarioNodeB.position = CGPoint(x: paralaxScenarioNodeB.position.x - (actualOffset / 7), y: paralaxScenarioNodeB.position.y)
        
        if paralaxScenarioNodeA.position.x <= -screenEnd{
            paralaxScenarioNodeA.position.x = screenEnd + paralaxScenarioNodeA.size.width
        }
        
        if paralaxScenarioNodeB.position.x <= -screenEnd{
            paralaxScenarioNodeB.position.x = screenEnd + paralaxScenarioNodeB.size.width
        }
    
        moveScenarioObjects(flyingScenarioObjects!, atLayer: 8)
        moveScenarioObjects(groundedScenarioObjects!, atLayer: 3)
        
        // Move obstacles
        if let obstaculos = obstaclesParent?.children{
            // For each obstacle
            for obs in obstaculos{
                let obs = obs as! ObstacleNode
                // Updates the obstacle position at the same rate as the ground
                obs.update(dt)
                //obs.position = CGPoint(x: obs.position.x - actualOffset, y: obs.position.y)
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
        
        let goalPosition = self.playerOrigin.x + 150
        let r1 = (120.0 / Double(bgMusic!.bpm!)) * moveSpeedPerSecond + Double(goalPosition)
        let offset = CGFloat(r1) - self.obstaclesParent!.position.x
        
        // Adds a new obstacle to the parent node
        self.obstaclesParent?.addChild(ObstacleNode(speedPerSec: self.moveSpeedPerSecond, offset: offset))
        print(obstaclesParent?.position.x ?? 0, offset)
        print(playerOrigin.x)
        
        self.moveSpeedPerSecond *= 1.01
    }
}
