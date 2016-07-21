//
//  DictionaryPopoverController.swift
//  Belajar
//
//  Created by Jim Cramer on 12/07/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit

class DictionaryPopoverContainerView: UIView {
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touched popover content")
        // do nothing
    }
}

class DictionaryPopoverController: UIViewController {
    
    @IBOutlet private weak var contentView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let layer = contentView.layer
        layer.borderColor = UIColor.black().cgColor
        layer.borderWidth = 2
        layer.cornerRadius = 5
        layer.masksToBounds = true
        
        view.bounds.origin.x -= 10
        
        if view.traitCollection.userInterfaceIdiom == .pad {
            print("traitCollection: running on iPad")
        } else {
            print("traitCollection: running on iPhone")
        }
        
        if view.traitCollection.horizontalSizeClass == .regular {
            print("traitCollection: horizontal regular")
        } else {
            print("traitCollection: horizontal compact")
        }
        
        if view.traitCollection.verticalSizeClass == .regular {
            print("traitCollection: vertical regular")
        } else {
            print("traitCollection: vertical compact")
        }
    }
    
    @IBAction private func dismissPopover(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
}
