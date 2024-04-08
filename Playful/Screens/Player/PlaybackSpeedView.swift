//
//  PlaybackSpeedView.swift
//  Playful
//
//  Created by Pfriedrix on 08.04.2024.
//

import SwiftUI

struct PlaybackSpeedView: View {
    var body: some View {
        Button {
            
        } label: {
            Text("Speed x1")
                .padding(8)
                .background(.gray.opacity(0.2))
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PlaybackSpeedView()
}
