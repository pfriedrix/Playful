//
//  CMTime.swift
//  Playful
//
//  Created by Pfriedrix on 09.04.2024.
//

import AVFoundation

extension CMTime {
    var string: String {
        if self == .indefinite { return "--:--"}
        let total = Int(CMTimeGetSeconds(self))
        let hours = total / 3600
        let minutes = total % 3600 / 60
        let seconds = (total % 3600) % 60
        
        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
}
