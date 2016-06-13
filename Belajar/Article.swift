//
//  Article.swift
//  Belajar
//
//  Created by Jim Cramer on 09/06/16.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import Foundation

struct Article {
    var id: Int
    var topicId: Int
    var foreignLang: String
    var nativeLang: String
    var style: String?
    var mdText: String?
    var htmlText: String
    
    static let fieldNames = [
        "id",
        "topicId",
        "foreignLang",
        "nativeLang",
        "style",
        "mdText",
        "htmlText"
    ]
}