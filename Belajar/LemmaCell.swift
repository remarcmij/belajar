//
//  LemmaCell.swift
//  Belajar
//
//  Created by Jim Cramer on 21/07/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit
import TTTAttributedLabel

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex: Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

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
        headerText = AttributedStringHelper.makeClickableWord(from: lemmaBatch.base.uppercased(),
                                                              clickAction: "lookup", font: PreferredFont.get(type: .caption1Bold))
    }
    
    private func getAttributedString(from sourceString: String, cacheIndex: Int, clickAction: String, useSmallFont: Bool = false) -> NSAttributedString {
        if let attributedString = self.dynamicType.attributedStringCache[cacheIndex] {
            return attributedString
        }
        let attributedString = AttributedStringHelper.makeAttributedText(from: sourceString, clickAction: clickAction, useSmallFont: useSmallFont)
        self.dynamicType.attributedStringCache[cacheIndex] = attributedString
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
        
        let notificationName = action == "synopsis" ? Constants.WordClickNotification : Constants.WordLookupNotification
        NotificationCenter.default.post(name: notificationName, object: label, userInfo: ["word": word])
    }
}
