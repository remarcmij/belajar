//
//  DynamicTextTableViewController.swift
//  Belajar
//
//  Created by Jim Cramer on 26/07/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit

class DynamicTextTableViewController: UITableViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(onContentSizeChanged),
                                               name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool)  {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func onContentSizeChanged() {
        tableView.reloadData()
    }
}
