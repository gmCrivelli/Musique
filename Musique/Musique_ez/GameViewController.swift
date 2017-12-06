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
    func resetScene()
    func returnToSelection()
}

class GameViewController: UIViewController {
    
    var finalScore : String?
    
    var gameScene : PulsoGameScene!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.resetScene()

        if let view = self.view as! SKView? {
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
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

extension GameViewController: GameFinishedDelegate{
    
    func resetScene() {
        
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
        }
    }
    
    func returnToSelection() {
        self.navigationController?.popViewController(animated: true)
    }
}
