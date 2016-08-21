//
//  FlashCardViewController.swift
//  Belajar
//
//  Created by Jim Cramer on 17/08/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit

protocol FlashCardViewControllerDelegate: class {
    func textTapped(forPagenumber: Int)
}

class FlashCardViewController: UIViewController {

    @IBOutlet weak private var cardBorderView: UIView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var indicatorView: UIImageView!
    
    static let foreignColor = UIColor(netHex: 0x303F9F)
    
    private struct AssetCatalog {
        static let frontIndicatorImage = "Card Front Indicator"
        static let backIndicatorImage = "Card Back Indicator"
    }
    
    var pageNumber = 0
    var delegate: FlashCardViewControllerDelegate?
    
    var cardText: String! {
        didSet {
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicatorView.sizeToFit()
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(textTapped))
        textLabel.addGestureRecognizer(recognizer)
        updateUI()
   }
    
    func textTapped() {
        delegate?.textTapped(forPagenumber: pageNumber)
    }
    
    private func updateUI() {
        textLabel?.text = (cardText as NSString).replacingOccurrences(of: "_", with: "")
        
        let imageName: String
        let textColor: UIColor
        
        if pageNumber % 2 == 0 {
            imageName = AssetCatalog.frontIndicatorImage
            textColor = type(of: self).foreignColor
        } else {
            imageName = AssetCatalog.backIndicatorImage
            textColor = UIColor.black
        }
        
        textLabel?.textColor = textColor
        indicatorView?.image = UIImage(named: imageName)
    }
}
