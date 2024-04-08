//
//  PlayerView.swift
//  Playful
//
//  Created by Pfriedrix on 08.04.2024.
//

import SwiftUI
import ComposableArchitecture

struct PlayerView: View {
    let store: StoreOf<ViewPlayer>
    let player: PlayerService
    
    init(store: StoreOf<ViewPlayer>) {
        self.store = store
        player = PlayerService(viewStore: store)
        
        store.send(.start)
    }
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ControlView(store: store)
        }
    }
}

#Preview {
    PlayerView(store: .init(initialState: ViewPlayer.State()) {
        ViewPlayer()
    })
}

// Page Control
// Control Media
// PlaybackSpeed
// Progress Bar (duration, current)
// Chapter Info
// Cover
