//
//  CaptionView.swift
//  Playful
//
//  Created by Pfriedrix on 09.04.2024.
//

import SwiftUI
import ComposableArchitecture

struct CaptionView: View {
    let store: StoreOf<Playful>
    
    private struct ViewState: Equatable {
        var audiobook: AudioBook?
        var episode: Int?
        
        init(state: Playful.State) {
            audiobook = state.audiobook
            episode = state.episode
        }
    }
    
    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            VStack(spacing: 8) {
                if let episode = viewStore.episode, let audiobook = viewStore.audiobook {
                    Text("CHAPTER \(episode + 1) OF \(audiobook.episodes.count)")
                        .font(.headline)
                        .foregroundStyle(.gray)
                    let episode = audiobook.episodes[episode]
                    Text(episode.title)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
        }
    }
}

#Preview {
    CaptionView(store: Playful.default)
}
