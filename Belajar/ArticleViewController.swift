//
//  ArticleViewController.swift
//  Belajar
//
//  Created by Jim Cramer on 15/06/16.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit
import WebKit

private let smallestScreenWidth: CGFloat = 320
private var sharedSpeakOnTapIsOn = false

class ArticleViewController: UIViewController, WKScriptMessageHandler {
    
    @IBOutlet weak private var tableOfContentsButton: UIBarButtonItem!
    @IBOutlet weak var toolbarCloseButton: UIBarButtonItem!
    
    private struct Storyboard {
        static let showDictionary = "showDictionary"
        static let showMenu = "showMenu"
        static let showSpeechRatePopover = "showSpeechRatePopover"
    }
    
    private var webView: WKWebView!
    private var resolvedWord: String?
    private var dictionaryPopoverService: DictionaryPopoverService?
    private var clickedText: String?
    
    var speakOnTapIsOn = sharedSpeakOnTapIsOn {
        didSet {
            if !speakOnTapIsOn {
                SpeechService.sharedInstance.stopSpeaking()
            } else if clickedText != nil {
                SpeechService.sharedInstance.speak(text: clickedText!)
            }
            navigationController?.setToolbarHidden(!speakOnTapIsOn, animated: false)
        }
    }
    
    private var styleSheet: String {
        return "body {font-size: \(PreferredFont.get(type: .body).pointSize)px;}"
    }
    
    var topic: Topic! {
        didSet {
            _ = navigationController?.popToRootViewController(animated: true)
            if topic == nil {
                tableOfContentsButton.isEnabled = false
            } else {
                tableOfContentsButton.isEnabled = true
                navigationItem.title = topic.title
                article = TopicStore.sharedInstance.getArticle(withTopicId: topic.id)
                loadHTML()
            }
        }
    }
    
    private struct RestorationIdentifier {
        static let topic = "topic"
    }
    
    private var article: Article?
    
    private static let htmlTemplate: String = {
        let indexURL = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "www")!
        return try! String(contentsOf: indexURL, encoding: String.Encoding.utf8)
    }()
    
    private static let folderURL: URL = {
        return Bundle.main.url(forResource: "www", withExtension: nil)!
    }()
    
    override func awakeFromNib() {
        webView = WKWebView()
        view.addSubview(webView)
        webView.configuration.userContentController.add(MyMessageHandler(delegate: self), name: "wordClick");
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        let height = NSLayoutConstraint(item: webView, attribute: .height, relatedBy: .equal,
                                        toItem: view, attribute: .height, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: webView, attribute: .width, relatedBy: .equal,
                                       toItem: view, attribute: .width, multiplier: 1, constant: 0)
        view.addConstraints([height, width])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        speakOnTapIsOn = sharedSpeakOnTapIsOn
        navigationController?.setToolbarHidden(!speakOnTapIsOn, animated: false)
        
        dictionaryPopoverService = DictionaryPopoverService(controller: self)
        tableOfContentsButton.isEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(onContentSizeChanged),
                                               name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SpeechService.sharedInstance.stopSpeaking()
    }
    
    override func viewDidDisappear(_ animated: Bool)  {
        super.viewDidDisappear(animated)
        sharedSpeakOnTapIsOn = speakOnTapIsOn
        NotificationCenter.default.removeObserver(self)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        func handler(_ action: UIAlertAction) {
            print("user tapped \(action.title)")
        }
        
        if message.name == "wordClick" {
            let components = (message.body as! String).components(separatedBy: "|")
            let clickedWord = components[0]
            clickedText = components[1]
            print("Javascript clickedWord: \(clickedWord) clickedText: \(clickedText)")
            
            if speakOnTapIsOn {
                SpeechService.sharedInstance.speak(text: clickedText!)
            } else {
                dictionaryPopoverService?.wordClickPopover(word: clickedWord, sourceView: webView)
            }
        } else {
            print("something else called")
        }
    }
    
    private func alertControllerBackgroundTapped()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else { return }
        
        SpeechService.sharedInstance.stopSpeaking()
        
        switch identifier {
            
        case Storyboard.showDictionary:
            if let dictionaryController = segue.destination.contentViewController as? DictionaryViewController {
                dictionaryController.word = resolvedWord
                dictionaryController.lang = Constants.ForeignLang
                resolvedWord = nil
            }
            
        case Storyboard.showMenu:
            // note: menu controller embedded in a navigation controller to prevent it being presented underneath the
            // status bar on an iPhone
            if let menuController = segue.destination.contentViewController as? ArticleMenuPageViewController {
                segue.destination.popoverPresentationController?.barButtonItem = tableOfContentsButton
                menuController.menuDelegate = self
                menuController.article = article
            }
            
        case Storyboard.showSpeechRatePopover:
            // see Programming iOS 9, p519             
            let popoverViewController = segue.destination
            popoverViewController.modalPresentationStyle = .popover
            popoverViewController.popoverPresentationController!.delegate = self
            
        default: break
        }
    }
    
    
    // intermediate class to minimise memory leaks
    class MyMessageHandler: NSObject,  WKScriptMessageHandler {
        private weak var delegate: WKScriptMessageHandler?
        
        init(delegate: WKScriptMessageHandler) {
            self.delegate = delegate
            super.init()
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            delegate?.userContentController(userContentController, didReceive: message)
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
        speakOnTapIsOn = false
        //        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    @IBAction func speechRateSliderValueChanged(_ sender: UISlider) {
        SpeechService.sharedInstance.speechRate = sender.value
    }
    
    // MARK: - Restoration
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        coder.encode(topic, forKey: RestorationIdentifier.topic)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        topic = coder.decodeObject(forKey: RestorationIdentifier.topic) as? Topic
    }
    
    // MARK: - helper functions
    
    func onContentSizeChanged() {
        loadHTML()
    }
    
    func loadHTML() {
        SpeechService.sharedInstance.stopSpeaking()
        if let htmlText = article?.htmlText {
            var htmlDoc = self.dynamicType.htmlTemplate.replacingOccurrences(of: "<!-- style -->", with: styleSheet)
            htmlDoc = htmlDoc.replacingOccurrences(of: "<!-- article -->", with: htmlText)
            webView.loadHTMLString(htmlDoc, baseURL: self.dynamicType.folderURL)
        }
    }
}

extension ArticleViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension ArticleViewController: DictionaryPopoverServiceDelegate {
    
    func lookup(word: String, lang: String) {
        resolvedWord = word
        performSegue(withIdentifier: Storyboard.showDictionary, sender: self)
    }
    
    func enableSpeakOnTap() {
        speakOnTapIsOn = true
    }
    
    var showSpeakOnTapOption: Bool { return true }
}

extension ArticleViewController: ArticleMenuPageViewControllerDelegate {
    func scrollToAnchor(anchor: String) {
        dismiss(animated: true, completion: nil)
        webView.evaluateJavaScript("scrollToAnchor('\(anchor)')", completionHandler: nil)
    }
}
