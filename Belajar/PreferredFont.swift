//
//  PreferredFont.swift
//  Belajar
//
//  Created by Jim Cramer on 24/07/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit

enum PreferredFont {
    
    case title1, title2, title3, headline, body, bodyBold, bodyItalic, bodyLight, callout, subhead, subheadBold, subheadItalic, caption1, caption1Bold, caption1Italic, bodySmallCaps
    
    static func get(type: PreferredFont) -> UIFont {
       
        let font: UIFont
        
        switch type {
            
        case .title1:
            font = UIFont.preferredFont(forTextStyle: UIFontTextStyleTitle1)
            
        case .title2:
            font = UIFont.preferredFont(forTextStyle: UIFontTextStyleTitle2)
        
        case .title3:
            font = UIFont.preferredFont(forTextStyle: UIFontTextStyleTitle3)
            
        case .headline:
            font = UIFont.preferredFont(forTextStyle: UIFontTextStyleHeadline)

        case .body:
            font = UIFont.preferredFont(forTextStyle: UIFontTextStyleBody)
            
        case .bodyBold:
            let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyleBody)
                .withSymbolicTraits(UIFontDescriptorSymbolicTraits.traitBold)!
            font = UIFont(descriptor: descriptor, size: 0.0)
            
        case .bodyItalic:
            let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyleBody)
                .withSymbolicTraits(UIFontDescriptorSymbolicTraits.traitItalic)!
            font = UIFont(descriptor: descriptor, size: 0.0)
            
        case .callout:
            font = UIFont.preferredFont(forTextStyle: UIFontTextStyleCallout)
            
        case .subhead:
            font = UIFont.preferredFont(forTextStyle: UIFontTextStyleSubheadline)
            
        case .subheadBold:
            let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyleSubheadline)
                .withSymbolicTraits(UIFontDescriptorSymbolicTraits.traitBold)!
            font = UIFont(descriptor: descriptor, size: 0.0)
            
        case .subheadItalic:
            let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyleSubheadline)
                .withSymbolicTraits(UIFontDescriptorSymbolicTraits.traitItalic)!
            font = UIFont(descriptor: descriptor, size: 0.0)
            
        case .caption1:
            font = UIFont.preferredFont(forTextStyle: UIFontTextStyleCaption1)
            
        case .caption1Bold:
            let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyleCaption1)
                .withSymbolicTraits(UIFontDescriptorSymbolicTraits.traitBold)!
            font = UIFont(descriptor: descriptor, size: 0.0)
            
        case .caption1Italic:
            let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyleCaption1)
                .withSymbolicTraits(UIFontDescriptorSymbolicTraits.traitItalic)!
            font = UIFont(descriptor: descriptor, size: 0.0)
            
        case .bodySmallCaps:
            let textStyleBodyDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyleBody)
                .withSymbolicTraits(UIFontDescriptorSymbolicTraits.traitBold)!
            let smallCapsBoldDescriptor = textStyleBodyDescriptor.addingAttributes([
                UIFontDescriptorFeatureSettingsAttribute: [[
                    UIFontFeatureTypeIdentifierKey: kUpperCaseType,
                    UIFontFeatureSelectorIdentifierKey: kUpperCaseSmallCapsSelector
                    ]]])
            font = UIFont(descriptor: smallCapsBoldDescriptor, size: 0.0)
            
        case .bodyLight:
            let bodyFont = get(type: PreferredFont.body)
            font = UIFont.systemFont(ofSize: bodyFont.pointSize, weight: UIFontWeightLight)
         }
        
        return font
    }
}

