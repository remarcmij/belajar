//
//  LibraryCollectionViewController.swift
//  Belajar
//
//  Created by Jim Cramer on 03/08/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit

private let publicationOrder = "publicationOrder"

protocol LibraryCollectionViewControllerDelegate: class {
    func setTopic(topic: Topic)
}

class LibraryCollectionViewController: UICollectionViewController {
    
    weak var delegate: LibraryCollectionViewControllerDelegate?
    
    private struct Storyboard {
        static let libraryCollectionViewCell = "LibraryCollectionViewCell"
    }
    
    lazy var collectionTopics: [Topic] = {
        var topics = TopicStore.sharedInstance.getCollection()
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
        return orderedTopics
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
        //        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let publicationNames = collectionTopics.map() { $0.publication }
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
        return collectionTopics.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.libraryCollectionViewCell, for: indexPath) as! LibraryCollectionViewCell
        cell.topic = collectionTopics[indexPath.row]
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath) as! LibraryCollectionViewCell
        selectedCell.showSelectedState()
        
        let topic = collectionTopics[indexPath.row]
        collectionTopics.remove(at: indexPath.row)
        collectionTopics.insert(topic, at: 0)
        
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
        if let topic = collectionTopics.first(where: {$0.id == sender.tag}) {
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
}

extension LibraryCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let image = UIImage(named: collectionTopics[indexPath.row].imageName) {
            let height = 125.0 / image.size.width * image.size.height
            return CGSize(width: 125, height: height)
        } else {
            return CGSize(width: 125, height: 180)
        }
    }
}
