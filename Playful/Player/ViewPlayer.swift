//
//  ViewPlayer.swift
//  Playful
//
//  Created by Pfriedrix on 08.04.2024.
//

import Foundation
import ComposableArchitecture
import AVFoundation

@Reducer
struct ViewPlayer {
    enum ControlAction: Equatable {
        case load(with: URL)
        case play
        case pause
        case seek(to: CMTime)
        case next, prev
    }
    
    struct State: Equatable {
        var audiobook: AudioBook?
        var isLoading: Bool = false
        var episode: Int?
        
        var duration: CMTime = .zero
        
        var control: ControlAction?
        var player: Player.State = Player.State()
    }
    
    enum Action: Equatable {
        case start
        case section(Int)
        case backward(by: Double)
        case forward(by: Double)
        case seeker(to: CGFloat)
        case doneSeeking
        case audiobook(AudioBook?)
        
        case control(ControlAction)
        case player(Player.Action)
        
        case playerItem(AVPlayerItem?)
    }
    
    @Dependency(\.downloader) var downloader
    
    var body: some ReducerOf<ViewPlayer> {
        Scope(state: \.player, action: \.player) {
            Player()
        }
        Reduce { state, action in
            switch action {
            case .start:
                state.isLoading = true
                return .run { state in
                    let audiobook = try await downloader(.download("https://librivox.org/rss/5663"))
                    await state.callAsFunction(.audiobook(audiobook))
                }
            case let .backward(by: seconds):
                let time = max(state.player.currentTime - CMTime(seconds: seconds, preferredTimescale: 1), .zero)
                return .merge(
                    .send(.player(.currentTime(time))),
                    .send(.control(.seek(to: time)))
                )
            case let .forward(by: seconds):
                let time = min(state.player.currentTime + CMTime(seconds: seconds, preferredTimescale: 1), state.duration)
                return .merge(
                    .send(.player(.currentTime(time))),
                    .send(.control(.seek(to: time)))
                )
            case let .seeker(to: position):
                return .none
            case .doneSeeking:
                return .none
            case .control(let action):
                state.control = action
                switch action {
                case .next:
                    if let episode = state.episode, let audiobook = state.audiobook {
                        let episode = min(episode + 1, audiobook.episodes.count)
                        return .send(.section(episode))
                    }
                    return .none
                case .prev:
                    if let episode = state.episode {
                        let episode = max(episode - 1, .zero)
                        return .send(.section(episode))
                    }
                    return .none
                default: return .none
                }
            case let .audiobook(book):
                state.isLoading = false
                state.audiobook = book
                if let book = book, book.episodes.isEmpty {
                    // some ui information later
                    return .none
                } else {
                    return .send(.section(0))
                }
            case let .section(index):
                if let audiobook = state.audiobook {
                    let index = min(index, audiobook.episodes.count)
                    state.episode = index
                    let episode = audiobook.episodes[index]
                    return .send(.control(.load(with: episode.link)))
                }
                return .none
            case let .playerItem(item):
                if let item = item {
                    // some ui information later
                    state.duration = item.duration
                }
                return .none
            default: return .none
            }
        }
    }
}

extension ViewPlayer {
    static var `default`: StoreOf<ViewPlayer> {
        .init(initialState: ViewPlayer.State()) { ViewPlayer() }
    }
}
