//
//  DictionaryPopoverDelegate.swift
//  Belajar
//
//  Created by Jim Cramer on 12/07/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit
import AVFoundation

protocol DictionaryPopoverDelegate {
    func lookup(word: String, lang: String)
}

class DictionaryPopoverService: NSObject {
    private weak var viewController: UIViewController?
    private var resolvedWord: String?
    private let talker = AVSpeechSynthesizer()
    
    init(controller: UIViewController) {
        assert((controller as? DictionaryPopoverDelegate) != nil,
               "presenter should conform to DictionaryPopoverPresenter protocol")
        self.viewController = controller;
        controller.definesPresentationContext = true
        super.init()
    }
    
    func wordClickPopover(word: String, sourceView: UIView) {
        let normalisedWord = word.folding(options: .diacriticInsensitive, locale: Locale.current)
            .lowercased()
        
        if let controller = viewController,
            let (lemmas, variation) = DictionaryStore.sharedInstance.lookupWord(word: normalisedWord) {
            resolvedWord = variation
            
            let lemmaText = Lemma.makeSynopsis(lemmas: lemmas) + "\n→ **\(lemmas[0].base)**"
            let useSmallFont =  controller.traitCollection.userInterfaceIdiom == .phone
            let attributedLemmaText = AttributedStringHelper.makeAttributedText(from: lemmaText, clickAction: nil, useSmallFont: useSmallFont)
            
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.modalPresentationStyle = .popover
            if let ppc = alert.popoverPresentationController {
                ppc.permittedArrowDirections = []
                ppc.sourceView = sourceView
                ppc.sourceRect = sourceView.bounds
                print(controller.view.bounds)
            }
            alert.setValue(attributedLemmaText, forKey: "attributedMessage")
            
//            let pronounceActionTitle = NSLocalizedString("Pronounce", comment: "Word-click popover")
            let pronounceAction = UIAlertAction(title: "🗣 \(word)", style: .default) { [weak self] _ in
                self?.speak(word: word)
            }
            alert.addAction(pronounceAction)
            
            let dictionaryActionTitle = NSLocalizedString("Find in Dictionary", comment: "Word-click popover")
            let dictionaryAction = UIAlertAction(title: dictionaryActionTitle, style: .default) {[weak self] action in
                (self!.viewController as! DictionaryPopoverDelegate).lookup(word: self!.resolvedWord!, lang: Constants.ForeignLang)
            }
            alert.addAction(dictionaryAction)
            
            let cancelActionTitle = NSLocalizedString("Done", comment: "Word-click popover")
            let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel)
            alert.addAction(cancelAction)
            
            controller.present(alert, animated: true, completion: nil)
        }
    }
    
    private func speak(word: String) {
        let utterance = AVSpeechUtterance(string: word)
        utterance.voice = AVSpeechSynthesisVoice(language: "id-ID")
        talker.delegate = self
        talker.speak(utterance)
    }
}

extension DictionaryPopoverService: AVSpeechSynthesizerDelegate {
    
}
