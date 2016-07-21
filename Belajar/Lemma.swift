//
//  Lemma.swift
//  Belajar
//
//  Created by Jim Cramer on 13/06/16.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import Foundation

private let finalSemicolonRegex = try! RegularExpression(pattern: ";$", options: [])

struct Lemma {
    var id: Int
    var word: String
    var lang: String
    var attr: Character
    var groupName: String
    var dictOrder: Int
    var homonym: Int
    var text: String
    var base: String
    var baseLang: String
    
    static let fieldNames = [
        "id",
        "word",
        "lang",
        "attr",
        "groupName",
        "dictOrder",
        "homonym",
        "text",
        "base",
        "baseLang"
    ]
    
    static func makeSynopsis(lemmas: [Lemma]) -> String {
        var homonymGroups = [[Lemma]?]()
        
        var prevBase: String?
        var prevHomonym = -1
        var homonymGroup = [Lemma]()
        
        for lemma in lemmas {
            if prevBase == nil {
                prevBase = lemma.base
                prevHomonym = lemma.homonym
            }
            if lemma.base != prevBase! || lemma.homonym != prevHomonym {
                homonymGroups.append(homonymGroup)
                homonymGroup = [Lemma]()
            }
            homonymGroup.append(lemma)
        }
        
        homonymGroups.append(homonymGroup)
        
        let result = NSMutableString()
        
        for lemmas in homonymGroups {
            let buffer = NSMutableString()
            
            for lemma in lemmas! {
                var text = lemma.text
                if buffer.length == 0 {
                    buffer.append(text)
                } else {
                    let lemmaWordRegex = try! RegularExpression(
                        pattern: "\\*\\*\(lemma.word)\\*\\*. *(\\d+)", options: [])
                    text = lemmaWordRegex.stringByReplacingMatches(
                        in: text, options: [],
                        range: NSMakeRange(0, text.utf16.count), withTemplate: "$1")
                    buffer.append(" ")
                    buffer.append(text)
                }
            }
            
            if result.length > 0 {
                result.append("\n")
            }
            
            let homonymText = finalSemicolonRegex.stringByReplacingMatches(
                in: buffer as String, options: [],
                range: NSMakeRange(0, buffer.length), withTemplate: ".")
            result.append(homonymText)
        }
        
        return result as String
    }
}
