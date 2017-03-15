//
//  LibraryViewController.swift
//  Belajar
//
//  Created by Jim Cramer on 03/08/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit
import GoogleSignIn

private let publicationOrder = "publicationOrder"

protocol LibraryViewControllerDelegate: class {
    func setTopic(topic: Topic)
}

class LibraryViewController: UICollectionViewController, GIDSignInUIDelegate {
    
    private static var user: BackendClient.User? = nil
    
    weak var delegate: LibraryViewControllerDelegate?
    
    @IBOutlet weak private var signInButton: GIDSignInButton! {
        didSet {
            signInButton.style = .iconOnly
            signInButton.colorScheme = .dark
        }
    }
    
    private struct Storyboard {
        static let libraryViewCell = "LibraryViewCell"
    }
    
    var indexTopics = [Topic]()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadData()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        GIDSignIn.sharedInstance().uiDelegate = self
        signInButton.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDidSyncTopics),
                                               name: TopicManager.didSyncTopicsNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onSignedIn),
                                               name: Constants.didSignInNotification,
                                               object: nil)
        
        if BackendClient.shared.isTokenExpired() {
            LibraryViewController.user = nil
            updateUI()
        } else {
            if LibraryViewController.user != nil {
                updateUI()
            } else {
                BackendClient.shared.signInToServer() {[weak self] user in
                    LibraryViewController.user = user
                    DispatchQueue.main.async() {[weak self] in
                        self?.updateUI()
                        TopicManager.shared.syncTopics(isUserInitiated: false)
                    }
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let publicationNames = indexTopics.map { $0.publication }
        UserDefaults.standard.set(publicationNames, forKey: publicationOrder)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return indexTopics.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.libraryViewCell, for: indexPath) as! LibraryViewCell
        cell.topic = indexTopics[indexPath.row]
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath) as! LibraryViewCell
        selectedCell.showSelectedState()
        
        let topic = indexTopics[indexPath.row]
        indexTopics.remove(at: indexPath.row)
        indexTopics.insert(topic, at: 0)
        
        delegate?.setTopic(topic: topic)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [unowned self] in
            self.dismiss(animated: true, completion: nil)
        }
    }
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: AnyObject?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: AnyObject?) {
     
     }
     */
    
    @IBAction func infoButtonTapped(_ sender: UIButton) {
        if let topic = indexTopics.first(where: {$0.id == sender.tag}) {
            let message = NSMutableString()
            
            if let author = topic.author {
                message.append("\n\(author)")
            }
            
            if let publisher = topic.publisher {
                message.append("\n\(publisher)")
                if let pubDate = topic.pubDate {
                    message.append(" (\(pubDate))")
                }
            }
            
            if let isbn = topic.isbn {
                message.append("\nISBN: \(isbn)")
            }
            
            let alert = UIAlertController(title: topic.title, message: message as String, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func didTapMoreButton(_ sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelActionTitle = NSLocalizedString("Cancel", comment: "Library More button action sheet")
        actionSheet.addAction(UIAlertAction(title: cancelActionTitle, style: .cancel, handler: nil))
        
        let syncActionTitle = NSLocalizedString("Synchronize", comment: "Library More button action sheet")
        let syncAction = UIAlertAction(title: syncActionTitle, style: .default) { _ in
            TopicManager.shared.syncTopics(isUserInitiated: true)
        }
        syncAction.isEnabled = LibraryViewController.user != nil
        actionSheet.addAction(syncAction)
        
        let signOutActionTitle = NSLocalizedString("Sign out", comment: "Library More button action sheet")
        let signOutAction = UIAlertAction(title: signOutActionTitle, style: .default) { [weak self]_ in
            BackendClient.shared.signOut()
            GIDSignIn.sharedInstance().signOut()
            LibraryViewController.user = nil
            self?.signInButton.isHidden = false
        }
        signOutAction.isEnabled = LibraryViewController.user != nil
        actionSheet.addAction(signOutAction)
        
        present(actionSheet, animated: true, completion: nil)
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.barButtonItem = sender
        }
    }
    
    func onSignedIn(_ notification: NSNotification) {
        guard let googleUser = notification.userInfo?[Constants.googleUser] as? GIDGoogleUser else {
            return
        }
        BackendClient.shared.signInWithGoogle(googleUser: googleUser) {[weak self] success in
            if (success) {
                TopicManager.shared.syncTopics(isUserInitiated: true)
                self?.signInButton.isHidden = true
            }
        }
    }
    
    func onDidSyncTopics(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let userInitiatedSync = userInfo[TopicManager.userInitiatedSync] as? Bool,
            let newTopicCount = userInfo[TopicManager.newTopicCount] as? Int,
            let updatedTopicCount = userInfo[TopicManager.updatedTopicCount] as? Int,
            let deletedTopicCount = userInfo[TopicManager.deletedTopicCount] as? Int
            else { return }
        
        if newTopicCount + updatedTopicCount + deletedTopicCount > 0 {
            reloadData()
        } else if (userInitiatedSync) {
            let title = NSLocalizedString("Synchronization Completed", comment: "Synchronization completed alert")
            let message = NSLocalizedString("The latest updates have already been applied.", comment: "Synchronization completed alert")
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        
        #if DEBUG
            print("Topics synchronized: new: \(newTopicCount), updated: \(updatedTopicCount), deleted: \(deletedTopicCount)")
        #endif
    }
    
    private func reloadData() {
        var topics = TopicManager.shared.indexTopics
        var publicationNames = topics.map() { $0.publication }
        UserDefaults.standard.register(defaults: [publicationOrder: publicationNames])
        publicationNames = UserDefaults.standard.object(forKey: publicationOrder) as! [String]
        
        var orderedTopics = [Topic]()
        for publicationName in publicationNames {
            if let topic = topics.first(where: {$0.publication == publicationName}) {
                orderedTopics.append(topic)
            }
        }
        topics = topics.filter() {!orderedTopics.contains($0)}
        orderedTopics.append(contentsOf: topics)
        indexTopics = orderedTopics
        
        collectionView?.reloadData()
    }
    
    private func updateUI() {
        let isSignedIn = LibraryViewController.user != nil
        signInButton.isHidden = isSignedIn
        print("user: \(LibraryViewController.user)")
    }
}

extension LibraryViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let image = UIImage(named: indexTopics[indexPath.row].imageName) {
            let height = 125.0 / image.size.width * image.size.height
            return CGSize(width: 125, height: height)
        } else {
            return CGSize(width: 125, height: 180)
        }
    }
}
