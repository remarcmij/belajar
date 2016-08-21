//
//  MainMenuTableViewController.swift
//  Belajar
//
//  Created by Jim Cramer on 30/07/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit

protocol MainMenuTableViewControllerDelegate: class {
    func showLibrary()
}

class MainMenuTableViewController: UITableViewController {

    weak var delegate: MainMenuTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = tableView.rowHeight // Storyboard height
        tableView.rowHeight = UITableViewAutomaticDimension

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }


    // MARK: - Navigation

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            dismiss(animated: true) { [weak self] in
                self?.delegate?.showLibrary()
            }
            
        default: break
        }
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
