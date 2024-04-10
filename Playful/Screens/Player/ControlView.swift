//
//  ControlView.swift
//  Playful
//
//  Created by Pfriedrix on 08.04.2024.
//

import SwiftUI
import ComposableArchitecture

struct ControlView: View {
    let store: StoreOf<Playful>
    
    private struct ViewState: Equatable {
        var isLoading: Bool
        var player: Player.State
        var index: Int
        var episodes: Int
        
        init(state: Playful.State) {
            isLoading = state.isLoading
            player = state.player
            index = state.episode ?? 0
            episodes = state.audiobook?.episodes.count ?? 0
        }
    }
    
    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            HStack(spacing: 20) {
                Button {
                    store.send(.previous)
                } label: {
                    Image(systemName: "backward.end.fill")
                        .padding(4)
                        .foregroundStyle(viewStore.index > 0 ? Color(uiColor: .label) : .gray)
                }
                .buttonStyle(.scale)
                Button {
                    store.send(.backward(by: 5))
                } label: {
                    Image(systemName: "gobackward.5")
                        .padding(2)
                }
                .buttonStyle(.scale)
                ZStack {
                    if viewStore.isLoading || viewStore.player.isLoading {
                        ProgressView()
                    } else  {
                        let status = viewStore.player.timeControlStatus == .paused
                        Button {
                            store.send(.player(status ? .play : .pause))
                        } label: {
                            Image(systemName: status ? "play.fill" : "pause.fill")
                                .font(.largeTitle)
                                .padding(4)
                        }
                        .buttonStyle(.scale)
                    }
                }
                .frame(width: 30, height: 30)
                Button {
                    store.send(.forward(by: 10))
                } label: {
                    Image(systemName: "goforward.10")
                        .padding(2)
                }
                .buttonStyle(.scale)
                Button {
                    store.send(.next)
                } label: {
                    Image(systemName: "forward.end.fill")
                        .padding(4)
                        .foregroundStyle(viewStore.index < viewStore.episodes ? Color(uiColor: .label) : .gray)
                }
                .buttonStyle(.scale)
            }
            .font(.title2)
        }
        .padding(.vertical)
    }
}
