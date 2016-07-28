//
//  PublicationViewController.swift
//  Belajar
//
//  Created by Jim Cramer on 15/06/16.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit

class PublicationViewController: DynamicTextTableViewController {
    
    var publication: String! {
        didSet {
            topics = TopicStore.sharedInstance.getPublicationTopics(for: publication)
            tableView.reloadData()
        }
    }
    
    private var topics = [Topic]()
    
    private struct Storyboard {
        static let PublicationTableViewCell = "PublicationTableViewCell"
        static let ShowDetail = "ShowDetail"
    }
    
    private struct RestorationIndentifier {
        static let publication = "publication"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight // Storyboard height
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.PublicationTableViewCell, for: indexPath) as! PublicationTableViewCell
        cell.topic = topics[indexPath.row]
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let articleViewController = splitViewController?.viewControllers.last?.contentViewController as? ArticleViewController {
            prepare(articleViewController: articleViewController, for: topics[indexPath.row])
        } else {
            performSegue(withIdentifier: Storyboard.ShowDetail, sender: tableView.cellForRow(at: indexPath))
        }
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let articleViewController = segue.destinationViewController.contentViewController as? ArticleViewController,
            let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell),
            let identifier = segue.identifier,
            identifier == Storyboard.ShowDetail
            else { return }
        prepare(articleViewController: articleViewController, for: topics[indexPath.row])
    }
    
    // MARK: - Restoration
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        coder.encode(publication, forKey: RestorationIndentifier.publication)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        if let publication = coder.decodeObject(forKey: RestorationIndentifier.publication) as? String {
            self.publication = publication
        }
    }
    
    // MARK: - Help methods
    func prepare(articleViewController controller: ArticleViewController, for topic: Topic) {
        controller.topicID = topic.id
        controller.navigationItem.title = topic.title
        controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
        controller.navigationItem.leftItemsSupplementBackButton = true
    }
}

