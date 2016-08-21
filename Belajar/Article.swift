//
//  Article.swift
//  Belajar
//
//  Created by Jim Cramer on 09/06/16.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import Foundation

// regexp's for anchors
private let anchorRegExp = try! NSRegularExpression(pattern: "<(h\\d) id=\"(.+?)\">(.+?)</h\\d>", options: [])
private let htmlTagRegExp = try! NSRegularExpression(pattern: "<.+?>", options: [])

// regexp's for flashcards
private let beginMarkerRegExp = try! NSRegularExpression(pattern: "<!-- flashcard: start -->", options: [])
private let endMarkerRegExp = try! NSRegularExpression(pattern: "<!-- flashcard: end -->", options: [])
private let headerRegExp = try! NSRegularExpression(pattern: "^#+\\s*(.*)$", options: [])
private let foreignFragmentRegExp = try! NSRegularExpression(pattern: "\\*\\*(.+?)\\*\\*", options: [])

private let notFoundRange = NSMakeRange(0, NSNotFound)

struct AnchorInfo {
    let tag: String;
    let anchor: String;
    let title: String;
}

struct FlashCard {
    let sectionTitle: String
    let phrase: String
    let translation: String
}

struct FlashCardSection {
    let title: String?
    var flashCards: [FlashCard]
}

struct Article {
    var id: Int
    var topicId: Int
    var foreignLang: String
    var nativeLang: String
    var style: String?
    var mdText: String?
    var htmlText: String
    
    func getAnchors() -> [AnchorInfo] {
        var items = [AnchorInfo]()
        let text = htmlText as NSString
        let matches = anchorRegExp.matches(in: htmlText, options: [], range: NSMakeRange(0, text.length))
        for match in matches {
            let htmlTitle = text.substring(with: match.rangeAt(3))
            let title = htmlTagRegExp.stringByReplacingMatches(in: htmlTitle, options: [],
                                                               range: NSMakeRange(0, htmlTitle.utf16.count),
                                                               withTemplate: "")
            items.append(AnchorInfo(tag: text.substring(with: match.rangeAt(1)),
                                    anchor: text.substring(with: match.rangeAt(2)),
                                    title: title))
        }
        
        return items
    }
    
    var hasFlashCards: Bool {
        guard let text = mdText else { return false }
        return beginMarkerRegExp.firstMatch(in: text, options: [], range: NSMakeRange(0, text.utf16.count)) != nil
    }
    
    func getFlashCards() -> [FlashCard] {
        var flashCards = [FlashCard]()
        
        let text = mdText! as NSString
        
        let beginMarkerMatches = beginMarkerRegExp.matches(in: text as String, options: [], range: NSMakeRange(0, text.length))
        let endMarkerMatches = endMarkerRegExp.matches(in: text as String, options: [], range: NSMakeRange(0, text.length))
        
        guard beginMarkerMatches.count == endMarkerMatches.count else { return flashCards }
        
        
        for i in 0..<beginMarkerMatches.count {
            let beginMatch = beginMarkerMatches[i]
            let endMatch = endMarkerMatches[i]
            
            var title: String?
            let location = beginMatch.range.location + beginMatch.range.length
            let length = endMatch.range.location - location
            let lines = text.substring(with: NSMakeRange(location, length)).components(separatedBy: "\n")
            
            for line in lines {
                if let result = headerRegExp.firstMatch(in: line, options: [], range: NSMakeRange(0, line.utf16.count)) {
                    title = title ?? (line as NSString).substring(with: result.rangeAt(1))
                } else if title != nil {
                    let text = line as NSString
                    if let result = foreignFragmentRegExp.firstMatch(in: text as String, options: [], range: NSMakeRange(0, text.length)) {
                        let foreignText = text.substring(with: result.rangeAt(1))
                        let nativeText = text.substring(to: result.range.location) + text.substring(from: result.range.location + result.range.length)
                        let flashCard = FlashCard(sectionTitle: title!, phrase: foreignText.trimmed(), translation: nativeText.trimmed())
                        flashCards.append(flashCard)
                    }
                }
                
            }
        }
        
        return flashCards
    }
    
    static let fieldNames = [
        "id",
        "topicId",
        "foreignLang",
        "nativeLang",
        "style",
        "mdText",
        "htmlText"
    ]
}

private extension String
{
    func trimmed() -> String
    {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
}
