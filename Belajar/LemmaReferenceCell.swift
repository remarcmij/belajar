//
//  LemmaReferenceCell.swift
//  Belajar
//
//  Created by Jim Cramer on 23/07/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class LemmaReferenceCell: LemmaCell {
    
    @IBOutlet private weak var baseButton: UIButton!
    
    @IBOutlet private weak var bodyLabel: TTTAttributedLabel! {
        didSet {
            bodyLabel.delegate = self
            bodyLabel.linkAttributes = LemmaCell.linkAttributes
        }
    }
    
    @IBOutlet private weak var separatorView: UIView!
    
    override func setLemmaGroup(with lemmaBatch: LemmaBatch, forRow rowIndex: Int) {
        super.setLemmaGroup(with: lemmaBatch, forRow: rowIndex)
        baseButton.setTitle(headerText!.string, for: .normal)
        bodyLabel.setText(bodyText!)
        separatorView.isHidden = false
    }
    
    override func hideSeparator() {
        separatorView.isHidden = true
    }
}
