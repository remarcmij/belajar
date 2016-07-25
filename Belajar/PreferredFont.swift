//
//  PreferredFont.swift
//  Belajar
//
//  Created by Jim Cramer on 24/07/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit

enum PreferredFont {
    
    case regular, bold, italic, smallRegular, smallBold, smallItalic, smallCapsBold, bodyTextLight
    
    private static var fontCache = [PreferredFont: UIFont]()
    
    static func get(type: PreferredFont) -> UIFont {
        if let font = fontCache[type] {
            return font
        }
        
        let font: UIFont
        
        switch type {
            
        case .regular:
            font = UIFont.preferredFont(forTextStyle: UIFontTextStyleBody)
            
        case .bold:
            let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyleBody)
                .withSymbolicTraits(UIFontDescriptorSymbolicTraits.traitBold)!
            font = UIFont(descriptor: descriptor, size: 0.0)
            
        case .italic:
            let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyleBody)
                .withSymbolicTraits(UIFontDescriptorSymbolicTraits.traitItalic)!
            font = UIFont(descriptor: descriptor, size: 0.0)
            
            
        case .smallRegular:
            font = UIFont.preferredFont(forTextStyle: UIFontTextStyleCaption1)
            
        case .smallBold:
            let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyleCaption1)
                .withSymbolicTraits(UIFontDescriptorSymbolicTraits.traitBold)!
            font = UIFont(descriptor: descriptor, size: 0.0)
            
        case .smallItalic:
            let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyleCaption1)
                .withSymbolicTraits(UIFontDescriptorSymbolicTraits.traitItalic)!
            font = UIFont(descriptor: descriptor, size: 0.0)
            
        case .smallCapsBold:
            let textStyleBodyDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyleBody)
                .withSymbolicTraits(UIFontDescriptorSymbolicTraits.traitBold)!
            let smallCapsBoldDescriptor = textStyleBodyDescriptor.addingAttributes([
                UIFontDescriptorFeatureSettingsAttribute: [[
                    UIFontFeatureTypeIdentifierKey: kUpperCaseType,
                    UIFontFeatureSelectorIdentifierKey: kUpperCaseSmallCapsSelector
                    ]]])
            font = UIFont(descriptor: smallCapsBoldDescriptor, size: 0.0)
            
        case .bodyTextLight:
            let bodyFont = get(type: PreferredFont.regular)
            font = UIFont.systemFont(ofSize: bodyFont.pointSize, weight: UIFontWeightLight)
         }
        
        fontCache[type] = font
        return font
    }
    
    static func clearCache() {
        fontCache.removeAll()
    }
}

