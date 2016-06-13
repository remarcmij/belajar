//
//  Lemma.swift
//  Belajar
//
//  Created by Jim Cramer on 13/06/16.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import Foundation

struct Lemma {
    var id: Int
    var word: String
    var lang: String
    var attr: Character
    var groupName: String
    var dictOrder: Int
    var homonym: Int
    var text: String
    var base: String
    var baseLang: String
    
    static let fieldNames = [
        "id",
        "word",
        "lang",
        "attr",
        "groupName",
        "dictOrder",
        "homonym",
        "text",
        "base",
        "baseLang"
    ]
}