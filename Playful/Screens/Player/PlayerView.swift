//
//  PlayerView.swift
//  Playful
//
//  Created by Pfriedrix on 08.04.2024.
//

import SwiftUI
import ComposableArchitecture

struct PlayerView: View {
    let store: StoreOf<Playful>
    
    private struct ViewState: Equatable {
        var cover: Data
        var alert: AlertState<Playful.AlertAction>?
        
        init(state: Playful.State) {
            cover = state.cover
            alert = state.alert
        }
    }
    
    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            ZStack {
                if viewStore.cover.isEmpty {
                    ProgressView()
                } else if let uiImage = UIImage(data: viewStore.cover) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                }
            }
            .frame(minHeight: 0, maxHeight: .infinity)
            VStack {
                CaptionView(store: store)
                    .frame(minHeight: 0, maxHeight: .infinity)
                PlaybackView(store: store)
                    .frame(minHeight: 0, maxHeight: .infinity)
                ControlView(store: store)
                    .frame(minHeight: 0, maxHeight: .infinity)
                Color.clear
                    .frame(minHeight: 0, maxHeight: .infinity)
            }
            .frame(minHeight: 0, maxHeight: .infinity, alignment: .top)
            .alert(item: viewStore.binding(get: \.alert, send: .alert(.hide))) { _ in
                if let alert = viewStore.alert {
                    return Alert(alert, action: { _ in })
                }
                return Alert(title: Text("Error!"))
            }
        }
    }
}

#Preview {
    PlayerView(store: Playful.default)
}
