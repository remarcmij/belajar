//
//  LemmaCell.swift
//  Belajar
//
//  Created by Jim Cramer on 21/07/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit
import TTTAttributedLabel


class LemmaBaseCell: UITableViewCell, TTTAttributedLabelDelegate {

    private static var attributedStringCache = [Int: AttributedString]()

    var bodyText: AttributedString?
    var headerText: AttributedString?
    
    static var linkAttributes = {[
        NSUnderlineStyleAttributeName: NSNumber(value: NSUnderlineStyle.styleNone.rawValue),
        NSForegroundColorAttributeName: UIButton().tintColor
        ]}()
    
    static func clearCache() {
        attributedStringCache.removeAll()
    }
    
    func setLemmaText(with lemmaHomonym: LemmaHomonym, forRow rowIndex: Int) {
        bodyText = getAttributedString(from: lemmaHomonym.body, cacheIndex: rowIndex * 2, clickAction: "synopsis")
        
        var text = "**\(lemmaHomonym.base.uppercased())**"
        if lemmaHomonym.base != lemmaHomonym.word {
            text = "▷ " + text
        }
        headerText = getAttributedString(from: text, cacheIndex: rowIndex * 2 + 1, clickAction: "lookup", useSmallFont: true)
    }
    
    private func getAttributedString(from sourceString: String, cacheIndex: Int, clickAction: String, useSmallFont: Bool = false) -> AttributedString {
        if let attributedString = self.dynamicType.attributedStringCache[cacheIndex] {
            return attributedString
        }
        let attributedString = AttributedStringHelper.makeAttributedText(from: sourceString, clickAction: clickAction, useSmallFont: useSmallFont)
        self.dynamicType.attributedStringCache[cacheIndex] = attributedString
        return attributedString
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
        
        let notificationName = action == "synopsis" ? Constants.WordClickNotification : Constants.WordLookupNotification
        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: ["word": word])
    }
}
