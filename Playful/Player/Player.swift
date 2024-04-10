//
//  Player.swift
//  Playful
//
//  Created by Pfriedrix on 09.04.2024.
//

import ComposableArchitecture
import AVFoundation

@Reducer
struct Player {
    static let ID = UUID()
    
    struct State: Equatable {
        var timeControlStatus: AVPlayer.TimeControlStatus = .paused
        var currentTime: CMTime = .zero
        var duration: CMTime = .zero
        var rate: PlaybackSpeed = .normal
        var isLoading = false
        
        let player = AVPlayer()
    }
    
    enum Action: Equatable {
        case load(with: URL)
        case play
        case pause
        case seek(to: CMTime)
        case duration(CMTime)
        case rate(PlaybackSpeed)
        case loaded
        case currentTime(CMTime)
        case cancelTimer
        case startTimer
        case fail
    }

    @Dependency(\.continuousClock) var clock
    let session = AVAudioSession.sharedInstance()
    
    init() {
        try? session.setCategory(.playback, options: [.mixWithOthers, .allowBluetooth, .allowAirPlay])
    }
    
    var body: some ReducerOf<Player> {
        Reduce { state, action in
            switch action {
            case .fail:
                return .send(.loaded)
            case let .load(with: url):
                state.isLoading = true
                state.currentTime = .zero
                let asset = AVAsset(url: url)
                let item = AVPlayerItem(asset: asset)
                state.player.replaceCurrentItem(with: item)
                return .run { sender in
                    do {
                        let duration = try await asset.load(.duration)
                        await sender.callAsFunction(.duration(duration))
                    } catch {
                        await sender(.fail)
                    }
                }
            case .play:
                state.timeControlStatus = .playing
                state.player.playImmediately(atRate: Float(state.rate.rawValue))
                return .send(.startTimer)
            case .pause:
                state.timeControlStatus = .paused
                state.player.pause()
                return .send(.cancelTimer)
            case let .seek(to: time):
                let time = CMTimeMake(
                    value: Int64(max(0, min(time.value, state.duration.value))),
                    timescale: 1
                )
                state.currentTime = time
                let player = state.player
                return .merge(
                    .run { send in
                        _ = await player.seek(to: time)
                        await send(.startTimer)
                    }
                )
            case let .duration(time):
                state.duration = time
                return .send(.loaded)
            case .loaded:
                state.isLoading = false
                return .none
            case let .rate(rate):
                state.rate = rate
                if state.timeControlStatus == .playing {
                    state.player.playImmediately(atRate: Float(rate.rawValue))
                }
                return .none
            case let .currentTime(time):
                state.currentTime = time.convertScale(1, method: .default)
                return .none
            case .startTimer:
                let player = state.player
                
                let timeUpdates = AsyncStream<CMTime> { continuation in
                    let timeObserver = player.addPeriodicTimeObserver(forInterval: .init(value: 1, timescale: 1), queue: .main) { time in
                        continuation.yield(time)
                    }
                    
                    continuation.onTermination = { @Sendable  _ in
                        player.removeTimeObserver(timeObserver)
                    }
                }

                return .run { send in
                    for await time in timeUpdates {
                        await send(.currentTime(time))
                    }
                }.cancellable(id: Player.ID, cancelInFlight: true)
            case .cancelTimer: return .cancel(id: Player.ID)
            }
        }
    }
}


