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
        }
    }
    
    lazy var topics: [Topic] = {
        return TopicStore.sharedInstance.getPublicationTopics(for: self.indexTopic.publication)
    }()
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        let topic = topics[indexPath.row]
        cell.textLabel?.text = topic.title
        cell.detailTextLabel?.text = topic.subtitle
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowArticle" {
            if let row = tableView.indexPathForSelectedRow?.row {
                let topic = topics[row]
                let articleViewController = segue.destinationViewController as! ArticleViewController
                articleViewController.topic = topic
            }
        }
    }

}
