//
//  LibraryCollectionViewCell.swift
//  Belajar
//
//  Created by Jim Cramer on 03/08/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit

protocol LibraryCollectionViewCellDelegate: class {
    func infoButtonTapped(for: Topic)
}

class LibraryCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: LibraryCollectionViewCellDelegate?
    
    @IBOutlet weak private var imageView: UIImageView!
    
    weak var topic: Topic? {
        didSet {
            if let topic = topic {
                imageView.image = UIImage(named: topic.imageName)
            }
        }
    }
    
    @IBAction func infoButtonTapped() {
        delegate?.infoButtonTapped(for: topic!)
    }
}
