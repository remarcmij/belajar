//
//  LibraryCollectionViewCell.swift
//  Belajar
//
//  Created by Jim Cramer on 03/08/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit

class LibraryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak private var imageView: UIImageView!   
    @IBOutlet weak var blankCoverView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var infoButton: UIButton!
    
    weak var topic: Topic? {
        didSet {
            if let topic = topic {
                infoButton.tag = topic.id
                if let image = UIImage(named: topic.imageName) {
                    imageView.image = image
                    blankCoverView.isHidden = true
                } else  {
                    titleLabel.text = topic.title
                    imageView.isHidden = true
                }
            }
        }
    }
    
    func showSelectedState() {
        imageView.alpha = 0.5
        blankCoverView.alpha = 0.5
    }
}
