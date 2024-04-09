//
//  PlayfulApp.swift
//  Playful
//
//  Created by Pfriedrix on 08.04.2024.
//

import SwiftUI
import ComposableArchitecture

@main
struct PlayfulApp: App {
    let store = Playful.default
    
    init() {
        store.send(.start)
    }
    
    var body: some Scene {
        WindowGroup {
            WithViewStore(store, observe: { $0.tab }) { viewStore in
                switch viewStore.state {
                case .player:
                    PlayerView(store: store)
                        .transition(.move(edge: .trailing))
                case .episodes:
                    EpisodesView(store: store)
                        .transition(.move(edge: .leading))
                }
            }
            .overlay(alignment: .bottom) {
                PageControl(store: store)
                    .padding(.vertical)
            }
        }
    }
}
