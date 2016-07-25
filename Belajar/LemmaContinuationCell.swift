 //
//  LemmaBodyCell.swift
//  Belajar
//
//  Created by Jim Cramer on 21/07/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class LemmaContinuationCell: LemmaCell {

    @IBOutlet weak var bodyLabel: TTTAttributedLabel! {
        didSet {
            bodyLabel.delegate = self
            bodyLabel.linkAttributes = LemmaCell.linkAttributes
        }
    }
    
    override func setLemmaGroup(with lemmaBatch: LemmaBatch, forRow rowIndex: Int) {
        super.setLemmaGroup(with: lemmaBatch, forRow: rowIndex)
        bodyLabel.setText(bodyText!)
    }
}
