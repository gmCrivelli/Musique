//  Sound.swift
//  tilemaptest
//
//  Created by Rafael Prado on 09/11/17.
//  Copyright © 2017 DoM7. All rights reserved.
//

import Foundation
import AVFoundation

/// ATTENTION: THIS CLASS IS FOR MUSIC ONLY.
/// FOR SOUND EFFECTS, USE SKACTIONS.

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

/// This class provides simple manipulation for audio objects using AVFoundation
class Sound: NSObject, AVAudioPlayerDelegate{
    
    // MARK: - Static Parameters (Audio Session)
    
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
    
    /// Object audio player
    private var player:AVAudioPlayer = AVAudioPlayer()
    
    /// Completion block to be executed after sound is finished playing
    private var completion : () -> Void = {}
    
    // MARK: - Methods
    
    /// Initializer for the Sound object
    ///
    /// - Parameters
    ///     - url: url containing the sound file path.
    init(url: URL){
        // NSObject init
        super.init()
        
        do {
            // Instantiates the player with the contents of the URL
            self.player = try AVAudioPlayer(contentsOf: url)
            // Sets the player delegate property to self
            self.player.delegate = self
        } catch let error {
            print("Initialization error: \(error)")
        }
    }
    
    /// Plays the corresponding sound
    func play(){
        self.player.prepareToPlay()
        self.player.play()
    }
    
    
    /// Plays sound corresponding to the audioplayer
    ///
    /// - Parameter completion: completion block to be executed when the song ends
    func play(_ completion: @escaping () -> Void){
        self.completion = completion
        
        self.player.prepareToPlay()
        self.player.play()
    }
    
    /// Stops playing the sound
    func stop(){
        self.player.stop()
        self.player.currentTime = 0.0
    }
    
    /// Pauses the song
    func pause(){
        self.player.pause()
    }
    
    // MARK: - Audioplayer Delegate methods
    
    ///  This Audioplayer delegate method is called when the player finishes playing
    ///
    /// - Parameters:
    ///   - player: player object that finished playing
    ///   - flag: indicates whether it ended successfuly
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.completion()
    }
}
