//
//  PublicationTableViewCell.swift
//  Belajar
//
//  Created by Jim Cramer on 24/07/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit

class PublicationTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    var topic: Topic! {
        didSet {
            titleLabel?.text = topic.title
            titleLabel?.font = PreferredFont.get(type: .body)
            subtitleLabel?.text = topic.subtitle
            subtitleLabel?.font = PreferredFont.get(type: .subhead)
        }
    }
}
