//
//  SpriteComponent.swift
//  choraGabe
//
//  Created by Gustavo De Mello Crivelli on 06/07/17.
//  Copyright © 2017 Gustavo De Mello Crivelli. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class SpriteComponent: GKComponent {
    
    let node: SKShapeNode
    
    init(imageNamed: String, location: CGPoint) {
        
        let texture = SKTexture(imageNamed: imageNamed)
        var shapeNode: SKShapeNode = SKShapeNode(rectOf: texture.size())

        shapeNode.fillTexture = texture
        shapeNode.fillColor = SKColor.white
        shapeNode.strokeColor = .clear
        shapeNode.position = location
        self.node = shapeNode
        
        let width = texture.size().width
        let height = texture.size().height
        
        super.init()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

