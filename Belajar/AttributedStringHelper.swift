//
//  AttributedStringHelper.swift
//  Belajar
//
//  Created by Jim Cramer on 12/07/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit

struct AttributedStringHelper {
    
    private static let markdownRegExp = try! NSRegularExpression(pattern: "\\*\\*(.+?)\\*\\*|\\*(.+?)\\*|__(.+?)__|_(.+?)_", options: [])
    
    static func makeAttributedText(from text: NSString, clickAction: String? = nil, useSmallFont: Bool = false) -> NSAttributedString {
        //        let startTime = Date()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.paragraphSpacing = 4.0
        let attributedString = NSMutableAttributedString(string: "")
        
        var startPos = 0
        let matches = AttributedStringHelper.markdownRegExp.matches(in: text as String, options: [], range: NSMakeRange(0, text.length))
        
        let regularFontType = useSmallFont ? PreferredFont.subhead : .body
        let boldFontType = useSmallFont ? PreferredFont.subheadBold : .bodyBold
        let italicFontType = useSmallFont ? PreferredFont.subheadItalic : .bodyItalic
        
        let regularFont = PreferredFont.get(type: regularFontType)
        let boldFont = PreferredFont.get(type: boldFontType)
        let italicFont = PreferredFont.get(type: italicFontType)
        
        for match in matches {
            let outerRange = match.range
            
            if outerRange.location > startPos {
                let snippet = text.substring(with: NSMakeRange(startPos, outerRange.location - startPos))
                attributedString.append(NSAttributedString(string: snippet, attributes: [NSFontAttributeName: regularFont]))
            }
            
            if match.rangeAt(1).location != NSNotFound {
                let snippet = text.substring(with: match.rangeAt(1))
                attributedString.append(clickAction != nil
                    ? makeClickableWord(from: snippet, clickAction: clickAction!, font: boldFont)
                    : NSAttributedString(string: snippet, attributes: [NSFontAttributeName: boldFont]))
            } else if match.rangeAt(2).location != NSNotFound {
                let snippet = text.substring(with: match.rangeAt(2))
                attributedString.append(clickAction != nil
                    ? makeClickableWord(from: snippet, clickAction: clickAction!, font: italicFont)
                    : NSAttributedString(string: snippet, attributes: [NSFontAttributeName: italicFont]))
            } else if match.rangeAt(3).location != NSNotFound {
                let snippet = text.substring(with: match.rangeAt(3))
                attributedString.append(NSAttributedString(string: snippet, attributes: [NSFontAttributeName: boldFont]))
            } else if match.rangeAt(4).location != NSNotFound {
                let snippet = text.substring(with: match.rangeAt(4))
                attributedString.append(NSAttributedString(string: snippet, attributes: [NSFontAttributeName: italicFont]))
            }
            
            startPos = outerRange.location + outerRange.length
        }
        
        if (startPos < text.length) {
            let snippet = text.substring(from: startPos)
            attributedString.append(NSAttributedString(string: snippet, attributes: [NSFontAttributeName: regularFont]))
        }
        
        attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        
        //        let endTime = Date()
        //        let elapsed = endTime.timeIntervalSince(startTime) * 1000
        //        print("makeAttributedText took \(elapsed) ms")
        
        return attributedString
    }
    
    static func makeClickableWord(from word: NSString, clickAction: String, font: UIFont) -> NSAttributedString {
        let urlEncoded = word.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let url = URL(string: "http://belajar.nl/q?word=\(urlEncoded)&action=\(clickAction)")!
        let attributes = [NSFontAttributeName: font,
                          NSLinkAttributeName: url]
        return NSAttributedString(string: word as String, attributes: attributes)
    }
    
}
