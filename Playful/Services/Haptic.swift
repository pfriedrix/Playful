//
//  HapticService.swift
//  Playful
//
//  Created by Pfriedrix on 10.04.2024.
//

import Dependencies
import UIKit

extension DependencyValues {
    var haptic: @Sendable (UIImpactFeedbackGenerator.FeedbackStyle) async -> Void {
        get { self[HapticKey.self] }
        set { self[HapticKey.self] = newValue }
    }

    private enum HapticKey: DependencyKey {
        static let liveValue: @Sendable (UIImpactFeedbackGenerator.FeedbackStyle) async  -> Void = { @MainActor style in
            let haptic = UIImpactFeedbackGenerator(style: style)
            haptic.impactOccurred()
        }
    }
}
