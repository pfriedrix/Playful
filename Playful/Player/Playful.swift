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
struct Playful {
    
    enum PlayfulError: Error, Equatable {
        case failedAudiobook, failedAudio
    }
    
    enum Tab: String, Equatable, CaseIterable {
        case episodes, player
        
        var icon: String {
            switch self {
            case .episodes: "text.alignleft"
            case .player: "headphones"
            }
        }
    }
    
    enum AlertAction: Equatable {
        case hide
    }
    
    struct State: Equatable {
        var tab: Tab = .player
        
        var audiobook: AudioBook?
        var isLoading: Bool = false
        var episode: Int?
        
        var alert: AlertState<AlertAction>?
        var cover: Data = Data()
        
        var player: Player.State = .init()
    }
    
    enum Action: Equatable {
        case start
        case section(Int)
        case backward(by: Double)
        case forward(by: Double)
        case seeker(Double)
        case doneSeeking
        case audiobook(AudioBook?)
        case next, previous
        case loadCover(Data)
        
        case loaded
        case failed(PlayfulError)
        case alert(AlertAction)
        
        case player(Player.Action)
        case tab(Tab)
    }
    
    @Dependency(\.downloader) var downloader
    @Dependency(\.haptic) var haptic
    
    var body: some ReducerOf<Playful> {
        Scope(state: \.player, action: \.player) {
            Player()
        }
        Reduce { state, action in
            switch action {
            case let .alert(action):
                switch action {
                case .hide:
                    state.alert = nil
                    return .run { _ in
                        await haptic(.light)
                    }
                }
            case .loaded:
                state.isLoading = false
                return .none
            case let .failed(error):
                switch error {
                case .failedAudiobook:
                    state.alert = AlertState(title: .init("FAIL"), message: .init("Упс, не зміг скачати книгу"))
                case .failedAudio:
                    state.alert = AlertState(title: .init("FAIL"), message: .init("Чомусь не грає"))
                }
                return .send(.loaded)
            case let .tab(tab):
                state.tab = tab
                return .run { _ in
                    await haptic(.light)
                }
            case .start:
                state.isLoading = true
                return .run { state in
                    do {
                        let audiobookData = try await downloader(.download())
                        let audiobook = AudioBookParser().parse(data: audiobookData)
                        await state.callAsFunction(.audiobook(audiobook))
                        
                        let coverData = try await downloader(.download(audiobook?.coverArtURL?.absoluteString ?? ""))
                        await state(.loadCover(coverData))
                    } catch {
                        await state(.failed(PlayfulError.failedAudiobook))
                    }
                }
            case let .audiobook(book):
                state.audiobook = book
                if let book = book, book.episodes.isEmpty {
                    return .send(.loaded)
                } else {
                    return .merge(
                        .send(.loaded),
                        .send(.section(0))
                    )
                }
            case let .loadCover(data):
                state.cover = data
                return .none
            case let .backward(by: seconds):
                let time = max(state.player.currentTime - CMTime(seconds: seconds, preferredTimescale: 1), .zero)
                return .merge(
                    .send(.player(.seek(to: time))),
                    .run { _ in
                        await haptic(.light)
                    }
                )
            case let .forward(by: seconds):
                let time = min(state.player.currentTime + CMTime(seconds: seconds, preferredTimescale: 1), state.player.duration)
                return .merge(
                    .send(.player(.seek(to: time))),
                    .run { _ in
                        await haptic(.light)
                    }
                )
            case let .seeker(seconds):
                let time = CMTimeMake(
                    value: Int64(max(0, min(seconds, state.player.duration.seconds))),
                    timescale: 1
                )
                state.player.currentTime = time
                return .merge(
                    .send(.player(.cancelTimer)),
                    .run { _ in
                        await haptic(.soft)
                    }
                )
            case .doneSeeking:
                let time = state.player.currentTime
                return .merge(
                    .send(.player(.seek(to: time))),
                    .run { _ in
                        await haptic(.medium)
                    }
                )
            case .next:
                if let episode = state.episode {
                    return .merge(
                        .send(.section(episode + 1)),
                        .run { _ in
                            await haptic(.light)
                        }
                    )
                }
                return .run { _ in
                    await haptic(.light)
                }
            case .previous:
                if let episode = state.episode {
                    return .merge(
                        .send(.section(episode - 1)),
                        .run { _ in
                            await haptic(.light)
                        }
                    )
                }
                return .run { _ in
                    await haptic(.soft)
                }
            case let .section(index):
                if let audiobook = state.audiobook, 0...audiobook.episodes.count ~= index {
                    state.episode = index
                    let episode = audiobook.episodes[index]
                    return .merge(
                        .send(.player(.pause)),
                        .send(.player(.load(with: episode.link))),
                        .send(.player(.play))
                    )
                }
                return .none
            case .player(.currentTime):
                guard state.player.duration.seconds > 0 else { return .none }
                if state.player.currentTime.seconds.rounded() >= state.player.duration.seconds.rounded() {
                    return .send(.next)
                }
                return .none
            case .player(.fail):
                return .send(.failed(PlayfulError.failedAudio))
            case .player(.play):
                return .run { _ in
                    await haptic(.light)
                }
            case .player(.pause):
                return .run { _ in
                    await haptic(.light)
                }
            case .player(.rate(_)):
                return .run { _ in
                    await haptic(.light)
                }
            case .player(_): return .none
            }
            
        }
    }
}

extension Playful {
    static var `default`: StoreOf<Playful> {
        .init(initialState: Playful.State()) { Playful() }
    }
}
