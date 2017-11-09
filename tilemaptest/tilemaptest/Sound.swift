//
//  Sound.swift
//  tilemaptest
//
//  Created by Rafael Prado on 09/11/17.
//  Copyright © 2017 DoM7. All rights reserved.
//

import Foundation
import AVFoundation

/// Holds all possibilities for AVAudioSession types. Also provides a method for easily getting it.
public enum SoundCategory {
    
    /// Equivalent of AVAudioSessionCategoryAmbient.
    case ambient
    /// Equivalent of AVAudioSessionCategorySoloAmbient.
    case soloAmbient
    /// Equivalent of AVAudioSessionCategoryPlayback.
    case playback
    /// Equivalent of AVAudioSessionCategoryRecord.
    case record
    /// Equivalent of AVAudioSessionCategoryPlayAndRecord.
    case playAndRecord
    
    fileprivate var avFoundationCategory: String {
        get {
            switch self {
            case .ambient:
                return AVAudioSessionCategoryAmbient
            case .soloAmbient:
                return AVAudioSessionCategorySoloAmbient
            case .playback:
                return AVAudioSessionCategoryPlayback
            case .record:
                return AVAudioSessionCategoryRecord
            case .playAndRecord:
                return AVAudioSessionCategoryPlayAndRecord
            }
        }
    }
}


class Sound{
    
    // MARK: - Static Parameters
    
    /// Holds every audio player instanced
    static var audioPlayers = [AVAudioPlayer]()
    
    /// Holds the audio session for playing the audio
    static var session = AVAudioSession.sharedInstance()
    
    /// Sets the category foir the audio session above
    static var category: SoundCategory = {
        let defaultCategory = SoundCategory.playback
        try? session.setCategory(defaultCategory.avFoundationCategory)
        return defaultCategory
    }() {
        didSet {
            try? session.setCategory(category.avFoundationCategory)
        }
    }
    
    // MARK: - Sound Instance Parameters
    
    /// Index of the player on the audioPlayer array
    var index: Int?
    
    // MARK: - Methods
    
    /// Initializer for the Sound object
    ///
    /// - Parameter url: url containing the sound file path.
    init(url: URL){
        do{
            // Instantiates the player with the contents of the URL
            let player = try AVAudioPlayer(contentsOf: url)
            // Appends it to the array
            Sound.audioPlayers.append(player)
            
            // Sets the object player index on the array
            self.index = Sound.audioPlayers.count-1
            
        }catch let error {
            print("Initialization error: \(error)")
        }
    }
    
    
    /// Plays the corresponding sound
    func play(){
        let player = Sound.audioPlayers[self.index!]
        player.prepareToPlay()
        player.play()
    }
    
    /// Stops playing the sound
    func stop(){
        let player = Sound.audioPlayers[self.index!]
        player.stop()
    }
}









