//
//  TableOfContentsTableViewController.swift
//  Belajar
//
//  Created by Jim Cramer on 27/07/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit

private let anchorRegExp = try! NSRegularExpression(pattern: "<(h\\d) id=\"(.+?)\">(.+?)</h\\d>", options: [])
private let htmlTagRegExp = try! NSRegularExpression(pattern: "<.+?>", options: [])

protocol ArticleContentsDelegate: class {
    func scrollToAnchor(anchor: String)
}

class ArticleContentsTableViewController: UITableViewController {

    private struct Storyboard {
        static let tableOfContentCell = "TableOfContentsCell"
        
    }

    private struct AnchorInfo {
        let tag: String;
        let anchor: String;
        let title: String;
    }
    
    @IBOutlet weak private var doneButton: UIBarButtonItem!
    
    private var anchors = [AnchorInfo]()
    
    weak var delegate: ArticleContentsDelegate?
    
    var article: Article? {
        didSet {
            if let text: NSString = article?.htmlText {
                let matches = anchorRegExp.matches(in: text as String, options: [], range: NSMakeRange(0, text.length))
                anchors.removeAll()
                for match in matches {
                    anchors.append(AnchorInfo(tag: text.substring(with: match.rangeAt(1)),
                                              anchor: text.substring(with: match.rangeAt(2)),
                                              title: text.substring(with: match.rangeAt(3))))
                }
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return anchors.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.tableOfContentCell, for: indexPath)
        let title = anchors[indexPath.row].title
        cell.textLabel?.font = PreferredFont.get(type: .body)
        cell.textLabel?.text = htmlTagRegExp.stringByReplacingMatches(in: title, options: [],
                                                                      range: NSMakeRange(0, title.characters.count),
                                                                      withTemplate: "")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.scrollToAnchor(anchor: anchors[indexPath.row].anchor)
    }
    
    // MARK: - @IBAction handlers
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
