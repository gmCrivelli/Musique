//
//  PatternInstantiator.swift
//  Musique
//
//  Created by Gustavo De Mello Crivelli on 09/11/17.
//  Copyright © 2017 Gustavo De Mello Crivelli. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class PatternCannon {
    var baseLocation : CGPoint!
    var cannonStep : CGPoint!
    var numberOfTargets : Int!
    var targetScale : CGFloat!
    var targetTypeArray : [ObstacleType] = [ObstacleType.fence]
    var baseTargetSpeed : float2!
    var baseTargetAccel : float2!
    var timeDelayArray : [TimeInterval] = [0.0]
    
    var randomizingRange : CGPoint!
    var maxSpeed : Float = 300
    var maxAccel : Float = 100
    
    let entityManager : EntityManager
    
    var timer : Timer!
    var launchedCounter : Int = 0
    
    var sequence : [SKAction]!
    
    init(baseLocation : CGPoint, cannonStep: CGPoint, numberOfTargets : Int, targetScale : CGFloat, obstacleTypeArray: [ObstacleType], baseTargetSpeed : float2, baseTargetAccel : float2, timeDelayArray : [TimeInterval], entityManager : EntityManager) {
        
        self.baseLocation = baseLocation
        self.cannonStep = cannonStep
        self.numberOfObstacles = numberOfObstacles
        self.targetScale = targetScale
        self.targetTypeArray = targetTypeArray
        self.baseTargetSpeed = baseTargetSpeed
        self.baseTargetAccel = baseTargetAccel
        self.timeDelayArray = timeDelayArray
        self.entityManager = entityManager
        
        var i = 0
        sequence = []
        while i < numberOfObstacles {
            
            sequence.append(SKAction.run {
                self.launchTarget() } )
            
            if self.timeDelayArray[self.launchedCounter % self.timeDelayArray.count] > 0 {
                sequence.append(SKAction.wait(forDuration: (self.timeDelayArray[self.launchedCounter % self.timeDelayArray.count])))
                
                i += 1
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func launchTarget() {
        
        //        while(true) {
        //            if launchedCounter >= numberOfTargets {
        //                timer.invalidate()
        //                return
        //            }
        
        let t1 = entityManager.spawnTarget(targetType: targetTypeArray[launchedCounter % targetTypeArray.count],
                                           location: baseLocation,
                                           scale: targetScale,
                                           initialVelocity: baseTargetSpeed,
                                           initialAccel: baseTargetAccel,
                                           maxSpeed: baseTargetSpeed.x,
                                           maxAccel: maxAccel,
                                           moveType: MoveType.gravity,
                                           path: nil,
                                           returnEntity: true)
        
        if targetTypeArray[launchedCounter % targetTypeArray.count] == .stickLeft {
            let t2 = entityManager.spawnTarget(targetType: .duckLeft,
                                               location: CGPoint(x: baseLocation.x, y: baseLocation.y + 100),
                                               scale: targetScale,
                                               initialVelocity: baseTargetSpeed,
                                               initialAccel: baseTargetAccel,
                                               maxSpeed: baseTargetSpeed.x,
                                               maxAccel: maxAccel,
                                               moveType: MoveType.gravity,
                                               path: nil,
                                               returnEntity: true)
            
            t1.relatedEntity = t2
            t2.relatedEntity = t1
        }
        
        if targetTypeArray[launchedCounter % targetTypeArray.count] == .stickRight {
            let t2 = entityManager.spawnTarget(targetType: .duckRight,
                                               location: CGPoint(x: baseLocation.x, y: baseLocation.y + 100),
                                               scale: targetScale,
                                               initialVelocity: baseTargetSpeed,
                                               initialAccel: baseTargetAccel,
                                               maxSpeed: maxSpeed,
                                               maxAccel: maxAccel,
                                               moveType: MoveType.gravity,
                                               path: nil,
                                               returnEntity: true)
            
            t1.relatedEntity = t2
            t2.relatedEntity = t1
        }
        
        self.baseLocation = self.baseLocation + self.cannonStep
        self.launchedCounter += 1
        
        //            if timeDelayArray[launchedCounter % timeDelayArray.count] != 0.0 { break }
        //        }
        
        //        if timeDelayArray.count > 0 {
        //            timer.invalidate()
        ////            timer = Timer.scheduledTimer(timeInterval: timeDelayArray[launchedCounter % timeDelayArray.count], target: self,
        ////                                         selector: #selector(self.launchTarget), userInfo: nil, repeats: false)
        //        }
    }
}

class PatternInstantiator {
    
    let entityManager : EntityManager
    var patternArray = [(TimeInterval, PatternCannon)]()
    
    var bpm : Int!
    var beatTime : Double
    
    init(bpm: Int, entityManager: EntityManager) {
        self.entityManager = entityManager
        self.bpm = bpm
        self.beatTime = 1.0 / Double(bpm)

        setupArray()
    }
    
    func setupArray() {
        patternArray.append((0.0,
                             PatternCannon(baseLocation: CGPoint(x: 0, y: 0),
                                           cannonStep: CGPoint(x: 0, y: 0),
                                           numberOfTargets: 100,
                                           obstacleScale: 3.7,
                                           obstacleTypeArray: [ObstacleType.fence],
                                           baseTargetSpeed: float2(x: 10, y: 0),
                                           baseTargetAccel: float2(x: 0, y: 0),
                                           timeDelayArray: [0.6],
                                           entityManager: entityManager)))
}









