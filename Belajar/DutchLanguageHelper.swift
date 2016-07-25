//
//  File.swift
//  Belajar
//
//  Created by Jim Cramer on 30/06/16.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import Foundation

struct DutchLanguageHelper : LanguageHelper {
    
    var substitutions: [String: String] {
        return [
            "...": "puntje puntje puntje",
            "bijv.": "bijvoorbeeld",
            "meerv.": "meervoud",
            "enz.": "enzovoorts",
            "iem.": "iemand"
        ]
    }
}
