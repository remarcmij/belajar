//
//  UIKitExtensions.swift
//  Belajar
//
//  Created by Jim Cramer on 21/07/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit

extension UIViewController {
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.viewControllers.first ?? self
        } else {
            return self
        }
    }
}
