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

protocol ArticleContentsTableViewControllerDelegate: class {
    func scrollToAnchor(anchor: String)
}

class ArticleContentsTableViewController: UITableViewController {
    
    private struct Storyboard {
        static let tableOfContentCell = "TableOfContentsCell"
    }
    
    @IBOutlet weak private var doneButton: UIBarButtonItem!
    
    private var anchors = [AnchorInfo]()
    
    weak var delegate: ArticleContentsTableViewControllerDelegate?
    
    var article: Article? {
        didSet {
            if article != nil {
                anchors = article!.getAnchors()
            } else {
                anchors.removeAll()
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
        cell.textLabel?.font = PreferredFont.get(type: .body)
        cell.textLabel?.text = anchors[indexPath.row].title
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
