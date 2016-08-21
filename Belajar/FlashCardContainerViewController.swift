//
//  FlashCardViewController.swift
//  Belajar
//
//  Created by Jim Cramer on 15/08/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit

private var muteVoice = true

class FlashCardContainerViewController: UIViewController {
    
    var fileName: String!
    var flashCards: [FlashCard]!
    
    private var flashCardIndexKey: String {
        return fileName + ".flashCardIndex"
    }
    
    private var defaultPageNumber: Int {
        return UserDefaults.standard.integer(forKey: flashCardIndexKey)
    }
    
    private var flashCardPageViewController: FlashCardPageViewController?
    fileprivate var pageNumber = 0
    
    @IBOutlet weak private var dashboardView: UIView!
    @IBOutlet weak fileprivate var sectionTitleLabel: UILabel!
    @IBOutlet weak fileprivate var flashCardSlider: UISlider!
    @IBOutlet weak fileprivate var flashCardCountLabel: UILabel!
    @IBOutlet weak private var containerView: UIView!
    @IBOutlet weak private var muteButton: UIBarButtonItem!

    private struct Storyboard {
        static let embedFlashCardPageViewController = "embedFlashCardPageViewController"
    }
    
    private struct AssetCatalog {
        static let mute = "Mute"
        static let volumeUp = "Volume Up"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UserDefaults.standard.register(defaults: [flashCardIndexKey: 0])
        pageNumber = defaultPageNumber

        flashCardSlider.minimumValue = 0.0
        flashCardSlider.maximumValue = Float(flashCards.count * 2 - 1)
        flashCardSlider.value = Float(pageNumber)
        updateMuteButtonImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SpeechService.sharedInstance.stopSpeaking()
        UserDefaults.standard.set(pageNumber, forKey: flashCardIndexKey)
    }
    
    @IBAction func flashCardSliderValueChanged(_ sender: UISlider) {
        flashCardPageViewController?.setCurrentPage(pageNumber: Int(sender.value))
    }
    
    @IBAction func muteButtonTapped(_ sender: UIBarButtonItem) {
        muteVoice = !muteVoice
        if (muteVoice) {
            SpeechService.sharedInstance.stopSpeaking()
        } else {
            speakText(forPageNumber: pageNumber)
        }
        updateMuteButtonImage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
            
        case Storyboard.embedFlashCardPageViewController:
            flashCardPageViewController = segue.destination.contentViewController as? FlashCardPageViewController
            flashCardPageViewController?.flashCards = flashCards
            flashCardPageViewController?.flashCardDelegate = self
            flashCardPageViewController?.setCurrentPage(pageNumber: defaultPageNumber)
            speakText(forPageNumber: defaultPageNumber)
            
        default: break
        }
    }
    
    private func updateMuteButtonImage() {
        let imageName = muteVoice ? AssetCatalog.mute : AssetCatalog.volumeUp
        muteButton.image = UIImage(named: imageName)
    }
}

extension FlashCardContainerViewController: FlashCardPageViewControllerDelegate {
    
    func flashCardPageNumber(changedTo pageNumber: Int) {
        self.pageNumber = pageNumber
        if pageNumber != Int(flashCardSlider.value) {
            flashCardSlider.value = Float(pageNumber)
        }
        let sectionTitle = flashCards[pageNumber / 2].sectionTitle
        sectionTitleLabel.attributedText = AttributedStringHelper.makeAttributedText(from: sectionTitle as NSString, useSmallFont: true)
        flashCardCountLabel.text = "\(pageNumber / 2 + 1)/\(flashCards.count)"
    }
    
    func speakText(forPageNumber pageNumber: Int) {
        guard !muteVoice else { return }
        let voice = pageNumber % 2 == 0 ? SpeechVoiceLanguage.foreign : .native
        let flashCard = flashCards[pageNumber / 2]
        let text = pageNumber % 2 == 0 ? flashCard.phrase : flashCard.translation
        SpeechService.sharedInstance.speak(phrase: text, voice: voice)
    }
}
