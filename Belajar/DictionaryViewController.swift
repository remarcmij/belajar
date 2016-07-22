//
//  DictionaryController.swift
//  Belajar
//
//  Created by Jim Cramer on 19/06/16.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit


class DictionaryViewController : UITableViewController, SearchResultsControllerDelegate {
    
    var word: String!
    var lang: String!
    
    private var lemmaHomonyms = [LemmaHomonym]()
    private var dictionaryPopoverDelegate: DictionaryPopoverDelegate!
    private var searchController: UISearchController!
    
    private struct Storyboard {
        static let LemmaHeaderCell = "LemmaHeaderCell"
        static let LemmaBodyCell = "LemmaBodyCell"
    }
    
    // MARK: - life cycle
    
    deinit {
        LemmaBaseCell.clearCache()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        dictionaryPopoverDelegate = DictionaryPopoverDelegate(controller: self)
        
        let searchResultsController = storyboard!.instantiateViewController(withIdentifier: "SearchResultsController") as! SearchResultsController
        searchResultsController.delegate = self
        searchResultsController.modalPresentationStyle = .popover
        
        searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.searchResultsUpdater = self
        
        let searchBar = searchController.searchBar
        searchBar.delegate = self
        searchBar.showsSearchResultsButton = true
        searchBar.autocapitalizationType = .none
        searchBar.autocorrectionType = .no
        searchBar.sizeToFit()
        
        navigationItem.titleView = searchBar
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        
        if word != nil {
            searchBar.text = word!
            lookup(word: word, lang: lang)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(receiveWordClickNotification),
                                       name: Constants.WordClickNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(receiveWordLookupNotification),
                                       name: Constants.WordLookupNotification, object: nil)

        if word == nil {
            // show keyboard (needs delay, otherwise becomeFirstResponder return false
            DispatchQueue.main.after(when: .now() + 0.5) { [weak self] in
                self?.searchController.searchBar.becomeFirstResponder()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lemmaHomonyms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let lemmaHomonym = lemmaHomonyms[row]
        if (row == 0 || lemmaHomonyms[row-1].base != lemmaHomonym.base) {
            return getHeaderCell(lemmaHomonym: lemmaHomonym, cellForRowAt: indexPath)
        } else {
            return getBodyCell(lemmaHomonym: lemmaHomonym, cellForRowAt: indexPath)
        }
    }
    
    @IBAction func dismiss(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - notification receivers
    
    /// Registered to receive a notification when a lemma body word is clicked.
    /// Invokes a popover with a dictionary synopsis of the clicked word
    ///
    /// - parameters:
    ///     - notification: The received notification
    ///
    func receiveWordClickNotification(notification: Notification) {
        if let word = notification.userInfo?["word"] as? String {
            dictionaryPopoverDelegate?.wordClickPopover(word: word)
        }
    }
    
    /// Registered to receive a notification when a lemma base header is clicked.
    /// Invokes a direct dictionary search for the clicked lemma base
    ///
    /// - parameters:
    ///     - notification: The received notification
    ///
    func receiveWordLookupNotification(notification: Notification) {
        if let word = notification.userInfo?["word"] as? String {
            lookup(word: word, lang: Constants.ForeignLang)
        }
    }
    
    // MARK: - private helper functions
    
    private func getHeaderCell(lemmaHomonym: LemmaHomonym, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.LemmaHeaderCell, for: indexPath) as! LemmaHeaderCell
        cell.setLemmaText(with: lemmaHomonym, forRow: indexPath.row)
        return cell
    }
    
    private func getBodyCell(lemmaHomonym: LemmaHomonym, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.LemmaBodyCell, for: indexPath) as! LemmaBodyCell
        cell.setLemmaText(with: lemmaHomonym, forRow: indexPath.row)
        return cell
    }
    
    func lookup(word: String, lang: String) {
        
        let startTime = Date()
        
        let normalisedWord = word.folding(options: .diacriticInsensitive, locale: Locale.current).lowercased()
        if let result = DictionaryStore.sharedInstance.lookupWord(word: normalisedWord, lang: lang) {
            lemmaHomonyms = DictionaryStore.sharedInstance.aggregateSearch(word: result.1, lang: lang)
        }
        
        LemmaBaseCell.clearCache()
        tableView.reloadData()
        
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        //        hideSearchBar()
        
        let endTime = Date()
        let elapsed = endTime.timeIntervalSince(startTime) * 1000
        print("lookup \(word) took \(elapsed) ms")
    }
    
    private func hideSearchBar() {
        tableView.setContentOffset(CGPoint(x: 0, y: searchController.searchBar.frame.size.height), animated: false)
    }
}

extension DictionaryViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let term = searchBar.text!.lowercased()
        guard !term.isEmpty else { return }
        
        let autoCompleteItems = DictionaryStore.sharedInstance.autoCompleteSearch(term: term, lang: nil)
        
        (searchController.searchResultsController as? SearchResultsController)?.autoCompleteItems = autoCompleteItems
    }
}

extension DictionaryViewController: UISearchBarDelegate {
    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
        print("resultslistbutton clicked")
    }
}
