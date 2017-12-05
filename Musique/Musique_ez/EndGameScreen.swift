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
    
    init(scene: SKScene) {
        
        super.init()
        
        self.darkenerRectangle = SKShapeNode(rectOf: scene.size)
        self.darkenerRectangle.fillColor = .black
        self.darkenerRectangle.alpha = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
