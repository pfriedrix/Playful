//
//  ViewPlayer.swift
//  Playful
//
//  Created by Pfriedrix on 08.04.2024.
//

import Foundation
import ComposableArchitecture
import AVFoundation

struct ViewPlayer: Reducer {
    enum ControlAction: Equatable {
        case load(with: URL)
        case play
        case pause
        case seek(to: CMTime)
    }
    
    struct State: Equatable {
        var audiobook: AudioBook?
        var isLoading: Bool = false
        var episode: Int?
        
        var control: ControlAction?
    }
    
    enum Action {
        case start
        case section(Int)
        case backward(by: Int)
        case forward(by: Int)
        case seeker(to: CGFloat)
        case doneSeeking
        case audiobook(AudioBook?)
        
        case control(ControlAction)
    }
    
    @Dependency(\.downloader) var downloader
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .start:
            state.isLoading = true
            return .run { state in
                let audiobook = try await downloader(.download("https://librivox.org/rss/5663"))
                await state.callAsFunction(.audiobook(audiobook))
            }
        case let .backward(by: seconds):
            return .none
        case let .forward(by: seconds):
            return .none
        case let .seeker(to: position):
            return .none
        case .doneSeeking:
            return .none
        case .control(let action):
            state.control = action
            return .none
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
            state.episode = index
            if let audiobook = state.audiobook, audiobook.episodes.count > index {
                let episode = audiobook.episodes[index]
                return .send(.control(.load(with: episode.link)))
            }
            return .none
        }
    }
}

extension ViewPlayer {
    static var `default`: StoreOf<ViewPlayer> {
        .init(initialState: ViewPlayer.State()) { ViewPlayer() }
    }
}
