//
//  LemmaBodyCell.swift
//  Belajar
//
//  Created by Jim Cramer on 21/07/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class LemmaBodyCell: LemmaBaseCell {

    @IBOutlet weak var bodyLabel: TTTAttributedLabel! {
        didSet {
            bodyLabel.delegate = self
            bodyLabel.linkAttributes = LemmaBaseCell.linkAttributes
        }
    }
    
    override func setLemmaText(with lemmaHomonym: LemmaHomonym, forRow rowIndex: Int) {
        super.setLemmaText(with: lemmaHomonym, forRow: rowIndex)
        bodyLabel.setText(bodyText!)
    }
}
