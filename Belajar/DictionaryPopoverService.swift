//
//  DictionaryPopoverDelegate.swift
//  Belajar
//
//  Created by Jim Cramer on 12/07/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit

protocol DictionaryPopoverDelegate {
    func lookup(word: String, lang: String)
}

private let parenthesizedSnippetRegExp = try! NSRegularExpression(pattern: "\\((.*?)\\)", options: [])
private let anyParensRegExp = try! NSRegularExpression(pattern: "[()]", options: [])

class DictionaryPopoverService: NSObject {
    private weak var viewController: UIViewController?
    
    init(controller: UIViewController) {
        assert((controller as? DictionaryPopoverDelegate) != nil,
               "presenter should conform to DictionaryPopoverPresenter protocol")
        self.viewController = controller;
        controller.definesPresentationContext = true
        super.init()
    }
    
    func wordClickPopover(word: String, sourceView: UIView) {
        var normalisedWord = parenthesizedSnippetRegExp.stringByReplacingMatches(in: word, options: [], range: NSMakeRange(0, word.utf16.count), withTemplate: "")
        normalisedWord = parenthesizedSnippetRegExp.stringByReplacingMatches(in: normalisedWord, options: [], range: NSMakeRange(0, normalisedWord.utf16.count), withTemplate: "")
        normalisedWord = normalisedWord.folding(options: .diacriticInsensitive, locale: Locale.current)
            .lowercased()
        
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
                message = Lemma.makeSynopsis(lemmas: lemmas) + "\n→ **\(lemmas[0].base)**"
            } else {
                message = NSLocalizedString("Nothing found in dictionary", comment: "wordClick popover")
            }
            let useSmallFont =  controller.traitCollection.userInterfaceIdiom == .phone
            let attributedLemmaText = AttributedStringHelper.makeAttributedText(from: message, clickAction: nil, useSmallFont: useSmallFont)
            alert.setValue(attributedLemmaText, forKey: "attributedMessage")
            
            let pronounceAction = UIAlertAction(title: "🗣 \(word)", style: .default) { _ in
                let cleansedWord = parenthesizedSnippetRegExp.stringByReplacingMatches(in: word, options: [], range: NSMakeRange(0, word.utf16.count), withTemplate: "$1")
                SpeechService.sharedInstance.speak(text: cleansedWord)
            }
            alert.addAction(pronounceAction)
            
            if resolvedWord != nil {
                let dictionaryActionTitle = NSLocalizedString("Find in Dictionary", comment: "Word-click popover")
                let dictionaryAction = UIAlertAction(title: dictionaryActionTitle, style: .default) {[weak self] action in
                    (self!.viewController as! DictionaryPopoverDelegate).lookup(word: resolvedWord!, lang: Constants.ForeignLang)
                }
                alert.addAction(dictionaryAction)
            }
            
            let cancelActionTitle = NSLocalizedString("Done", comment: "Word-click popover")
            let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel)
            alert.addAction(cancelAction)
            
            controller.present(alert, animated: true, completion: nil)
            alert.view.layoutIfNeeded() //avoid Snapshotting error
        }
    }
   
}

