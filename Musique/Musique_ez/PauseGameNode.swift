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

class PauseGameNode : SKNode {
    
    // MARK: Properties
    
    // Child nodes
    private var darkenerRectangle : SKShapeNode?
    private var box : SKNode!
    public var restartButton : SKSpriteNode!
    public var continueButton : SKSpriteNode!
    public var menuButton : SKSpriteNode!
    
    // Action for movement
    private var moveBoxAction : SKAction!
    
    func setup(rectOf size: CGSize) {
        // Setup child nodes
        self.box = self.childNode(withName: "box")
        
        self.restartButton = box?.childNode(withName: "restartButton") as! SKSpriteNode
        self.continueButton = box?.childNode(withName: "continueButton") as! SKSpriteNode
        self.menuButton = box?.childNode(withName: "menuButton") as! SKSpriteNode
        
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
            self?.darkenerRectangle!.alpha = 0.7 * adjustedTime
        })
    }
    
    func hideBox() {
        self.box.position = CGPoint(x: 0, y: -4000)
    }
}

