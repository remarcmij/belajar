//
//  ArticleMenuPageViewController.swift
//  Belajar
//
//  Created by Jim Cramer on 10/08/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit

private struct Storyboard {
    static let articleOptionsTableViewController = "ArticleOptionsTableViewController"
    static let articleContentsTableViewController = "ArticleContentsTableViewController"
    
}
protocol ArticleMenuPageViewControllerDelegate: ArticleContentsDelegate, ArticleOptionsDelegate {
}

class ArticleMenuPageViewController: UIPageViewController {

    weak var menuDelegate: ArticleMenuPageViewControllerDelegate?
    var article: Article?

    private var optionsViewController: ArticleOptionsTableViewController?
    private var contentsViewController: ArticleContentsTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        optionsViewController = UIStoryboard.init(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: Storyboard.articleOptionsTableViewController) as? ArticleOptionsTableViewController
        optionsViewController?.delegate = menuDelegate
        
        contentsViewController = UIStoryboard.init(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: Storyboard.articleContentsTableViewController) as? ArticleContentsTableViewController
        contentsViewController?.delegate = menuDelegate
        contentsViewController?.article = article
        
        setViewController(forIndex: 0)
    }

    func setViewController(forIndex index: Int) {
        setViewControllers([index == 0 ? contentsViewController! : optionsViewController!],
                           direction: .forward, animated: false, completion: nil)
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        setViewController(forIndex: sender.selectedSegmentIndex)
    }

    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }   
}

extension ArticleMenuPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController == contentsViewController {
            return optionsViewController
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController == optionsViewController {
            return contentsViewController
        }
        
        return nil
    }
}
