//
//  Lemma.swift
//  Belajar
//
//  Created by Jim Cramer on 13/06/16.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import Foundation

private let xxx = try! RegularExpression(pattern: "", options: [])

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
        var homonymGroup = [Lemma]()
        
        var prevBase: String?
        var prevHomonym = -1
        
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
        
        if homonymGroup.count != 0 {
            homonymGroups.append(homonymGroup)
        }
        
        let result = NSMutableString()
        
        for lemmas in homonymGroups {
            let buffer = NSMutableString()
            
            for lemma in lemmas! {
                var text = lemma.text
                if buffer.length == 0 {
                    buffer.append(text)
                } else {
                    text = text.replacingOccurrences(of: "**\(lemma.word)**", with: lemma.word)
                    buffer.append(text)
                }
            }
            
            if result.length > 0 {
                result.append("\n")
            }
            
            result.append(buffer as String)
        }
        
        return result as String
    }
}
