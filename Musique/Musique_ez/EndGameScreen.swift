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
    private var EndGameBox : SKSpriteNode!
    
    private var scoreLabel : SKLabelNode!
    private var obstacleLabel : SKLabelNode!
    private var rankLabel : SKLabelNode!
    
    init(scene: SKScene) {
        
        super.init()
        
        self.darkenerRectangle = SKShapeNode(rectOf: scene.size)
        self.darkenerRectangle.fillColor = .black
        self.darkenerRectangle.alpha = 0
        
        let box = self.childNode(withName: "box")
        
        self.scoreLabel = box?.childNode(withName: "scoreLabel") as! SKLabelNode
        self.obstacleLabel = box?.childNode(withName: "scoreLabel") as! SKLabelNode
        self.rankLabel = box?.childNode(withName: "scoreLabel") as! SKLabelNode
    }
    
    func animateScore(score: Int, duration : TimeInterval) {
        
        let scoreTweenAction = SKAction.customAction(withDuration: duration){ (node, t) in
            let tweenedScore = Int(CGFloat(score) * t * t)
            self.scoreLabel.text = String(format: "%06d",tweenedScore)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
