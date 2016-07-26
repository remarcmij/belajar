//
//  LemmaHeaderCell.swift
//  Belajar
//
//  Created by Jim Cramer on 21/07/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class LemmaHeaderCell: LemmaCell {
    
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var bodyLabel: TTTAttributedLabel! {
        didSet {
            bodyLabel.delegate = self
            bodyLabel.linkAttributes = LemmaCell.linkAttributes
        }
    }
    
    override func setLemmaGroup(with lemmaBatch: LemmaBatch, forRow rowIndex: Int) {
        super.setLemmaGroup(with:lemmaBatch, forRow: rowIndex)
        headerLabel.text = headerText!.string
        headerLabel.font = PreferredFont.get(type: .caption1Bold)
        bodyLabel.setText(bodyText!)
        separatorView.isHidden = false
    }
    
    override func hideSeparator() {
        separatorView.isHidden = true
    }
}
