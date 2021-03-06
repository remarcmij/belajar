//
//  DictionaryPopoverDelegate.swift
//  Belajar
//
//  Created by Jim Cramer on 12/07/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit

protocol DictionaryPopoverServiceDelegate {
    func lookup(word: String, lang: String)
    var showSpeakOnTapOption: Bool { get }
    func enableSpeakOnTap()
}

extension DictionaryPopoverServiceDelegate {
    var showSpeakOnTapOption: Bool { return false }
    func enableSpeakOnTap() { }
}

private let parenthesizedSnippetRegExp = try! NSRegularExpression(pattern: "\\((.*?)\\)", options: [])
private let anyParensRegExp = try! NSRegularExpression(pattern: "[()]", options: [])

class DictionaryPopoverService: NSObject {
    
    private weak var viewController: UIViewController?
    
    init(controller: UIViewController) {
        assert((controller as? DictionaryPopoverServiceDelegate) != nil,
               "presenter should conform to DictionaryPopoverPresenter protocol")
        self.viewController = controller;
        controller.definesPresentationContext = true
        super.init()
    }
    
    func wordClickPopover(word: String, sourceView: UIView) {
        var normalisedWord = parenthesizedSnippetRegExp.stringByReplacingMatches(in: word, options: [], range: NSMakeRange(0, word.utf16.count), withTemplate: "")
        normalisedWord = anyParensRegExp.stringByReplacingMatches(in: normalisedWord, options: [], range: NSMakeRange(0, normalisedWord.utf16.count), withTemplate: "")
        normalisedWord = normalisedWord.folding(options: .diacriticInsensitive, locale: Locale.current).lowercased()
        
        var resolvedWord: String?
        
        if let controller = viewController {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.modalPresentationStyle = .popover
            
            if let ppc = alert.popoverPresentationController {
                ppc.permittedArrowDirections = []
                ppc.sourceView = sourceView
                ppc.sourceRect = sourceView.bounds
            }
            
            let message: String
            if let (lemmas, variation) = DictionaryStore.sharedInstance.lookupWord(word: normalisedWord) {
                resolvedWord = variation
                message = "**\(lemmas[0].base.uppercased())**\n" + Lemma.makeSynopsis(lemmas: lemmas)
            } else {
                message = NSLocalizedString("Nothing found in dictionary", comment: "Feedback to user in word-click popover if nothing found")
            }
            let attributedLemmaText = AttributedStringHelper.makeAttributedText(from: message as NSString, clickAction: nil, useSmallFont: true)
            alert.setValue(attributedLemmaText, forKey: "attributedMessage")
            
            if resolvedWord != nil {
                let dictionaryActionTitle = String(format: NSLocalizedString("Lookup: %@", comment: "Alert action title in word-click popover"), resolvedWord!)
                let dictionaryAction = UIAlertAction(title: dictionaryActionTitle, style: .default) {[weak self] action in
                    (self!.viewController as! DictionaryPopoverServiceDelegate).lookup(word: resolvedWord!, lang: Constants.ForeignLang)
                }
                alert.addAction(dictionaryAction)
            }
            
            let sayActionTitle = String(format: NSLocalizedString("Say: %@", comment: "Alert action title in word-click popover"), word.lowercased())
            let sayAction = UIAlertAction(title: sayActionTitle, style: .default) { _ in
                let cleansedWord = parenthesizedSnippetRegExp.stringByReplacingMatches(in: word, options: [], range: NSMakeRange(0, word.utf16.count), withTemplate: "$1")
                SpeechService.sharedInstance.speak(phrase: cleansedWord)
            }
            alert.addAction(sayAction)
            
            if (viewController as! DictionaryPopoverServiceDelegate).showSpeakOnTapOption {
                let speakOnTapActionTitle = NSLocalizedString("Enable Speech Mode", comment: "Alert action title in word-click popover")
                let speakOnTapAction = UIAlertAction(title: speakOnTapActionTitle, style: .default) {[weak self] action in
                    (self!.viewController as! DictionaryPopoverServiceDelegate).enableSpeakOnTap()
                }
                alert.addAction(speakOnTapAction)
            }
            
            let cancelActionTitle = NSLocalizedString("Cancel", comment: "Alert action title in word-click popover")
            let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel)
            alert.addAction(cancelAction)
            
            controller.present(alert, animated: true, completion: nil)
            alert.view.layoutIfNeeded() //avoid Snapshotting error
        }
    }
   
}

