//
//  FlashCardPageViewController.swift
//  Belajar
//
//  Created by Jim Cramer on 17/08/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit

protocol FlashCardPageViewControllerDelegate: class {
    func flashCardPageNumber(changedTo: Int)
    func speakText(forPageNumber pageNumber: Int)
}

class FlashCardPageViewController: UIPageViewController {
    
    private var reusableControllers = Set<FlashCardViewController>()
    
    var flashCards: [FlashCard]!
    
    weak var flashCardDelegate: FlashCardPageViewControllerDelegate?
    
    private struct Storyboard {
        static let flashCardStoryboardName = "FlashCard"
        static let flashCardViewController  = "FlashCardViewController"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
    }
    
    func setCurrentPage(pageNumber: Int) {
        if let currentViewController = viewControllers?.first as? FlashCardViewController {
            if currentViewController.pageNumber == pageNumber {
                return
            }
        }

        let flashCardController = getController(forPageNumber: pageNumber)
        flashCardDelegate?.flashCardPageNumber(changedTo: pageNumber)
        setViewControllers([flashCardController], direction: .forward, animated: false, completion: nil)
    }
    
    private func dequeueResusableController() -> FlashCardViewController {
        let unusedControllers = reusableControllers.filter() { $0.parent == nil }
        if let unusedController = unusedControllers.last {
            return unusedController
        }
        
        let newController = UIStoryboard.init(name: Storyboard.flashCardStoryboardName, bundle: nil)
            .instantiateViewController(withIdentifier: Storyboard.flashCardViewController) as! FlashCardViewController
        reusableControllers.insert(newController)
        return newController
    }
    
    fileprivate func getController(forPageNumber pageNumber: Int) -> FlashCardViewController {
        let newController = dequeueResusableController()
        newController.delegate = self
        newController.pageNumber = pageNumber
        let flashCard = flashCards[pageNumber / 2]
        newController.cardText = pageNumber % 2 == 0 ? flashCard.phrase : flashCard.translation
        return newController
    }
}

extension FlashCardPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentController = viewController as! FlashCardViewController
        let pageNumber = currentController.pageNumber
        return pageNumber <= 0 ? nil : getController(forPageNumber: pageNumber - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentController = viewController as! FlashCardViewController
        let pageNumber = currentController.pageNumber
        return pageNumber >= flashCards.count * 2 - 1 ? nil: getController(forPageNumber: pageNumber + 1)
    }
}

extension FlashCardPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let flashCardController = pageViewController.viewControllers?[0] as? FlashCardViewController {
                let pageNumber = flashCardController.pageNumber
                flashCardDelegate?.flashCardPageNumber(changedTo: pageNumber)
                flashCardDelegate?.speakText(forPageNumber: pageNumber)
            }
        }
    }
}

extension FlashCardPageViewController: FlashCardViewControllerDelegate {
    
    func textTapped(forPagenumber pageNumber: Int) {
        flashCardDelegate?.speakText(forPageNumber: pageNumber)
    }
}
