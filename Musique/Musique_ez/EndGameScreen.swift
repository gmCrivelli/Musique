//
//  EndGameScreen.swift
//  Musique_ez
//
//  Created by Gustavo De Mello Crivelli on 04/12/17.
//  Copyright © 2017 DoM7. All rights reserved.
//

import Foundation
import SpriteKit
import SpriteKitEasingSwift

class EndGameScreen : SKNode {
    
    
    // MARK: Properties
    
    // Child nodes
    private var darkenerRectangle : SKShapeNode!
    private var box : SKSpriteNode!
    
    private var scoreLabel : SKLabelNode!
    private var obstacleLabel : SKLabelNode!
    private var rankLabel : SKLabelNode!
    
    // Sound actions
    private var drumrollSoundAction : SKAction!
    private var endSoundActions : [SKAction] = []
    
    init(scene: SKScene) {
        
        super.init()
        
        // Setup child nodes
        self.box = self.childNode(withName: "box") as! SKSpriteNode
    
        self.scoreLabel = box?.childNode(withName: "scoreLabel") as! SKLabelNode
        self.obstacleLabel = box?.childNode(withName: "scoreLabel") as! SKLabelNode
        self.rankLabel = box?.childNode(withName: "scoreLabel") as! SKLabelNode
        
        // Darkener for the rest of the screen
        self.darkenerRectangle = SKShapeNode(rectOf: scene.size)
        self.darkenerRectangle.fillColor = .black
        self.darkenerRectangle.alpha = 0
        self.darkenerRectangle.zPosition = -1
        self.addChild(darkenerRectangle)
        
        // Setup sound actions
        self.drumrollSoundAction = SKAction.playSoundFileNamed("drum_roll.wav", waitForCompletion: false)
        
        let goodSoundAction = SKAction.playSoundFileNamed("good_end.wav", waitForCompletion: false)
        let midSoundAction = SKAction.playSoundFileNamed("mid_end.wav", waitForCompletion: false)
        let badSoundAction = SKAction.playSoundFileNamed("bad_end.wav", waitForCompletion: false)
        self.endSoundActions = [badSoundAction, midSoundAction, goodSoundAction]
    }
    
    // MARK: Show box on screen
    func displayBox(center: CGPoint, duration: TimeInterval) {
        
        self.box.alpha = 1
        
        let boxMoveAction = SKEase.move(easeFunction: .curveTypeElastic, easeType: .easeTypeOut, time: duration, from: box.position, to: center)
        
        let rectangleDarkenAction = SKAction.fadeAlpha(to: 0.3, duration: duration / 2)
        
        self.run(SKAction.group([boxMoveAction, rectangleDarkenAction]))
    }
    
    
    // MARK: Value tweening Actions
    func animateScore(score: Int, duration : TimeInterval) {
        
        let scoreTweenAction = SKAction.customAction(withDuration: duration){ (node, t) in
            let tweenedScore = Int(CGFloat(score) * t * t)
            self.scoreLabel.text = String(format: "%06d",tweenedScore)
        }
        
        self.run(scoreTweenAction)
    }
    
    func animateObstacles(jumpedObstacles : Int, totalObstacles : Int, duration : TimeInterval) {
        
        let obstacleTweenAction = SKAction.customAction(withDuration: duration){ (node, t) in
            let tweenedObstacles = Int(CGFloat(jumpedObstacles) * t * t)
            self.obstacleLabel.text =  String(format: "%03d",tweenedObstacles) + "/\(totalObstacles)"
        }
        
        self.run(obstacleTweenAction)
        
    }
    
    func animateRank(finalRank : Int, duration : TimeInterval) {
        
        let rankTweenAction = SKAction.customAction(withDuration: duration){ (node, t) in
            let tweenedRank = Int(CGFloat(finalRank) * t * t)
            self.obstacleLabel.text = "\(tweenedRank)%"
        }
        self.run(rankTweenAction)
    }
    
    func animateAllWithSound(score : Int, jumpedObstacles : Int, totalObstacles : Int, finalRank : Int, duration : TimeInterval){
        
        
        let soundActionSequence = SKAction.sequence([drumrollSoundAction, SKAction.wait(forDuration: duration), endSoundActions[finalRank / 34]])
        
        self.run(soundActionSequence)
        
        animateScore(score: score, duration: duration)
        animateObstacles(jumpedObstacles: jumpedObstacles, totalObstacles: totalObstacles, duration: duration)
        animateRank(finalRank: finalRank, duration: duration)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
