//
//  CollectionViewController.swift
//  Belajar
//
//  Created by Jim Cramer on 15/06/16.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit

class CollectionController: UITableViewController {
    
    private lazy var topics: [Topic] = {
        return TopicStore.sharedInstance.getCollection()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 85.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }

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
        if segue.identifier == "ShowPublication" {
            if let row = tableView.indexPathForSelectedRow?.row {
                let indexTopic = topics[row]
                let masterViewViewController = segue.destinationViewController as! MasterViewController
                masterViewViewController.indexTopic = indexTopic
            }
        }
    }
    
}
