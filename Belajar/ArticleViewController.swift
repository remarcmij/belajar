//
//  ArticleViewController.swift
//  Belajar
//
//  Created by Jim Cramer on 15/06/16.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit
import WebKit



class ArticleViewController: UIViewController, WKScriptMessageHandler, DictionaryPopoverPresenter {
    
    @IBOutlet weak private var tableOfContentsButton: UIBarButtonItem!
    
    private struct Storyboard {
        static let showDictionary = "showDictionary"
        static let showTableOfContents = "showTableOfContents"
    }
    
    private var webView: WKWebView!
    private var resolvedWord: String?
    private var clickedText: String?
    private var dictionaryPopoverDelegate: DictionaryPopoverDelegate?
    
    private var styleSheet: String {
        return "body {font-size: \(PreferredFont.get(type: .body).pointSize)px;}"
    }
    
    var topic: Topic! {
        didSet {
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
        let indexURL = Bundle.main.urlForResource("index", withExtension: "html", subdirectory: "www")!
        return try! String(contentsOf: indexURL, encoding: String.Encoding.utf8)
    }()
    
    private static let folderURL: URL = {
        return Bundle.main.urlForResource("www", withExtension: nil)!
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
        dictionaryPopoverDelegate = DictionaryPopoverDelegate(presenter: self)
        tableOfContentsButton.isEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(onContentSizeChanged),
                                               name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool)  {
        super.viewDidDisappear(animated)
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
            
            dictionaryPopoverDelegate?.wordClickPopover(word: clickedWord, sourceView: webView)
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
        
        switch identifier {
            
        case Storyboard.showDictionary:
            if let dictionaryController = segue.destinationViewController.contentViewController as? DictionaryViewController {
                dictionaryController.word = resolvedWord
                dictionaryController.lang = Constants.ForeignLang
                resolvedWord = nil
            }
            
        case Storyboard.showTableOfContents:
            // note: toc controller embedded in a navigation controller to prevent it being presented underneath the
            // status bar on an iPhone
            if let controller = segue.destinationViewController.contentViewController as? TableOfContentsTableViewController {
                controller.popoverPresentationController?.barButtonItem = tableOfContentsButton
                controller.delegate = self
                controller.article = article
            }
            
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
    
    // MARK: - DictionaryPopoverPresenter
    
    func lookup(word: String, lang: String) {
        resolvedWord = word
        performSegue(withIdentifier: Storyboard.showDictionary, sender: self)
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
        if let htmlText = article?.htmlText {
            var htmlDoc = self.dynamicType.htmlTemplate.replacingOccurrences(of: "<!-- style -->", with: styleSheet)
            htmlDoc = htmlDoc.replacingOccurrences(of: "<!-- article -->", with: htmlText)
            webView.loadHTMLString(htmlDoc, baseURL: self.dynamicType.folderURL)
        }
    }
}

extension ArticleViewController: TableOfContentDelegate {
    func scrollToAnchor(anchor: String) {
        dismiss(animated: true, completion: nil)
        webView.evaluateJavaScript("scrollToAnchor('\(anchor)')", completionHandler: nil)
    }
}

