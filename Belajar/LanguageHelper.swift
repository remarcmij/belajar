//
//  LanguageHelper.swift
//  Belajar
//
//  Created by Jim Cramer on 30/06/16.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import Foundation

protocol LanguageHelper {
    var substitutions: [String: String] {get}
    func getWordVariations(for word: String) -> [String]
}

extension LanguageHelper {

    func getWordVariations(for word: String) -> [String] {
        return [word]
    }
}

func getLanguageHelper(for lang: String) -> LanguageHelper {
    switch lang {
    case "id":
        return IndonesianLanguageHelper()
    case "nl":
        return DutchLanguageHelper()
    default:
        fatalError()
    }
}
