//
//  PlayfulApp.swift
//  Playful
//
//  Created by Pfriedrix on 08.04.2024.
//

import SwiftUI

@main
struct Playful: App {
    var body: some Scene {
        WindowGroup {
            PlayerView(store: ViewPlayer.default)
        }
    }
}
