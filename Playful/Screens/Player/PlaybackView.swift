//
//  ProgressBar.swift
//  Playful
//
//  Created by Pfriedrix on 09.04.2024.
//

import SwiftUI
import ComposableArchitecture

struct PlaybackView: View {
    let store: StoreOf<Playful>
    
    private struct ViewState: Equatable {
        var isLoading: Bool
        var player: Player.State = .init()

        init(state: Playful.State) {
            isLoading = state.isLoading
            player = state.player
        }
    }
    
    let onEditingChanged: (StoreOf<Playful>, Bool) -> Void = { store, result in
        if !result {
            store.send(.doneSeeking)
        }
    }
    
    init(store: StoreOf<Playful>) {
        self.store = store
        
        UISlider.appearance().thumbTintColor = .systemBlue
    }

    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            VStack(spacing: 8) {
                HStack {
                    let value = Binding(get: viewStore.player.currentTime.seconds.rounded,
                                          set: { store.send(.seeker($0))})
                    Text(viewStore.player.currentTime.string)
                        .frame(width: 40)
                    Slider(value: value,
                           in: 0...viewStore.player.duration.seconds,
                           onEditingChanged: { onEditingChanged(store, $0) })
                    Text(viewStore.player.duration.string)
                        .frame(width: 40)
                }
                .font(.system(.caption))
                .foregroundStyle(.gray)
                playbackSpeed(speed: viewStore.player.rate) {
                    store.send(.player(.rate(viewStore.player.rate.next)))
                }
            }
            .padding(.horizontal)
            .opacity(viewStore.isLoading || viewStore.player.isLoading ? 0 : 1)
        }
    }
    
    func playbackSpeed(speed: PlaybackSpeed, _ action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Text("Speed x\(speed.string)")
                .font(.body)
                .padding(8)
                .background(.gray.opacity(0.2))
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PlaybackView(store: Playful.default)
}
