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
    
    private static var regularFont: UIFont = {
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyleBody)
        return UIFont(descriptor: descriptor, size: 0.0)
    }()
    
    private static var boldFont: UIFont = {
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyleBody)
            .withSymbolicTraits(UIFontDescriptorSymbolicTraits.traitBold)!
        return UIFont(descriptor: descriptor, size: 0.0)
    }()
    
    private static var italicFont: UIFont = {
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyleBody)
            .withSymbolicTraits(UIFontDescriptorSymbolicTraits.traitItalic)!
        return UIFont(descriptor: descriptor, size: 0.0)
    }()
    
    private static var smallRegularFont: UIFont = {
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyleCaption1)
        return UIFont(descriptor: descriptor, size: 0.0)
    }()
    
    private static var smallBoldFont: UIFont = {
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyleCaption1)
            .withSymbolicTraits(UIFontDescriptorSymbolicTraits.traitBold)!
        return UIFont(descriptor: descriptor, size: 0.0)
    }()
    
    private static var smallItalicFont: UIFont = {
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyleCaption1)
            .withSymbolicTraits(UIFontDescriptorSymbolicTraits.traitItalic)!
        return UIFont(descriptor: descriptor, size: 0.0)
    }()
    
    static func makeAttributedText(from text: NSString, useSmallFont: Bool = false) -> AttributedString {
        let attributedString = NSMutableAttributedString(string: "")
        
        var startPos = 0
        let matches = Util.markdownRegExp.matches(in: text as String, options: [], range: NSMakeRange(0, text.length))
        
        let regularFont = useSmallFont ? Util.smallRegularFont : Util.regularFont
        let boldFont = useSmallFont ? Util.smallBoldFont : Util.boldFont
        let italicFont = useSmallFont ? Util.smallItalicFont : Util.italicFont
        
        for match in matches {
            let outerRange = match.range
            
            if outerRange.location > startPos {
                let snippet = text.substring(with: NSMakeRange(startPos, outerRange.location - startPos))
                attributedString.append(AttributedString(string: snippet, attributes: [NSFontAttributeName: regularFont]))
            }
            
            if match.range(at: 1).location != NSNotFound {
                let snippet = text.substring(with: match.range(at: 1))
                attributedString.append(makeClickableWord(from: snippet, font: boldFont))
            } else if match.range(at: 2).location != NSNotFound {
                let snippet = text.substring(with: match.range(at: 2))
                attributedString.append(makeClickableWord(from: snippet, font: italicFont))
            } else if match.range(at: 3).location != NSNotFound {
                let snippet = text.substring(with: match.range(at: 3))
                attributedString.append(AttributedString(string: snippet, attributes: [NSFontAttributeName: boldFont]))
            } else if match.range(at: 4).location != NSNotFound {
                let snippet = text.substring(with: match.range(at: 4))
                attributedString.append(AttributedString(string: snippet, attributes: [NSFontAttributeName: italicFont]))
            }
            
            startPos = outerRange.location + outerRange.length
        }
        
        if (startPos < text.length) {
            let snippet = text.substring(from: startPos)
            attributedString.append(AttributedString(string: snippet, attributes: [NSFontAttributeName: regularFont]))
        }

        return attributedString
    }
    
    static func makeClickableWord(from word: NSString, font: UIFont) -> AttributedString {
        let urlEncoded = word.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let url = URL(string: "http://belajar.nl/q?word=\(urlEncoded)")!
        let attributes = [NSFontAttributeName: font,
                          NSLinkAttributeName: url]
        return AttributedString(string: word as String, attributes: attributes)
    }
}
