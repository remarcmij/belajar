//
//  Util.swift
//  Belajar
//
//  Created by Jim Cramer on 09/06/16.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit

class Util {
    static func joinWithComma(_ fieldNames: [String], omitNames: Set<String> = []) -> String {
        return fieldNames
            .filter {fieldName in !omitNames.contains(fieldName)}
            .joined(separator: ",")
    }
    
    private static let markdownRegExp = try! RegularExpression(pattern: "\\*\\*(.+?)\\*\\*|\\*(.+?)\\*|__(.+?)__|_(.+?)_", options: [])
    private static let foreignWordRegExp = try! RegularExpression(pattern: "[-'()\\p{L}]{2,}", options: [])
    private static let regularFont = UIFont.systemFont(ofSize: UIFont.systemFontSize())
    private static let boldFont = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize())
    private static let italicFont = UIFont.italicSystemFont(ofSize: UIFont.systemFontSize())
    private static let smallRegularFont = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize())
    private static let smallBoldFont = UIFont.boldSystemFont(ofSize: UIFont.smallSystemFontSize())
    private static let smallItalicFont = UIFont.italicSystemFont(ofSize: UIFont.smallSystemFontSize())
    
    static func makeAttributedText(from text: NSString, useSmallFont: Bool = false) -> AttributedString {
        
        let attributedString = NSMutableAttributedString(string: "")
        
        func makeClickableText(from snippet: NSString, font: UIFont) {
            var startPos = 0
            let matches = Util.foreignWordRegExp.matches(in: snippet as String, options: [], range: NSMakeRange(0, snippet.length))
            for match in matches {
                if match.range.location > startPos {
                    let leadingText = snippet.substring(with: NSMakeRange(startPos, match.range.location - startPos))
                    attributedString.append(AttributedString(string: leadingText, attributes: [NSFontAttributeName: font]))
                }
                
                let word = snippet.substring(with: match.range)
                if let latinized = word.applyingTransform(StringTransform.toLatin, reverse: false),
                    urlEncoded = latinized.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
                    let url = URL(string: "http://www.belajar.nl/lookup?lookup=\(urlEncoded)")!
                    let attributes = [NSFontAttributeName: font,
                                      NSLinkAttributeName: url]
                    attributedString.append(AttributedString(string: word, attributes: attributes))
                    startPos = match.range.location + match.range.length
                }
            } 
            
            if (startPos < snippet.length) {
                let trailingText = text.substring(from: startPos)
                attributedString.append(AttributedString(string: trailingText, attributes: [NSFontAttributeName: font]))
            }
        }
        
        var startPos = 0
        let matches = Util.markdownRegExp.matches(in: text as String, options: [], range: NSMakeRange(0, text.length))
        
        let regularFont = useSmallFont ? Util.smallRegularFont : Util.regularFont
        let boldFont = useSmallFont ? Util.smallBoldFont : Util.boldFont
        let italicFont = useSmallFont ? Util.smallItalicFont : Util.italicFont
        
        for match in matches {
            let outerRange = match.range(at: 0)
            var snippet = ""
            
            if outerRange.location > startPos {
                snippet = text.substring(with: NSMakeRange(startPos, outerRange.location - startPos))
                attributedString.append(AttributedString(string: snippet, attributes: [NSFontAttributeName: regularFont]))
            }
            
            if match.range(at: 1).location != NSNotFound {
                snippet = text.substring(with: match.range(at: 1))
                makeClickableText(from: snippet, font: boldFont)
            } else if match.range(at: 2).location != NSNotFound {
                snippet = text.substring(with: match.range(at: 2))
                makeClickableText(from: snippet, font: italicFont)
            } else if match.range(at: 3).location != NSNotFound {
                snippet = text.substring(with: match.range(at: 3))
                attributedString.append(AttributedString(string: snippet, attributes: [NSFontAttributeName: boldFont]))
            } else if match.range(at: 4).location != NSNotFound {
                snippet = text.substring(with: match.range(at: 4))
                attributedString.append(AttributedString(string: snippet, attributes: [NSFontAttributeName: italicFont]))
            }
            startPos = outerRange.location + outerRange.length
        }
        
        if (startPos < text.length) {
            let snippet = text.substring(from: startPos)
            attributedString.append(AttributedString(string: snippet, attributes: [NSFontAttributeName: Util.regularFont]))
        }
        
        return attributedString
    }
    
}
