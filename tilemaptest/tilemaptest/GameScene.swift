//
//  GameScene.swift
//  tilemaptest
//
//  Created by Rafael Prado on 08/11/17.
//  Copyright © 2017 DoM7. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var muffinMan:Sound?
    
    // Ground node and its initial position
    private var groundNode1: SKTileMapNode?
    private var originalPosition:CGPoint?
    
    // Ground movement parameters
    private let groundOffset = 150.0
    private var lastUpdateTime:Double = 0.0
    
    // Node that will parent all obstacles
    private var obstaclesParent : SKNode?
    
    // Timer used to display obstacles
    var timer:Timer?
    let thread = DispatchQueue(label: "Timer", qos: .background, attributes: .concurrent)
    
    override func didMove(to view: SKView) {
        // Initializes the ground
        self.groundNode1 = childNode(withName: "Ground1") as? SKTileMapNode
        originalPosition = groundNode1?.position
        
        // Initializes the parent node for all obstacles
        self.obstaclesParent = childNode(withName: "Obstacles")
        
        // Creates an asynchronous operation so the timer will run without interfering on the UI
        thread.async { [unowned self] in
            // In case the scene disappears, invalidates the timer
            if let _ = self.timer{
                self.timer?.invalidate()
                self.timer = nil
            }
            
            // Holds the running loop that will handle the timer event
            let mainLoop = RunLoop.current
            // Initializes the timer
            self.timer = Timer(timeInterval: 1, target: self, selector: #selector (self.addObstacle), userInfo: nil, repeats: true)
            // Adds the timer to the running loop
            mainLoop.add(self.timer!, forMode: .commonModes)
            // Starts the operation
            mainLoop.run()
            // Fires the timer
            self.timer?.fire()
        }
        
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "The_Muffin_Man", ofType: "mp3")!)
        muffinMan = Sound(url: url)
        
        muffinMan?.play{
            self.timer?.invalidate()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Updates the time control parameters
        if lastUpdateTime == 0{
            lastUpdateTime = currentTime
            return
        }
        // Finds out how much time has passed since last update
        let elapsedTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        // Updates the pixel offset
        let actualOffset = CGFloat(groundOffset * elapsedTime)
        
        // Updates the ground position to loop endlessly
        groundNode1?.position = CGPoint(x: (groundNode1?.position.x)! - actualOffset, y: (groundNode1?.position.y)!)
        // In case the ground has reached a limit distance, returns it to the initial position
        if((groundNode1?.position.x)! < -(groundNode1?.frame.width)!/2){
            groundNode1?.position = originalPosition!
        }
        
        // Obstacle Manipulation
        // If there are any obstacles attached to the parent
        if let obstaculos = obstaclesParent?.children{
            // For each obstacle
            for obs in obstaculos{
                // Updates the obstacle position at the same rate as the ground
                obs.position = CGPoint(x: obs.position.x - actualOffset, y: obs.position.y)
                // In case the obstacle has reached the outside of the screen
                if(obs.position.x < 2*(self.groundNode1?.frame.minX)! - obs.frame.width){
                    // Removes the object from the parent node to avoid excessive memory use
                    obs.removeFromParent()
                }
            }
        }
    }
    
    /// Selector to be called everytime the timer fires
    @objc func addObstacle() -> Void{
        // Adds a new obstacle to the parent node
        self.obstaclesParent?.addChild(ObstacleNode())
    }
    
    
}
