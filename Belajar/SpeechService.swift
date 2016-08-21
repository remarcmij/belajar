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

enum SpeechVoiceLanguage {
    case foreign, native
}

class SpeechService: NSObject {
    
    static let sharedInstance = SpeechService()
    static let minimumValue: Float = 0.25
    static let maximumValue: Float = 0.5

    private let speechSynthesizer: AVSpeechSynthesizer

    override init() {
        speechSynthesizer = AVSpeechSynthesizer()
        super.init()
        speechSynthesizer.delegate = self
    }
    
    var speechRate: Float = SpeechService.maximumValue {
        didSet {
            if speechRate != oldValue {
                stopSpeaking()
            }
        }
    }
    
    func stopSpeaking() {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
    }
    
    func speak(text: String, voice: SpeechVoiceLanguage = .foreign) {
        stopSpeaking()
        
        let partionedText = endOfSentenceRegExp.stringByReplacingMatches(in: text, options: [], range: NSMakeRange(0, text.utf16.count), withTemplate: "$1|")
        let sentences = partionedText.components(separatedBy: "|")
        
        for sentence in sentences {
            speak(phrase: sentence, voice: voice, rate: speechRate)
        }
    }
    
    func speak(phrase: String,  voice: SpeechVoiceLanguage = .foreign, rate: Float = maximumValue) {
        let utterance = AVSpeechUtterance(string: phrase)
        utterance.voice = AVSpeechSynthesisVoice(language: voice == .foreign ? Constants.foreignBCP47 : Constants.nativeBCP47)
        utterance.rate = rate
        speechSynthesizer.speak(utterance)
    }
}

extension SpeechService: AVSpeechSynthesizerDelegate {
    
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
//        print("finished \(utterance.speechString)")
//    }
//    
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
//        print("cancelled \(utterance.speechString)")
//    }
//    
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
//        print("willSpeak \((utterance.speechString as NSString).substring(with: characterRange))")
//    }
//    
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
//        print("didStart \(utterance.speechString)")
//    }
//    
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
//        print("didPause")
//    }
}
