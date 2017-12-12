//
//  AppDelegate.swift
//  Musique
//
//  Created by Gustavo De Mello Crivelli on 12/12/17.
//  Copyright © 2017 DoM7. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if(!UserDefaults().bool(forKey: "databaseLoaded")){
            let songs = JSONManager.loadJson()
            
            for i in songs{
                MusicServices.createMusic(music: i, { (error) in
                    UserDefaults().set(true, forKey: "databaseLoaded")
                })
            }
        }
        
        return true
    }
}

