//
//  PublicationViewController.swift
//  Belajar
//
//  Created by Jim Cramer on 15/06/16.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit

class PublicationViewController: DynamicTextTableViewController {
    
    var topic: Topic? {
        didSet {
            if topic != nil {
                topics = TopicStore.sharedInstance.getPublicationTopics(for: topic!.publication)
                navigationItem.title = topic?.title
                tableView.reloadData()
            }
        }
    }
    
    private var lastSelectedKey: String {
        return "\(topic!.publication).lastSelected"
    }
    
    private var searchButton: UIBarButtonItem?
    
    private var topics = [Topic]()
    
    private struct Storyboard {
        static let PublicationTableViewCell = "PublicationTableViewCell"
        static let PresentMenu = "PresentMenu"
        static let ShowDetail = "ShowDetail"
        static let ShowLibrary = "ShowLibrary"
        static let ShowDictionary = "ShowDictionary"
    }
    
    private struct RestorationIdentifier {
        static let topic = "topic"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight // Storyboard height
        tableView.rowHeight = UITableViewAutomaticDimension

        if traitCollection.userInterfaceIdiom == .phone {
            searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(performDictionarySegue))
            navigationItem.rightBarButtonItem = searchButton
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if topic == nil {
            performSegue(withIdentifier: Storyboard.ShowLibrary, sender: self)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let row = tableView.indexPathForSelectedRow?.row {
            UserDefaults.standard.set(row, forKey: lastSelectedKey)
        }
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
        showArticle(at: indexPath)
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == Storyboard.ShowDetail {
            guard let articleViewController = segue.destination.contentViewController as? ArticleViewController,
                let cell = sender as? UITableViewCell,
                let indexPath = tableView.indexPath(for: cell)
                else { return }
            prepare(articleViewController: articleViewController, for: topics[indexPath.row])
        } else if segue.identifier == Storyboard.ShowLibrary {
            guard let libraryViewController = segue.destination.contentViewController as? LibraryCollectionViewController
                else { return }
            libraryViewController.delegate = self
        } else if segue.identifier == Storyboard.PresentMenu {
            guard let menuViewController = segue.destination.contentViewController as? MainMenuTableViewController
                else { return }
            menuViewController.delegate = self
        }
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
    
    // MARK: - Help methods
    
    func showArticle(at indexPath: IndexPath) {
        if let articleViewController = splitViewController?.viewControllers.last?.contentViewController as? ArticleViewController {
            prepare(articleViewController: articleViewController, for: topics[indexPath.row])
        } else {
            performSegue(withIdentifier: Storyboard.ShowDetail, sender: tableView.cellForRow(at: indexPath))
        }
    }
    
    func prepare(articleViewController controller: ArticleViewController, for topic: Topic) {
        controller.topic = topic
        controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        controller.navigationItem.leftItemsSupplementBackButton = true
    }
    
    func performDictionarySegue() {
        performSegue(withIdentifier: Storyboard.ShowDictionary, sender: searchButton)
    }
}

extension PublicationViewController: MainMenuTableViewControllerDelegate {
    func showLibrary() {
        performSegue(withIdentifier: Storyboard.ShowLibrary, sender: self)
    }
}

extension PublicationViewController: LibraryCollectionViewControllerDelegate {
    func setTopic(topic: Topic) {
        self.topic = topic
        let lastSelectedRow = UserDefaults.standard.integer(forKey: lastSelectedKey)
        showArticle(at: IndexPath(row: lastSelectedRow, section: 0))
    }
}


