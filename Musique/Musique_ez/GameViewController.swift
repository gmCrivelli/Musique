//
//  GameViewController.swift
//  Musique_ez
//
//  Created by Gustavo De Mello Crivelli on 09/11/17.
//  Copyright © 2017 Gustavo De Mello Crivelli. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

protocol GameFinishedDelegate {
    func performEndGameFunctions(score: Float)
}

class GameViewController: UIViewController, GameFinishedDelegate {
    func performEndGameFunctions(score: Float) {
        performSegue(withIdentifier: "endGameSegue", sender: self)
    }
    
    var gameScene : PulsoGameScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'PulsoGameScene.sks'
            if let scene = SKScene(fileNamed: "PulsoGameScene") {
                
                self.gameScene = scene as! PulsoGameScene
                
                // Configure delegate
                self.gameScene.viewControllerDelegate = self
                
                // Set the scale mode to scale to fit the window
                gameScene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(gameScene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        gameScene.jump()
    }
    
//    @IBAction func handleTap(_ sender: Any) {
//        gameScene.jump()
//    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.landscapeLeft, .landscapeRight]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
