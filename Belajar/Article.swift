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
private let beginMarkerRegExp = try! NSRegularExpression(pattern: "<a class=\"flashcard-start\"></a>", options: [])
private let endMarkerRegExp = try! NSRegularExpression(pattern: "<a class=\"flashcard-end\"></a>", options: [])
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

class Article {
    var id: Int
    var topicId: Int
    let foreignLang: String
    let nativeLang: String
    let mdText: String?
    let htmlText: String
    
    var values: [Any] {
        return [
            NSNumber(value: topicId),
            NSString(string: foreignLang),
            NSString(string: nativeLang),
            mdText != nil ? NSString(string: mdText!) : NSNull(),
            NSString(string: htmlText)
        ]
    }
    
    static func create(fromJSONObject json: [String: Any]) -> Article? {
        guard let foreignLang = json["foreignLang"] as? String,
        let nativeLang = json["nativeLang"] as? String,
        let htmlText = json["htmlText"] as? String
            else { return nil }
        
        let mdText = json["mdText"] as? String
        
        return Article(id: -1,
                       topicId: -1,
                       foreignLang: foreignLang,
                       nativeLang: nativeLang,
                       mdText: mdText,
                       htmlText: htmlText)
    }
    
    init(id: Int, topicId: Int, foreignLang: String, nativeLang: String, mdText: String?, htmlText: String) {
        self.id = id
        self.topicId = topicId
        self.foreignLang = foreignLang
        self.nativeLang = nativeLang
        self.mdText = mdText
        self.htmlText = htmlText
    }
    
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
