//
//  XMLParserTests.swift
//  PlayfulTests
//
//  Created by Pfriedrix on 08.04.2024.
//

import XCTest
@testable import Playful

final class RSSParserTests: XCTestCase {
    var downloader: Downloader!
    var parser: RSSParser!
    
    override func setUp() {
        super.setUp()
        downloader = RSSDownloader()
        parser = AudioBookParser()
    }
    
    override func tearDown() {
        downloader = nil
        parser = nil
        super.tearDown()
    }
    
    func testDownloadAndParseRSS() async throws {
        let rss = try await downloader.download(from: "https://librivox.org/rss/5663")
        XCTAssertFalse(rss.isEmpty, "Shoud have more size then \(rss.count)")
        let audioBook = parser.parse(data: rss)
        XCTAssertNotNil(audioBook, "Should have audiobook")        
    }
}
