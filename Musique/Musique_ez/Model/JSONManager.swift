//
//  JSONManager.swift
//  Musique_ez
//
//  Created by Rafael Prado on 04/12/17.
//  Copyright © 2017 DoM7. All rights reserved.
//

import Foundation

class JSONManager{
    static func loadJson() -> [MusicPulse]{
         var response = [MusicPulse]()
        
        do{
            if let file = Bundle.main.url(forResource: "pulse", withExtension: "json"){
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                
                if let songs = json as? [[String:Any]]{
                    for song in songs{
                        let music = MusicPulse()
                        
                        music.name = song["name"] as! String
                        music.fileName = song["fileName"] as! String
                        music.fileExtension = song["fileExtension"] as! String
                        music.id = song["id"] as! Int16
                        music.bpm = song["bpm"] as! Double
                        music.highScore = song["highScore"] as! Int16
                        music.lastScore = song["lastScore"] as! Int16
                        
                        response.append(music)
                    }
                }
            }else{
                print("Invalid Filepath")
            }
        }catch{
            print(error.localizedDescription)
        }
        return response
    }
}
