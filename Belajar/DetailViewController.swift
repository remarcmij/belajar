//
//  ArticleViewController.swift
//  Belajar
//
//  Created by Jim Cramer on 15/06/16.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController, WKScriptMessageHandler {
    
    private var webView: WKWebView!
    private var resolvedWord: String?
    private var clickedText: String?
    private var dictionaryPopoverDelegate: DictionaryPopoverDelegate?
    
    var topic: Topic? {
        didSet {
            if topic != nil {
                navigationItem.title = topic!.title
                article = TopicStore.sharedInstance.getArticle(withTopicId: topic!.id)
                if let htmlText = article?.htmlText {
                    let htmlDoc = self.dynamicType.htmlTemplate.replacingOccurrences(of: "<!-- placeholder -->", with: htmlText)
                    webView.loadHTMLString(htmlDoc, baseURL: self.dynamicType.folderURL)
                }
            }
        }
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
        dictionaryPopoverDelegate = DictionaryPopoverDelegate(controller: self)
        //
        //        // todo: move text injection to model
        //        if let htmlText = article?.htmlText {
        //            let htmlDoc = self.dynamicType.htmlTemplate.replacingOccurrences(of: "<!-- placeholder -->", with: htmlText)
        //            webView.loadHTMLString(htmlDoc, baseURL: self.dynamicType.folderURL)
        //        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(receiveWordLookupNotification),
                                       name: Constants.WordLookupNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
            
            dictionaryPopoverDelegate?.wordClickPopover(word: clickedWord)
        } else {
            print("something else called")
        }
    }
    
    private func alertControllerBackgroundTapped()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func receiveWordLookupNotification(notification: Notification) {
        if let word = notification.userInfo?["word"] as? String {
            resolvedWord = word
            performSegue(withIdentifier: "ShowDictionary", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDictionary" {
            if let dictionaryController = segue.destinationViewController.contentViewController as? DictionaryViewController {
                
                //            let dictionaryController = segue.destinationViewController as! DictionaryViewController
                dictionaryController.word = resolvedWord
                dictionaryController.lang = Constants.ForeignLang
                resolvedWord = nil
            }
        }
    }
    
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
}

