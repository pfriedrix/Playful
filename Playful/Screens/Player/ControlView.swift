//
//  ControlView.swift
//  Playful
//
//  Created by Pfriedrix on 08.04.2024.
//

import SwiftUI
import ComposableArchitecture

struct ControlView: View {
    let store: StoreOf<ViewPlayer>
    
    private struct ViewState: Equatable {
        var isLoading: Bool
        var player: Player.State
        
        init(state: ViewPlayer.State) {
            self.isLoading = state.isLoading
            self.player = state.player
        }
    }
    
    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            HStack(spacing: 20) {
                Button {
                    store.send(.control(.prev))
                } label: {
                    Image(systemName: "backward.end.fill")
                        .padding(4)
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
                    if viewStore.isLoading && viewStore.player.status == .readyToPlay {
                        ProgressView()
                    } else {
                        let status = viewStore.player.timeControlStatus == .paused
                        Button {
                            store.send(.control(status ? .play : .pause))
                        } label: {
                            Image(systemName: status ? "play.fill" : "pause.fill")
                                .font(.largeTitle)
                                .padding(4)
                        }
                        .buttonStyle(.scale)
                    }
                }
                .frame(width: 30)
                Button {
                    store.send(.forward(by: 10))
                } label: {
                    Image(systemName: "goforward.10")
                        .padding(2)
                }
                .buttonStyle(.scale)
                Button {
                    store.send(.control(.next))
                } label: {
                    Image(systemName: "forward.end.fill")
                        .padding(4)
                }
                .buttonStyle(.scale)
            }
            .font(.title2)
        }
    }
}
