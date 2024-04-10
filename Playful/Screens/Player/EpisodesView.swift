//
//  EpissodesView.swift
//  Playful
//
//  Created by Pfriedrix on 10.04.2024.
//

import SwiftUI
import ComposableArchitecture

struct EpisodesView: View {
    let store: StoreOf<Playful>
    
    private struct ViewState: Equatable {
        var audiobook: AudioBook?
        var selected: Episode?
        var index: Int?
        
        init(state: Playful.State) {
            audiobook = state.audiobook
            selected = state.audiobook?.episodes[state.episode ?? 0]
            index = state.episode
        }
    }
    
    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            if let audiobook = viewStore.audiobook, let selected = viewStore.selected {
                ScrollView(showsIndicators: false) {
                    VStack {
                        ForEach(audiobook.episodes, id: \.title) { episode in
                            Button {
                                if let index = audiobook.episodes.firstIndex(of: episode) {
                                    store.send(.section(index))
                                }
                            } label: {
                                Text(episode.title)
                                    .font(.headline)
                                    .multilineTextAlignment(.leading)
                                    .foregroundStyle(selected == episode ? Color(uiColor: .label) : .gray)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 8)
                            }
                        }
                    }
                    .padding(.vertical)
                    .padding(.bottom, 50)
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    EpisodesView(store: Playful.default)
}
