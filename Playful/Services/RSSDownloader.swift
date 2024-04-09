//
//  RSSDownloader.swift
//  Playful
//
//  Created by Pfriedrix on 08.04.2024.
//

import Foundation
import Dependencies

protocol Downloader {
    func download(from urlString: String) async throws -> Data
}

enum DownloadError: Error {
    case invalidURL
}

struct RSSDownloader: Downloader {
    func download(from urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else { throw DownloadError.invalidURL }
        
        var request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        request.timeoutInterval = 10
        return try await URLSession.shared.data(for: request).0
    }
}

extension DependencyValues {
    enum Method {
        case download(String = "https://librivox.org/rss/5663")
    }
    
    var downloader: @Sendable (Method) async throws -> Data {
        get { self[DownloaderKey.self] }
        set { self[DownloaderKey.self] = newValue }
    }
    
    private enum DownloaderKey: DependencyKey {
        static let liveValue: @Sendable (Method) async throws -> Data = { method in
            if case .download(let urlString) = method {
                return try await RSSDownloader().download(from: urlString)
            }
            throw DownloadError.invalidURL
        }
    }
}
