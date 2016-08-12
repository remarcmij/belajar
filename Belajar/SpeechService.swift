//
//  SpeechService.swift
//  Belajar
//
//  Created by Jim Cramer on 09/08/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import Foundation
import AVFoundation
private var rate: Float = 0.5

private let endOfSentenceRegExp = try! NSRegularExpression(pattern: "([.?!])(?=\\s+(:?\\p{Lu}|['\"‘“]))", options: [])

class SpeechService: NSObject {
    
    static let sharedInstance = SpeechService()
    static let minimumValue: Float = 0.25
    static let maximumValue: Float = 0.5
    
    var speechRate: Float = SpeechService.maximumValue {
        didSet {
            if speechRate != oldValue {
                speechSynthesizer.stopSpeaking(at: .immediate)
            }
        }
    }
    
    private lazy var speechSynthesizer = AVSpeechSynthesizer()

    func stopSpeaking() {
        speechSynthesizer.stopSpeaking(at: .word)
    }
    
    func speak(text: String) {
        if speechSynthesizer.isSpeaking {
            stopSpeaking()
        }
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

extension SpeechService: AVSpeechSynthesizerDelegate {
}
