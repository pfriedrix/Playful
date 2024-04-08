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
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack(spacing: 20) {
                Button {
                    
                } label: {
                    Image(systemName: "backward.end.fill")
                        .padding(4)
                }
                .buttonStyle(.scale)
                Button {
                    
                } label: {
                    Image(systemName: "gobackward.5")
                }
                .buttonStyle(.scale)
                if viewStore.isLoading {
                    ProgressView()
                } else {
                    playButton
                }
                Button {
                    
                } label: {
                    Image(systemName: "goforward.10")
                }
                .buttonStyle(.scale)
                Button {
                    
                } label: {
                    Image(systemName: "forward.end.fill")
                        .padding(4)
                }
                .buttonStyle(.scale)
            }
            .font(.title2)
        }
    }
    
    var playButton: some View {
        Button {
            store.send(.control(.play))
        } label: {
            Image(systemName: "play.fill")
                .font(.largeTitle)
                .padding(4)
        }
        .buttonStyle(.scale)
    }
    
    var pauseButton: some View {
        Button {
            store.send(.control(.pause))
        } label: {
            Image(systemName: "pause.fill")
                .font(.largeTitle)
                .padding(4)
        }
        .buttonStyle(.scale)
    }
}
