//
//  ArticleMenuViewController.swift
//  Belajar
//
//  Created by Jim Cramer on 09/08/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit

private struct Storyboard {
    static let embedArticleContents = "embedArticleContents"
    static let embedArticleOptions = "embedArticleOptions"
}

protocol ArticleMenuDelegate: ArticleContentsDelegate, ArticleOptionsDelegate {
}

private var lastSelectedSegmentIndex = 0

class ArticleMenuViewController: UIViewController {
    
    @IBOutlet weak private var optionsContainerView: UIView!
    @IBOutlet weak private var contentsContainerView: UIView!
    @IBOutlet weak private var segmentedControl: UISegmentedControl!
    
    weak var delegate: ArticleMenuDelegate?
    var article: Article?
    
    override func viewDidLoad() {
        segmentedControl.selectedSegmentIndex = lastSelectedSegmentIndex
        if segmentedControl.selectedSegmentIndex == 0 {
            optionsContainerView.alpha = 1
            contentsContainerView.alpha = 0
        } else {
            optionsContainerView.alpha = 0
            contentsContainerView.alpha = 1
        }
    }
    
    @IBAction func showComponent(_ sender: UISegmentedControl) {
        lastSelectedSegmentIndex = sender.selectedSegmentIndex
        if sender.selectedSegmentIndex == 0 {
            UIView.animate(withDuration: 0.25, animations: { [weak self] in
                self?.optionsContainerView.alpha = 1
                self?.contentsContainerView.alpha = 0
                })
        } else {
            UIView.animate(withDuration: 0.25, animations: { [weak self] in
                self?.optionsContainerView.alpha = 0
                self?.contentsContainerView.alpha = 1
                })
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.embedArticleContents {
            if let controller = segue.destination.contentViewController as? ArticleContentsTableViewController {
                controller.delegate = delegate
                controller.article = article
            }
        } else if segue.identifier == Storyboard.embedArticleOptions {
            if let controller = segue.destination.contentViewController as? ArticleOptionsTableViewController {
                controller.delegate = delegate
            }
        }
    }
}
