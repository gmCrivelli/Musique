//
//  AppDelegate.swift
//  Musique_ez
//
//  Created by Gustavo De Mello Crivelli on 09/11/17.
//  Copyright © 2017 Gustavo De Mello Crivelli. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let music = MusicPulse()
        music.highestscore = Int16(0)
        music.name = "7th element" 
        
        MusicServices.createMusic(music: music, { error in
            if error != nil{
                print(String(describing:error))
            }
        })
        
        return true
    }
}

