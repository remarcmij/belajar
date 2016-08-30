//
//  LemmaCell.swift
//  Belajar
//
//  Created by Jim Cramer on 21/07/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class LemmaCell: UITableViewCell, TTTAttributedLabelDelegate {

    private static var attributedStringCache = [Int: NSAttributedString]()
    private static let linkColor = UIColor(netHex: 0x303F9F)

    var bodyText: NSAttributedString?
    var headerText: NSAttributedString?
    
    static var linkAttributes = {[
        NSUnderlineStyleAttributeName: NSNumber(value: NSUnderlineStyle.styleNone.rawValue),
        NSForegroundColorAttributeName: linkColor
        ]}()
    
    static func clearCache() {
        attributedStringCache.removeAll()
    }
    
    func setLemmaGroup(with lemmaBatch: LemmaBatch, forRow rowIndex: Int) {
        bodyText = getAttributedString(from: lemmaBatch.body, cacheIndex: rowIndex, clickAction: "synopsis")
        headerText = AttributedStringHelper.makeClickableWord(from: lemmaBatch.base.uppercased() as NSString,
                                                              clickAction: "lookup", font: PreferredFont.get(type: .caption1Bold))
    }
    
    private func getAttributedString(from sourceString: String, cacheIndex: Int, clickAction: String, useSmallFont: Bool = false) -> NSAttributedString {
        if let attributedString = type(of: self).attributedStringCache[cacheIndex] {
            return attributedString
        }
        let attributedString = AttributedStringHelper.makeAttributedText(from: sourceString as NSString, clickAction: clickAction, useSmallFont: useSmallFont)
        type(of: self).attributedStringCache[cacheIndex] = attributedString
        return attributedString
    }
   
    func hideSeparator() {
        // to be overridden by subclasses
    }

    // MARK: - TTTAttributedLabelDelegate
    
    /// Called when substring marked with an NSLinkAttributeName attribute is clicked.
    ///
    /// - parameters:
    ///    - label: The label whose link was selected.
    ///    - url: The URL for the selected link.
    ///
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        guard let queryItems = NSURLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
            let percentEncodedWord = queryItems.filter({ $0.name == "word" }).first?.value,
            let action = queryItems.filter({ $0.name == "action" }).first?.value,
            let word = percentEncodedWord.removingPercentEncoding
            else { return }
        
        let notificationName = action == "synopsis" ? Constants.wordClickNotification : Constants.wordLookupNotification
        NotificationCenter.default.post(name: notificationName, object: label, userInfo: ["word": word])
    }
}
