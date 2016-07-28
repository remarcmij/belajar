//
//  DynamicTextTableViewController.swift
//  Belajar
//
//  Created by Jim Cramer on 26/07/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit

class DynamicTextTableViewController: UITableViewController {
    
    private var localObserver: NSObjectProtocol?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIContentSizeCategoryDidChange,
                                               object: UIApplication.shared(),
                                               queue: OperationQueue.main)
        {
            [weak self] _ in
            self?.tableView.reloadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool)  {
        super.viewDidDisappear(animated)
        if let observer = localObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
