//
//  LibraryViewCell.swift
//  Belajar
//
//  Created by Jim Cramer on 03/08/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit

class LibraryViewCell: UICollectionViewCell {
    
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
                    imageView.isHidden = false
                    blankCoverView.isHidden = true
                } else  {
                    titleLabel.text = topic.title
                    imageView.isHidden = true
                    blankCoverView.isHidden = false
                }
            }
        }
    }
    
    func showSelectedState() {
        let overlayView = UIView(frame: bounds)
        overlayView.backgroundColor = UIColor.black
        overlayView.alpha = 0.5
        addSubview(overlayView)
    }
}
