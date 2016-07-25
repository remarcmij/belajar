//
//  PublicationViewController.swift
//  Belajar
//
//  Created by Jim Cramer on 15/06/16.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit

class PublicationViewController: UITableViewController {
    
    var indexTopic: Topic! {
        didSet {
            navigationItem.title = indexTopic.title
            topics = TopicStore.sharedInstance.getPublicationTopics(for: indexTopic.publication)
            tableView.reloadData()
        }
    }
    
    //    private var articleViewController: ArticleViewController?
    
    private var topics = [Topic]()
    
    private struct Storyboard {
        static let PublicationTableViewCell = "PublicationTableViewCell"
        static let ShowDetail = "ShowDetail"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        navigationItem.leftBarButtonItem = editButtonItem()
        
        //        if let split = splitViewController {
        //            let controllers = split.viewControllers
        //            articleViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? ArticleViewController
        //        }
        
        tableView.estimatedRowHeight = tableView.rowHeight // Storyboard height
        tableView.rowHeight = UITableViewAutomaticDimension
        
//        definesPresentationContext = true
        //        let libraryViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DictPopover") as! DictionaryPopoverController
        //        present(libraryViewController, animated: true, completion: nil)
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
        let topic = topics[indexPath.row]
        cell.titleLabel?.text = topic.title
        cell.subtitleLabel?.text = topic.subtitle
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let detailController = splitViewController?.viewControllers.last?.contentViewController as? ArticleViewController {
            // FIXME: use presented dic
            detailController.topic = topics[indexPath.row]
            detailController.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
            detailController.navigationItem.leftItemsSupplementBackButton = true
        } else {
            performSegue(withIdentifier: Storyboard.ShowDetail, sender: tableView.cellForRow(at: indexPath))
        }
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        var contentController = segue.destinationViewController
        if let navController = contentController as? UINavigationController {
            contentController = navController.viewControllers[0] ?? contentController
        }
        
        guard let detailController = contentController as? ArticleViewController,
            let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell),
            let identifier = segue.identifier,
            identifier == Storyboard.ShowDetail
            else { return }
        
        detailController.topic = topics[indexPath.row]
        detailController.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
        detailController.navigationItem.leftItemsSupplementBackButton = true
    }
}

