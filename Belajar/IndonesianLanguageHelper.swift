//
//  IndonesianLanguageHelper.swift
//  Belajar
//
//  Created by Jim Cramer on 30/06/16.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import Foundation

private extension String {
    func substring(with range: NSRange) -> String {
        return (self as NSString).substring(with: range)
    }
    
    func substring(from index: Int) -> String {
        return (self as NSString).substring(from: index)
    }
}

private extension RegularExpression {
    func firstMatch(in text: String) -> TextCheckingResult? {
        return self.firstMatch(in: text, options: [], range: NSMakeRange(0, text.utf16.count))
    }
}

class IndonesianLanguageHelper : LanguageHelper {
    
    var substitutions: [String: String] {
        return [
            "...": "titik titik titik"
        ]
    }
    
    private let finalWords = Set([
        "aku",
        "ilmu",
        "ilmu",
        "kamu",
        "tamu",
        "temu",
        "dia",
        "bukan",
        "ini",
        "sekali"
    ])
    
    private let simpleSuffix = try! RegularExpression(pattern: "^(.{2,})(?:nya|ku|kau|mu|[klt]ah|pun)$", options: [])
    private let kuMuKauPrefix = try! RegularExpression(pattern: "^(?:ku|mu|kau)(.{2,})$", options: [])
    private let diPrefix = try! RegularExpression(pattern: "^(?:di)(.{2,})$", options: [])
//    private let lahPunSuffix = try! RegularExpression(pattern: "^(.{2,})(?:[klt]ah|pun)$", options: [])
    private let terPrefix = try! RegularExpression(pattern: "^(?:ter)(.{2,})$", options: [])
    private let kanISuffix = try! RegularExpression(pattern: "^[^m].{2,}(kan|i)$", options: [])
    private let sePrefix = try! RegularExpression(pattern: "^(?:se)(.{2,})$", options: [])
    private let perPrefix = try! RegularExpression(pattern: "^per|pelajar", options: [])
    private let duplication = try! RegularExpression(pattern: "^(.{2,})(?:-.{2,})$", options: [])
    private let beginVowels = try! RegularExpression(pattern: "^[aeiou]", options: [])
    private let beginBF = try! RegularExpression(pattern: "^[bf]", options: [])
    private let beginP = try! RegularExpression(pattern: "^p", options: [])
    private let beginDTCJSyZ = try! RegularExpression(pattern: "^(?:d|t|c|j|sy|z)", options: [])
    private let beginT = try! RegularExpression(pattern: "^t", options: [])
    private let beginS = try! RegularExpression(pattern: "^s", options: [])
    private let beginGHKKh = try! RegularExpression(pattern: "^(?:g|h|k|kh)", options: [])
    private let beginK = try! RegularExpression(pattern: "^k[^h]", options: [])
    private let beginLRMNNyNgWY = try! RegularExpression(pattern: "^(?:l|r|m|n|ny|ng|w|y)", options: [])
    
    func getWordVariations(for word: String) -> [String] {
        var variations = [String]()
        getVariations(for: word, variations: &variations, isMeNPrefixApplied: false)
        return variations
    }
    
    private func getVariations(for word: String, variations: inout [String], isMeNPrefixApplied: Bool) {
        
        var isMeNPrefixed = isMeNPrefixApplied;
        
        if !variations.contains(word) {
            variations.append(word)
        }
        
        if finalWords.contains(word) {
            return;
        }
        
        if let match = simpleSuffix.firstMatch(in: word) {
            let variation = word.substring(with: match.range(at: 1))
            getVariations(for: variation, variations: &variations, isMeNPrefixApplied: isMeNPrefixed)
        }
        
        if let match = kuMuKauPrefix.firstMatch(in: word) {
            let variation = word.substring(with: match.range(at: 1))
            getVariations(for: variation, variations: &variations, isMeNPrefixApplied: isMeNPrefixed)
        }
        
        if let match = duplication.firstMatch(in: word) {
            let variation = word.substring(with: match.range(at: 1))
            getVariations(for: variation, variations: &variations, isMeNPrefixApplied: isMeNPrefixed)
        }
        
        if let match = diPrefix.firstMatch(in: word) {
            let variation = word.substring(with: match.range(at: 1))
            if !isMeNPrefixed {
                let meNWord = prefixWithMeN(variation)
                isMeNPrefixed = true
                if (meNWord != variation) {
                    getVariations(for: meNWord, variations: &variations, isMeNPrefixApplied: isMeNPrefixed)
                }
            }
            if perPrefix.firstMatch(in: variation) != nil {
                getVariations(for: "mem" + variation, variations: &variations, isMeNPrefixApplied: isMeNPrefixed)
            }
        }
        
        if let match = terPrefix.firstMatch(in: word) {
            let variation = word.substring(with: match.range(at: 1))
            getVariations(for: variation, variations: &variations, isMeNPrefixApplied: isMeNPrefixed)
        }
        
        if kanISuffix.firstMatch(in: word) != nil && !isMeNPrefixed {
            let meNWord = prefixWithMeN(word)
            isMeNPrefixed = true
            if meNWord != word {
                getVariations(for: meNWord, variations: &variations, isMeNPrefixApplied: isMeNPrefixed)
            }
        }
        
        if let match = sePrefix.firstMatch(in: word) {
            let variation = word.substring(with: match.range(at: 1))
            getVariations(for: variation, variations: &variations, isMeNPrefixApplied: isMeNPrefixed)
        }
        
        if perPrefix.firstMatch(in: word) != nil && !isMeNPrefixed {
            isMeNPrefixed = true
            getVariations(for: "mem" + word, variations: &variations, isMeNPrefixApplied: isMeNPrefixed)
        }
    }
    
    private func prefixWithMeN(_ word: String) -> String {
        var word = word
        if beginVowels.firstMatch(in: word) != nil {
            word = "meng" + word
        } else if beginBF.firstMatch(in: word) != nil{
            word = "mem" + word
        } else if beginP.firstMatch(in: word) != nil {
            // initial p is lost
            if perPrefix.firstMatch(in: word) == nil {
                word = word.substring(from: 1)
            }
            word = "mem" + word
        } else if beginDTCJSyZ.firstMatch(in: word) != nil {
            // initial t is lost
            if beginT.firstMatch(in: word) != nil {
                word = word.substring(from: 1)
            }
            word = "men" + word
        } else if beginS.firstMatch(in: word) != nil {
            // initial s is lost
            word = "meny" + word.substring(from: 1)
        } else if beginGHKKh.firstMatch(in: word) != nil {
            // initial k is lost
            if beginK.firstMatch(in: word) != nil {
                word = word.substring(from: 1)
            }
            word = "meng" + word
        } else if beginLRMNNyNgWY.firstMatch(in: word) != nil {
            word = "me" + word
        }
        return word
    }
}
