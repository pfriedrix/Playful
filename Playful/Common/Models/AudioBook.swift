//
//  AudioBook.swift
//  Playful
//
//  Created by Pfriedrix on 08.04.2024.
//

import Foundation

struct AudioBook: Equatable {
    static func == (lhs: AudioBook, rhs: AudioBook) -> Bool {
        lhs.title == rhs.title
    }
    
    var title: String = ""
    var author: String = ""
    var coverArtURL: URL?
    var episodes: [Episode] = []
}

struct Episode {
    let title: String
    let link: URL
}
