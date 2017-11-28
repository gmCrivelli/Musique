//
//  ScenarioObjectNode.swift
//  Musique_ez
//
//  Created by Rafael Prado on 14/11/17.
//  Copyright © 2017 Gustavo De Mello Crivelli. All rights reserved.
//


import SpriteKit
import GameplayKit

class ScenarioObjectNode: SKSpriteNode {
    private var isGroundObject : Bool!
    private var layer : Int!
    
    init(isGroundObject: Bool, layer: Int, texture: SKTexture){
        super.init(texture: nil, color: .red, size: CGSize(width: texture.size().width / 7, height: texture.size().height / 7))
        self.isGroundObject = isGroundObject
        self.layer = layer
        self.physicsBody?.affectedByGravity = false
        self.texture = texture
        self.zPosition = -6

        if(!isGroundObject){
            self.position.y = self.position.y + CGFloat(arc4random_uniform(80)) - 40
            self.zPosition = -9
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
}

