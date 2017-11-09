//
//  GameScene.swift
//  FreestylePrototype
//
//  Created by Rafael Prado on 25/10/17.
//  Copyright © 2017 DoM7. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    private var controlNode : SKSpriteNode?
    private var backgroundNode: SKNode?
    
    //    Background dimensions:
    private let numberOfColumns : CGFloat = 10.0
    
    private var selectedNode : SKNode = SKNode()
    
    override func didMove(to view: SKView) {
        
        self.controlNode = self.childNode(withName: "controlNode") as? SKSpriteNode
        self.backgroundNode = self.childNode(withName: "backgroundNode") as? SKSpriteNode
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        
    }
    
    func selectNodeForTouch(touchLocation: CGPoint) {
        // 1
        let touchedNode = self.atPoint(touchLocation)
        
        if touchedNode is SKSpriteNode {
            // 2
            if !selectedNode.isEqual(touchedNode) {
                self.selectedNode.removeAllActions()
                self.selectedNode = touchedNode as! SKNode
            }
        }
    }
    
    func panForTranslation(translation: CGPoint) {
        let position = self.selectedNode.position
        selectedNode.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches {
            let positionInScene = t.location(in: self)
            selectNodeForTouch(touchLocation: positionInScene)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let positionInScene = t.location(in: self)
            let previousPosition = t.previousLocation(in:self)
            let translation = CGPoint(x: positionInScene.x - previousPosition.x, y: positionInScene.y - previousPosition.y)
            
            panForTranslation(translation: translation)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let columnWidth : CGFloat = (backgroundNode?.frame.width)! / numberOfColumns
            let columnWithDecimals = Double(selectedNode.frame.midX / columnWidth)
            print(columnWithDecimals)
            
            var column:Double = round(columnWithDecimals)
            var multiplier = 0.5
            if column > columnWithDecimals {
                multiplier = -0.5
            }
            column += multiplier
            
            let center = CGPoint(x: column * Double(columnWidth), y: 0)
            let movementAction = SKAction.move(to: center, duration: 0.3)
            self.selectedNode.run(movementAction)
        }
    }
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
