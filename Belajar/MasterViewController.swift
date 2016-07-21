//
//  PublicationViewController.swift
//  Belajar
//
//  Created by Jim Cramer on 15/06/16.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    
    var indexTopic: Topic! {
        didSet {
            navigationItem.title = indexTopic.title
            topics = TopicStore.sharedInstance.getPublicationTopics(for: indexTopic.publication)
            tableView.reloadData()
        }
    }
    
    //    private var detailViewController: DetailViewController?
    
    private var topics = [Topic]()
    
    private struct Storyboard {
        static let PublicationCell = "PublicationCell"
        static let ShowDetail = "ShowDetail"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        navigationItem.leftBarButtonItem = editButtonItem()
        
        //        if let split = splitViewController {
        //            let controllers = split.viewControllers
        //            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        //        }
        
        tableView.estimatedRowHeight = tableView.rowHeight // Storyboard height
        tableView.rowHeight = UITableViewAutomaticDimension
        indexTopic = Topic(id: 0, fileName: "", publication: "harmani", chapter: "", groupName: "", sortIndex: 0, title: "Harmani", subtitle: "", author: "", publisher: "", pubDate: "", icon: "", lastModified: "")
        
        definesPresentationContext = true
        //        let collectionController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DictPopover") as! DictionaryPopoverController
        //        present(collectionController, animated: true, completion: nil)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.PublicationCell, for: indexPath)
        let topic = topics[indexPath.row]
        cell.textLabel?.text = topic.title
        cell.detailTextLabel?.text = topic.subtitle
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let detailController = splitViewController?.viewControllers.last?.contentViewController as? DetailViewController {
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
        
        guard let detailController = contentController as? DetailViewController,
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

