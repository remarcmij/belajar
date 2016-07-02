//
//  LanguageHelper.swift
//  Belajar
//
//  Created by Jim Cramer on 30/06/16.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import Foundation

protocol LanguageHelper {
    static func getFor(lang: String) -> LanguageHelper
    var substitutions: [String: String] {get}
    func encodeForSpeech(text: String) -> String
    func getWordVariations(for word: String) -> [String]
}

extension LanguageHelper {
    static func getFor(lang: String) -> LanguageHelper {
        return DutchLanguageHelper()
    }
    
    func encodeForSpeech(text: String) -> String {
        let lexer = SpeechTextLexer(targetText: text)
        let buffer = NSMutableString()
        
        var (tokenType, tokenText) = lexer.nextToken()
        
        while tokenType != .endOfText {
            switch tokenType {
                
            case .word, .abbreviation, .ellipsis:
                if let replacement = substitutions[text] {
                    buffer.append(replacement)
                } else {
                    buffer.append(tokenText)
                }
                
            case .comma, .semiColon, .colon, .endOfSentence:
                buffer.append(tokenText)
                buffer.append("|")
                
            default:
                buffer.append(tokenText)
            }
            
            (tokenType, tokenText) = lexer.nextToken()
        }
        
        return buffer as String
    }
    
    func getWordVariations(for word: String) -> [String] {
        return [word]
    }
}
