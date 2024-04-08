//
//  XMLParser.swift
//  Playful
//
//  Created by Pfriedrix on 08.04.2024.
//

import Foundation

protocol RSSParser {
    func parse(data: Data) -> AudioBook?
}

class AudioBookParser: NSObject, XMLParserDelegate {
    private var currentElement = ""
    private var currentTitle: String = ""
    private var currentLink: String = ""
    private var currentAuthor: String = ""
    private var imageURL: URL?
    
    internal var audioBook: AudioBook?
    
    func parserDidStartDocument(_ parser: XMLParser) {
        audioBook = AudioBook()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if elementName == "enclosure" {
            currentLink = attributeDict["url"] ?? ""
        } else if elementName == "itunes:image" {
            imageURL = URL(string: attributeDict["href"] ?? "")
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement {
        case "title":
            currentTitle += string
        case "itunes:author":
            currentAuthor += string
        default:
            break
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            if let linkURL = URL(string: currentLink) {
                let episode = Episode(title: currentTitle.trimmingCharacters(in: .whitespacesAndNewlines), link: linkURL)
                audioBook?.episodes.append(episode)
            }
            
            currentTitle = ""
            currentLink = ""
        } else if elementName == "channel" {
            audioBook?.title = currentTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            audioBook?.author = currentAuthor.trimmingCharacters(in: .whitespacesAndNewlines)
            audioBook?.coverArtURL = imageURL
        }
    }
}

extension AudioBookParser: RSSParser {
    func parse(data: Data) -> AudioBook? {
        let parser = XMLParser(data: data)
        parser.delegate = self
        if parser.parse() {
            return audioBook
        } 
        return nil
    }
}
