//
//  SpeechService.swift
//  Belajar
//
//  Created by Jim Cramer on 09/08/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import Foundation
import AVFoundation

private let endOfSentenceRegExp = try! NSRegularExpression(pattern: "([.?!])(?=\\s+(:?\\p{Lu}|['\"‘“]))", options: [])

class SpeechService: NSObject, AVSpeechSynthesizerDelegate {
    
    static let sharedInstance = SpeechService()
    
    var speechRate: Float = 0.5
    
    private let speechSynthesizer = AVSpeechSynthesizer()

    func stopSpeaking() {
        speechSynthesizer.stopSpeaking(at: .immediate)
    }
    
    func speak(text: String) {
        let partionedText = endOfSentenceRegExp.stringByReplacingMatches(in: text, options: [], range: NSMakeRange(0, text.utf16.count), withTemplate: "$1|")
        let sentences = partionedText.components(separatedBy: "|")
        
        var first = true
        for sentence in sentences {
            speakSentence(text: sentence, preUtteranceDelay: first ? 0.0 : 0.3)
            first = false
        }
    }
    
    private func speakSentence(text: String, preUtteranceDelay: Double) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: Constants.foreignBCP47)
        utterance.rate = speechRate
        utterance.preUtteranceDelay = preUtteranceDelay
        speechSynthesizer.delegate = self
        speechSynthesizer.speak(utterance)
    }
}
