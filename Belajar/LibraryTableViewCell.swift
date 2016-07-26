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
    
    var topic: Topic! {
        didSet {
            productImageView?.image = UIImage(named: "\(topic.publication).index.png")
            productImageView?.sizeToFit()
            titleLabel?.text = topic.title
            titleLabel?.font = PreferredFont.get(type: .bodyLight)
            subtitleLabel?.text = topic.subtitle
            subtitleLabel?.font = PreferredFont.get(type: .caption1)
        }
    }
}
