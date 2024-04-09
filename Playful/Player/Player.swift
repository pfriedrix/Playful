//
//  Player.swift
//  Playful
//
//  Created by Pfriedrix on 08.04.2024.
//

import AVFoundation
import ComposableArchitecture

@Reducer
struct Player {
    struct State: Equatable {
        var status: AVPlayer.Status = .unknown
        var timeControlStatus: AVPlayer.TimeControlStatus = .paused
        var reasonWaitingToPlay: AVPlayer.WaitingReason?
        var currentTime: CMTime = .zero
        var rate: Float = .zero
        var volume: Float = 1
    }
    
    enum Action: Equatable {
        case status(AVPlayer.Status)
        case timeControlStatus(AVPlayer.TimeControlStatus)
        case reasonForWaitingToPlay(AVPlayer.WaitingReason?)
        case rate(Float)
        case currentTime(CMTime)
        case volume(Float)
    }
    
    var body: some ReducerOf<Player> {
        Reduce { state, action in
            switch action {
            case let .status(status):
                state.status = status
                return .none
            case let .timeControlStatus(status):
                state.timeControlStatus = status
                return .none
            case let .reasonForWaitingToPlay(reason):
                state.reasonWaitingToPlay = reason
                return .none
            case let .rate(rate):
                state.rate = rate
                return .none
            case let .currentTime(time):
                state.currentTime = time
                return .none
            case let .volume(volume):
                state.volume = volume
                return .none
            }
        }
    }
}
