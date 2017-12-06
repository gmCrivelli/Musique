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

class EndGameNode : SKNode {
    
    // MARK: Properties
    
    // Child nodes
    private var darkenerRectangle : SKShapeNode?
    private var box : SKSpriteNode!
    public var restartButton : SKSpriteNode!
    public var homeButton : SKSpriteNode!
    
    private var scoreLabel : SKLabelNode!
    private var obstacleLabel : SKLabelNode!
    private var rankLabel : SKLabelNode!
    
    // Sound actions
    private var drumrollSoundAction : SKAction!
    private var endSoundActions : [SKAction] = []
    
    // Action for movement
    private var moveBoxAction : SKAction!
    
    func setup(rectOf size: CGSize) {
        // Setup child nodes
        self.box = self.childNode(withName: "box") as! SKSpriteNode
        
        self.scoreLabel = box?.childNode(withName: "scoreLabel") as! SKLabelNode
        self.obstacleLabel = box?.childNode(withName: "obstacleLabel") as! SKLabelNode
        self.rankLabel = box?.childNode(withName: "rankLabel") as! SKLabelNode
        
        self.restartButton = box?.childNode(withName: "restartButton") as! SKSpriteNode
        self.homeButton = box?.childNode(withName: "homeButton") as! SKSpriteNode
        
        // Setup sound actions
        self.drumrollSoundAction = SKAction.playSoundFileNamed("drum_roll.wav", waitForCompletion: false)
        
        let goodSoundAction = SKAction.playSoundFileNamed("good_end.wav", waitForCompletion: false)
        let midSoundAction = SKAction.playSoundFileNamed("mid_end.wav", waitForCompletion: false)
        let badSoundAction = SKAction.playSoundFileNamed("bad_end.wav", waitForCompletion: false)
        self.endSoundActions = [badSoundAction, midSoundAction, goodSoundAction]
        
        // Darkener for the rest of the screen
        if let darkRect = self.darkenerRectangle {
            darkRect.alpha = 0
        }
        else {
            self.darkenerRectangle = SKShapeNode(rectOf: size)
            self.darkenerRectangle!.fillColor = .black
            self.darkenerRectangle!.alpha = 0
            self.darkenerRectangle!.zPosition = -1
            self.addChild(darkenerRectangle!)
        }
    
        self.position = CGPoint(x: size.width / 2, y: size.height / 2)
        self.zPosition = 100
        self.box.position = CGPoint(x: 0, y: 4000)
        
        moveBoxAction = SKAction.move(to: CGPoint.zero, duration: 5)
    }
    
    // MARK: Show box on screen
    func displayBox(duration: TimeInterval) {
        
        self.parent?.run(SKAction.customAction(withDuration: duration) {
            [weak self] (node, t) in
            let adjustedTime = (t / CGFloat(duration)) * (t / CGFloat(duration))
            
            self?.box.position = CGPoint(x: 0, y: -4000 * (1 - adjustedTime))
            self?.darkenerRectangle!.alpha = 0.5 * adjustedTime
        })
    }

    // MARK: Value tweening Actions
    func animateScore(score: Int, duration : TimeInterval) {
        
        let scoreTweenAction = SKAction.customAction(withDuration: duration){ [weak self] (node, t) in
            
            let adjustedTime = t / CGFloat(duration)
            let tweenedScore = Int(CGFloat(score) * adjustedTime * adjustedTime)
            self?.scoreLabel.text = String(format: "%06d",tweenedScore)
        }
        
        self.parent?.run(scoreTweenAction)
    }
    
    func animateObstacles(jumpedObstacles : Int, totalObstacles : Int, duration : TimeInterval) {
        
        let obstacleTweenAction = SKAction.customAction(withDuration: duration){ [weak self] (node, t) in
            let adjustedTime = t / CGFloat(duration)
            let tweenedObstacles = Int(CGFloat(jumpedObstacles) * adjustedTime * adjustedTime)
            self?.obstacleLabel.text =  String(format: "%03d",tweenedObstacles) + "/\(totalObstacles)"
        }
        
        self.parent?.run(obstacleTweenAction)
        
    }
    
    func animateRank(finalRank : Int, duration : TimeInterval) {
        
        let rankTweenAction = SKAction.customAction(withDuration: duration){ [weak self] (node, t) in
            let adjustedTime = t / CGFloat(duration)
            let tweenedRank = Int(CGFloat(finalRank) * adjustedTime)
            self?.rankLabel.text = "\(tweenedRank)%"
        }
        self.parent?.run(rankTweenAction)
    }
    
    func animateAllWithSound(score : Int, jumpedObstacles : Int, totalObstacles : Int, finalRank : Int, duration : TimeInterval){
        
        let soundActionSequence = SKAction.sequence([drumrollSoundAction, SKAction.wait(forDuration: duration), endSoundActions[finalRank / 34]])
        
        self.parent?.run(soundActionSequence)
        
        animateScore(score: score, duration: duration)
        animateObstacles(jumpedObstacles: jumpedObstacles, totalObstacles: totalObstacles, duration: duration)
        animateRank(finalRank: finalRank, duration: duration)
    }
}
