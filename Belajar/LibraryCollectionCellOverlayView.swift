//
//  DogEarView.swift
//  Belajar
//
//  Created by Jim Cramer on 04/08/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit


@IBDesignable
class LibraryCollectionCellOverlayView: UIView {

    @IBInspectable var dogEarWidth: CGFloat = 50.0
    @IBInspectable var alphaForFill: CGFloat = 1.0
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        let lowerRightCorner = CGPoint(x: bounds.size.width, y: bounds.size.height)
        path.move(to: lowerRightCorner)
        path.addLine(to: CGPoint(x: lowerRightCorner.x - CGFloat(dogEarWidth), y: lowerRightCorner.y))
        path.addLine(to: CGPoint(x: lowerRightCorner.x, y: lowerRightCorner.y - CGFloat(dogEarWidth)))
        path.close()
        UIColor.black.setFill()
        path.fill(with: .normal, alpha: CGFloat(alphaForFill))
    }
}
