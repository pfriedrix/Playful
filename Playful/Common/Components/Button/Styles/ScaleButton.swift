//
//  ScaleButton.swift
//  Playful
//
//  Created by Pfriedrix on 08.04.2024.
//

import SwiftUI

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .background(
                Color.gray
                    .opacity(configuration.isPressed ? 0.3 : 0)
                    .clipShape(Circle())
                    .scaleEffect(1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.8 : 1.0)
    }
}

extension ButtonStyle where Self == ScaleButtonStyle {
    static var scale: ScaleButtonStyle {
        ScaleButtonStyle()
    }
}
