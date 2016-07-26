//
//  DictionaryController.swift
//  Belajar
//
//  Created by Jim Cramer on 19/06/16.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit

class DictionarySearchViewController : UITableViewController, SearchResultsControllerDelegate, DictionaryPopoverPresenter {
    
    var word: String!
    var lang: String!
    
    @IBOutlet private weak var tableViewFooterLabel: UILabel! {
        didSet {
            // add some white space after last lemma
            tableViewFooterLabel.text = " "
        }
    }
    
    private var aggregates = [LemmaBatch]()
    private var dictionaryPopoverDelegate: DictionaryPopoverDelegate!
    private var searchController: UISearchController!
    
    private static var theSearchResultsController: SearchResultsController = {
        return UIStoryboard.init(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "SearchResultsController") as! SearchResultsController
    }()
    
    private struct Storyboard {
        static let HeaderCell = "headerCell"
        static let ContinuationCell = "continuationCell"
        static let ReferenceCell = "referenceCell"
    }
    
    // MARK: - life cycle
    
    deinit {
        // ref: http://stackoverflow.com/questions/32282401/attempting-to-load-the-view-of-a-view-controller-while-it-is-deallocating-uis
        searchController.view.removeFromSuperview()
        
        LemmaCell.clearCache()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        dictionaryPopoverDelegate = DictionaryPopoverDelegate(presenter: self)
        
        let searchResultsController = self.dynamicType.theSearchResultsController
        searchResultsController.delegate = self
        
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
            lookup(word: word, lang: lang)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onContentSizeChanged),
                                               name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveWordClickNotification),
                                               name: Constants.WordClickNotification, object: nil)
        
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
        return aggregates.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let aggregate = aggregates[row]
        
        let identifier: String
        if (row == 0 || aggregates[row-1].base != aggregate.base) {
            if aggregate.base == word {
                identifier = Storyboard.HeaderCell
            } else {
                identifier = Storyboard.ReferenceCell
            }
        } else {
            identifier = Storyboard.ContinuationCell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! LemmaCell
        cell.setLemmaGroup(with: aggregate, forRow: indexPath.row)
        
        if row == 0 {
            cell.hideSeparator()
        }
        
        return cell
    }
    
    @IBAction func dismiss(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func baseButtonTapped(_ sender: UIButton) {
        if let word = sender.title(for: .normal) {
            lookup(word: word.lowercased(), lang: Constants.ForeignLang)
        }
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
    
    // MARK: - private helper functions
    
    private func getHeaderCell(aggregate: LemmaBatch, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.HeaderCell, for: indexPath) as! LemmaHeaderCell
        cell.setLemmaGroup(with: aggregate, forRow: indexPath.row)
        return cell
    }
    
    private func getBodyCell(aggregate: LemmaBatch, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ContinuationCell, for: indexPath) as! LemmaContinuationCell
        cell.setLemmaGroup(with: aggregate, forRow: indexPath.row)
        return cell
    }
    
    func lookup(word: String, lang: String) {
        
        let startTime = Date()
        
        let normalisedWord = word.folding(options: .diacriticInsensitive, locale: Locale.current).lowercased()
        self.word = normalisedWord
        self.lang = lang
        
        if let (_, word) = DictionaryStore.sharedInstance.lookupWord(word: normalisedWord, lang: lang) {
            let lemmas = DictionaryStore.sharedInstance.search(word: word, lang: lang)
            aggregates = Lemma.batchLemmas(word: word, lemmas: lemmas)
        }
        
        clearCacheAndReloadData()
        
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated : false)
        
        let endTime = Date()
        let elapsed = endTime.timeIntervalSince(startTime) * 1000
        print("lookup \(word) took \(elapsed) ms")
    }
    
    private func hideSearchBar() {
        tableView.setContentOffset(CGPoint(x: 0, y: searchController.searchBar.frame.size.height), animated: false)
    }
    
    func onContentSizeChanged() {
        clearCacheAndReloadData()
    }
    
    private func clearCacheAndReloadData() {
        LemmaCell.clearCache()
        tableView.reloadData()
    }
}

extension DictionarySearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let term = searchBar.text!.lowercased()
        guard !term.isEmpty else { return }
        
        let autoCompleteItems = DictionaryStore.sharedInstance.autoCompleteSearch(term: term, lang: nil)
        
        (searchController.searchResultsController as? SearchResultsController)?.autoCompleteItems = autoCompleteItems
    }
}

extension DictionarySearchViewController: UISearchBarDelegate {
    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
        print("resultslistbutton clicked")
    }
}
