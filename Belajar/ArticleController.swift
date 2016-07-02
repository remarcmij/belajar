//
//  ArticleViewController.swift
//  Belajar
//
//  Created by Jim Cramer on 15/06/16.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit
import WebKit

class ArticleController: UIViewController {
    
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
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        let height = NSLayoutConstraint(item: webView, attribute: .height, relatedBy: .equal,
                                        toItem: view, attribute: .height, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: webView, attribute: .width, relatedBy: .equal,
                                       toItem: view, attribute: .width, multiplier: 1, constant: 0)
        view.addConstraints([height, width])
        
        if let htmlText = article?.htmlText {
            let htmlDoc = self.dynamicType.htmlTemplate.replacingOccurrences(of: "<!-- placeholder -->", with: htmlText)
            webView.load(htmlDoc.data(using: String.Encoding.utf8)!, mimeType: "text/html", characterEncodingName: "utf-8", baseURL: self.dynamicType.folderURL)
        }
    }
}
