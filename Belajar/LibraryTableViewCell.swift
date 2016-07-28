//
//  LibraryTableViewCell.swift
//  Belajar
//
//  Created by Jim Cramer on 24/07/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit

class LibraryTableViewCell: UITableViewCell {

    @IBOutlet weak private var productImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var subtitleLabel: UILabel!
    
    func setTopic(topic: Topic, displayScale: CGFloat) {
        if displayScale >= 2.0 {
            productImageView?.image = UIImage(named: "\(topic.publication).index@2x.png")
        }
        if productImageView?.image == nil {
            productImageView?.image = UIImage(named: "\(topic.publication).index.png")
        }
        productImageView?.sizeToFit()
        titleLabel?.text = topic.title
        titleLabel?.font = PreferredFont.get(type: .subhead)
        subtitleLabel?.text = topic.subtitle
        subtitleLabel?.font = PreferredFont.get(type: .caption1)
        
    }
}
