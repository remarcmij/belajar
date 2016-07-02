//
//  SpeechTextLexer.swift
//  Belajar
//
//  Created by Jim Cramer on 30/06/16.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import Foundation

enum TokenType {
    case word
    case abbreviation
    case number
    case ellipsis
    case comma
    case semiColon
    case colon
    case whiteSpace
    case endOfSentence
    case other
    case endOfText
}

class SpeechTextLexer {
    private static let wordRegExp = try! RegularExpression(pattern: "^([-'\\p{L}]{2,})", options: [])
    private static let abbreviationRegExp = try! RegularExpression(pattern: "^(\\p{L}[.\\p{L}]*\\.)(?!\\s+\\p{Lu}|$)", options: [])
    private static let numberRegExp = try! RegularExpression(pattern: "^(\\.?\\d[.\\d]*)", options: [])
    private static let ellipsisRegExp = try! RegularExpression(pattern: "^(\\.{3})", options: [])
    private static let commaRegExp = try! RegularExpression(pattern: "^(,)", options: [])
    private static let semicolonRegExp = try! RegularExpression(pattern: "^(;)", options: [])
    private static let colonRegExp = try! RegularExpression(pattern: "^(:)", options: [])
    private static let whiteSpaceRegExp = try! RegularExpression(pattern: "^(\\s+)", options: [])
    private static let endOfSentenceRegExp = try! RegularExpression(pattern: "^([.?!])(?=\\s+\\p{Lu}|$)", options: [])
    private static let otherRegExp = try! RegularExpression(pattern: "^(.)", options: [])

    private static let tokenMatchers: [(TokenType, RegularExpression)] = [
        (.word, SpeechTextLexer.wordRegExp),
        (.abbreviation, SpeechTextLexer.abbreviationRegExp),
        (.number, SpeechTextLexer.numberRegExp),
        (.ellipsis, SpeechTextLexer.ellipsisRegExp),
        (.comma, SpeechTextLexer.commaRegExp),
        (.semiColon, SpeechTextLexer.semicolonRegExp),
        (.colon, SpeechTextLexer.colonRegExp),
        (.whiteSpace, SpeechTextLexer.whiteSpaceRegExp),
        (.endOfSentence, SpeechTextLexer.endOfSentenceRegExp),
        (.other, SpeechTextLexer.otherRegExp)
    ]
    
    private var targetText: NSString
    
    init(targetText: String) {
        self.targetText = targetText
    }
    
    func nextToken() -> (TokenType, String) {
        if targetText.length == 0 {
            return (.endOfText, "")
        }
        
        for (tokenType, regExp) in self.dynamicType.tokenMatchers {
            if  let checkingResult = regExp.firstMatch(in: targetText as String, options: [], range: NSMakeRange(0, targetText.length)) {
                let range = checkingResult.range(at: 1)
                let tokenText = targetText.substring(with: range) as String
                targetText = targetText.substring(from: range.location)
                return (tokenType, tokenText)
            }
        }
        
        fatalError("unexpected error")
    }
}
