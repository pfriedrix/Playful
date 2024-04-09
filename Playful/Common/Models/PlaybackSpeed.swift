//
//  PlaybackSpeed.swift
//  Playful
//
//  Created by Pfriedrix on 09.04.2024.
//

import Foundation

enum PlaybackSpeed: Double {
    case verySlow = 0.5, slow = 0.75, normal = 1, fast = 1.25, faster = 1.5, fastest = 2
    
    var next: PlaybackSpeed {
        switch self {
        case .verySlow: .slow
        case .slow: .normal
        case .normal: .fast
        case .fast: .faster
        case .faster: .fastest
        case .fastest: .verySlow
        }
    }
    
    var string: String {
        switch self {
        case .verySlow: "0.5"
        case .slow: "0.75"
        case .normal: "1"
        case .fast: "1.25"
        case .faster: "1.5"
        case .fastest: "2"
        }
    }
}
