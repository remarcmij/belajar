//
//  DictionaryPopoverDelegate.swift
//  Belajar
//
//  Created by Jim Cramer on 12/07/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit

protocol DictionaryPopoverPresenter {
    func lookup(word: String, lang: String)
}

class DictionaryPopoverDelegate: NSObject {
    private weak var presenter: UIViewController?
    private var resolvedWord: String?
    
    init(presenter: UIViewController) {
        assert((presenter as? DictionaryPopoverPresenter) != nil,
               "presenter should conform to DictionaryPopoverPresenter protocol")
        self.presenter = presenter;
        presenter.definesPresentationContext = true
        super.init()
    }
    
    func wordClickPopover(word: String) {
        let normalisedWord = word.folding(options: .diacriticInsensitive, locale: Locale.current)
            .lowercased()
        
        if let controller = presenter,
            let (lemmas, variation) = DictionaryStore.sharedInstance.lookupWord(word: normalisedWord) {
            resolvedWord = variation
            let synopsis = Lemma.makeSynopsis(lemmas: lemmas)
            
            let title = resolvedWord! == lemmas[0].base ? resolvedWord! : resolvedWord! + " → " + lemmas[0].base
            let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
            let attributedString = AttributedStringHelper.makeAttributedText(from: synopsis, clickAction: nil, useSmallFont: true)
            
            alert.setValue(attributedString, forKey: "attributedMessage")
            alert.addAction(UIAlertAction(title: "more...", style: .default, handler: {[weak weakSelf = self] action in
                (weakSelf!.presenter as! DictionaryPopoverPresenter).lookup(word: weakSelf!.resolvedWord!, lang: Constants.ForeignLang)
//                    DispatchQueue.main.async() { _ in
//                        NotificationCenter.default.post(name: Constants.WordLookupNotification,
//                                                        object: weakSelf.presenter,
//                                                        userInfo: ["word": weakSelf.resolvedWord!])
//                    }

//                }
                }))
            alert.addAction(UIAlertAction(title: "say", style: .default, handler: {  _ in print("cancelled") }))
            
            alert.view.isUserInteractionEnabled = true
            alert.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertViewTapped(sender:))))
            
            controller.present(alert, animated: false, completion: {
                alert.view.superview?.isUserInteractionEnabled = true
                alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertViewBackgroundTapped(sender:))))
            })
        }
    }
    
    func wordClickPopover2(word: String) {
        
        let normalisedWord = word.folding(options: .diacriticInsensitive, locale: Locale.current)
            .lowercased()
        
        if let controller = presenter,
            let (_, variation) = DictionaryStore.sharedInstance.lookupWord(word: normalisedWord) {
            resolvedWord = variation
            
            let popoverController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DictPopover") as! DictionaryPopoverController
            controller.present(popoverController, animated: true, completion: {
                if let superview = popoverController.view.superview {
                    superview.isUserInteractionEnabled = true
                    superview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertViewBackgroundTapped)))
                }
            })
        }
    }
    
    func alertViewTapped(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            print("alert window tapped")
        }
    }
    
    func alertViewBackgroundTapped(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            print("background clicked")
            presenter?.dismiss(animated: false, completion: nil)
        }
    }
}
