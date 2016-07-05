//
//  ArticleViewController.swift
//  Belajar
//
//  Created by Jim Cramer on 15/06/16.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit
import WebKit

class ArticleController: UIViewController, WKScriptMessageHandler {
    
    private var clickedWord: String?
    private var clickedText: String?
    
    var topic: Topic! {
        didSet {
            navigationItem.title = topic.title
        }
    }
    
    lazy var article: Article? = {
        return TopicStore.sharedInstance.getArticle(withTopicId: self.topic.id)
    }()
    
    static let htmlTemplate: String = {
        let indexURL = Bundle.main().urlForResource("index", withExtension: "html", subdirectory: "www")!
        return try! String(contentsOf: indexURL, encoding: String.Encoding.utf8)
    }()
    
    static let folderURL: URL = {
        return Bundle.main().urlForResource("www", withExtension: nil)!
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webView = WKWebView(frame: CGRect.zero)
        view.addSubview(webView)
        
        webView.configuration.userContentController.add(MyMessageHandler(delegate: self), name: "wordClick");
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        let height = NSLayoutConstraint(item: webView, attribute: .height, relatedBy: .equal,
                                        toItem: view, attribute: .height, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: webView, attribute: .width, relatedBy: .equal,
                                       toItem: view, attribute: .width, multiplier: 1, constant: 0)
        view.addConstraints([height, width])
        
        if let htmlText = article?.htmlText {
            let htmlDoc = self.dynamicType.htmlTemplate.replacingOccurrences(of: "<!-- placeholder -->", with: htmlText)
            //            webView.load(htmlDoc.data(using: String.Encoding.utf8)!, mimeType: "text/html",
            //                         characterEncodingName: "utf-8", baseURL: self.dynamicType.folderURL)
            webView.loadHTMLString(htmlDoc, baseURL: self.dynamicType.folderURL)
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "wordClick" {
            let components = (message.body as! String).components(separatedBy: "|")
            clickedWord = components[0]
            clickedText = components[1]
            print("Javascript clickedWord: \(clickedWord) clickedText: \(clickedText)")
            performSegue(withIdentifier: "ShowDictionary", sender: self)
        } else {
            print("something else called")
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDictionary" {
            print("prepare called")
            let dictionaryController = segue.destinationViewController as! DictionaryController
            dictionaryController.word = clickedWord
            dictionaryController.lang = foreignLang
            clickedWord = nil
        }
    }
    
    class MyMessageHandler: NSObject,  WKScriptMessageHandler {
        weak var delegate: WKScriptMessageHandler?
        
        init(delegate: WKScriptMessageHandler) {
            self.delegate = delegate
            super.init()
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            delegate?.userContentController(userContentController, didReceive: message)
        }
    }
}
