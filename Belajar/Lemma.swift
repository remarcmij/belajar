//
//  Lemma.swift
//  Belajar
//
//  Created by Jim Cramer on 13/06/16.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import Foundation
import FMDB

private let batchChunkSize = 5

class LemmaBatch {
    // note: class in preference of struct to minimise reference counting
    // on individual string properties
    let base: String
    let baseLang: String
    let word: String
    let body: String
    
    init(base: String, baseLang: String, word: String, body: String) {
        self.base = base
        self.baseLang = baseLang
        self.word = word
        self.body = body
    }
}

class Lemma {
    var word: String
    var homonym: Int
    var text: String
    var base: String
    var baseLang: String
    
    init(word: String, homonym: Int, text: String, base: String, baseLang: String) {
        self.word = word
        self.homonym = homonym
        self.text = text
        self.base = base
        self.baseLang = baseLang
    }
    
    static let fieldNames = [
        "word",
        "homonym",
        "text",
        "base",
        "baseLang"
    ]
    
    static func makeLemma(fromResultSet rs: FMResultSet) -> Lemma {
        return Lemma(word: rs.string(forColumnIndex: 0),
                     homonym: Int(rs.int(forColumnIndex: 1)),
                     text: rs.string(forColumnIndex: 2),
                     base: rs.string(forColumnIndex: 3),
                     baseLang: rs.string(forColumnIndex: 4))
    }

    private static let finalSemicolonRegex = try! NSRegularExpression(pattern: ";$", options: [])
    
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
                    let lemmaWordRegex = try! NSRegularExpression(
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
    
    static func batchLemmas(word: String, lemmas: [Lemma]) -> [LemmaBatch] {
        
        var batches = [LemmaBatch]()
        var prevBase = ""
        var prevBaseLang = ""
        var prevHomonym = -1
        var buffer = NSMutableString()
        var lemmaCount = 0
        
        for lemma in lemmas {
            
            if (prevBase.isEmpty) {
                prevBase = lemma.base
                prevBaseLang = lemma.baseLang
                prevHomonym = lemma.homonym
            }
            
            if (lemma.base != prevBase || lemma.homonym != prevHomonym || (lemma.base == word && lemmaCount >= batchChunkSize)) {
                let batch = LemmaBatch(base: prevBase, baseLang: prevBaseLang,
                                             word: word, body: buffer as String)
                batches.append(batch)
                prevBase = lemma.base
                prevBaseLang = lemma.baseLang
                prevHomonym = lemma.homonym
                lemmaCount = 0
                buffer = NSMutableString()
            }
            
            if (buffer.length > 0) {
                buffer.append("\n")
            }
            buffer.append(lemma.text)
            lemmaCount += 1
        }
        
        if (buffer.length > 0) {
            let lastLemma = lemmas.last!
            let batch = LemmaBatch(base: lastLemma.base, baseLang: lastLemma.baseLang,
                                         word: word, body: buffer as String)
            batches.append(batch)
        }
        
        return batches
    }

}
