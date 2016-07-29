//
//  LibraryViewController.swift
//  Belajar
//
//  Created by Jim Cramer on 15/06/16.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit

class LibraryViewController: DynamicTextTableViewController {

    private struct Storyboard {
        static let showPublication = "showPublication"
        static let libraryTableViewCell = "LibraryTableViewCell"
    }
    
    private lazy var topics: [Topic] = {
        return TopicStore.sharedInstance.getCollection()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight 
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.libraryTableViewCell, for: indexPath) as! LibraryTableViewCell
        cell.setTopic(topic: topics[indexPath.row], displayScale: traitCollection.displayScale)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.showPublication {
            if let row = tableView.indexPathForSelectedRow?.row {
                let publicationViewController = segue.destinationViewController as! PublicationViewController
                publicationViewController.topic = topics[row]
            }
        }
    }
}

