//
//  LibraryTableViewCell.swift
//  Belajar
//
//  Created by Jim Cramer on 24/07/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit

class LibraryTableViewCell: UITableViewCell {

    @IBOutlet private weak var productImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = PreferredFont.get(type: .bodyTextLight)
        }
    }
    @IBOutlet private weak var subtitleLabel: UILabel!
    
    var topic: Topic! {
        didSet {
            productImageView?.image = UIImage(named: "\(topic.publication).index.png")
            productImageView?.sizeToFit()
            titleLabel?.text = topic.title
            subtitleLabel?.text = topic.subtitle
        }
    }
}
