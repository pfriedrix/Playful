//
//  AudioPlayer.swift
//  Playful
//
//  Created by Pfriedrix on 10.04.2024.
//

import AVFoundation
import Dependencies
import DependenciesMacros
import MediaPlayer

protocol AudioPlayer {
    func replaceCurrentItem(with item: AVPlayerItem?)
    func playImmediately(atRate rate: Float)
    func pause()
    func seek(to time: CMTime) async -> Bool
    func addPeriodicTimeObserver(forInterval interval: CMTime, queue: dispatch_queue_t?, using block: @escaping @Sendable (CMTime) -> Void) -> Any
    func removeTimeObserver(_ timeObserver: Any)
}

struct LiveAudioPlayer: AudioPlayer {
    private let player = AVPlayer()
    private let session = AVAudioSession()
    
    init() {
        try? session.setCategory(.playback, options: [.mixWithOthers, .allowBluetooth, .allowAirPlay])
    }
    
    func replaceCurrentItem(with item: AVPlayerItem?) {
        try? session.setActive(true)
        player.replaceCurrentItem(with: item)
    }
    
    func playImmediately(atRate rate: Float) {
        player.playImmediately(atRate: rate)
    }
    
    func pause() {
        player.pause()
    }
    
    func seek(to time: CMTime) async -> Bool {
        await player.seek(to: time)
    }
    
    func addPeriodicTimeObserver(forInterval interval: CMTime, queue: dispatch_queue_t?, using block: @escaping @Sendable (CMTime) -> Void) -> Any {
        player.addPeriodicTimeObserver(forInterval: interval, queue: queue, using: block)
    }
    
    func removeTimeObserver(_ timeObserver: Any) {
        player.removeTimeObserver(timeObserver)
    }
}

private enum AudioPlayerKey: DependencyKey {
    static let liveValue: any AudioPlayer = LiveAudioPlayer()
}

extension DependencyValues {
    var player: AudioPlayer {
        get { self[AudioPlayerKey.self] }
        set { self[AudioPlayerKey.self] = newValue }
    }
}
