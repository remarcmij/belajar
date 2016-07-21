//
//  SearchResultController.swift
//  Belajar
//
//  Created by Jim Cramer on 21/07/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit

protocol SearchResultsControllerDelegate {
    func lookup(word: String, lang: String)
}

class SearchResultsController: UITableViewController {
    
    var delegate: SearchResultsControllerDelegate?

    var autoCompleteItems = [AutoCompleteItem]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private struct Storyboard {
        static let AutoCompleteCell = "AutoCompleteCell"
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autoCompleteItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.AutoCompleteCell, for: indexPath)
        let item = autoCompleteItems[indexPath.row]
        cell.textLabel?.text = "\(item.word) [\(item.lang)]"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true, completion: nil)
        let selectedItem = autoCompleteItems[indexPath.row]
        delegate?.lookup(word: selectedItem.word, lang: selectedItem.lang)
    }

}