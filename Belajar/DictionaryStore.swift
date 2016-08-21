//
//  DictionaryStore.swift
//  Belajar
//
//  Created by Jim Cramer on 13/06/16.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import Foundation
import FMDB


typealias AutoCompleteItem = (word: String, lang: String)

private let autoCompleteLimit = 100

final class DictionaryStore {
    private let database: FMDatabase
    
    static let sharedInstance = DictionaryStore()
    
    init() {
        let databasePath = Bundle.main.path(forResource: "Dictionary", ofType: "sqlite")
        database = FMDatabase(path: databasePath)
        if !database.open() {
            fatalError("could not open Dictionary database")
        }
        print("Dictionary database opened")
        
    }
    
    deinit {
        database.close()
        print("Dictionary database closed")
    }
    
    func autoCompleteSearch(term: String, lang: String?) -> [AutoCompleteItem] {
        let languageHelper = getLanguageHelper(for: Constants.ForeignLang)
        let wordVariations = languageHelper.getWordVariations(for: term)
        
        for variation in wordVariations {
            let results = autoCompleteSearchTerm(term: variation, lang: lang)
            if results.count > 0 {
                return results
            }
        }
        
        return [AutoCompleteItem]()
    }
    
    private func autoCompleteSearchTerm(term: String, lang: String?) -> [AutoCompleteItem] {
        
        var values: [Any] = [term]
        values.append(makeStopTerm(term: term))
        
        let sql = NSMutableString()
        sql.setString("SELECT word, lang FROM AutoComplete WHERE word>=? AND word<?")
        if lang != nil {
            sql.append(" AND lang=?")
            values.append(lang!)
        }
        sql.append(" ORDER BY word, lang LIMIT \(autoCompleteLimit);")
        
        let rs = try! database.executeQuery(sql as String!, values: values)
        var results = [AutoCompleteItem]()
        
        while rs.next() == true {
            results.append((word: rs.string(forColumnIndex: 0), lang: rs.string(forColumnIndex: 1)))
        }
        rs.close()
        return results
    }
    
    
//    private func makeStopTerm(term: String) -> String {
//        let text = NSMutableString()
//        text.setString(term)
//        let lastIndex = text.length - 1
//        
//        let lastCharPlusOne = text.character(at: lastIndex) + 1
//        return text.substring(to: lastIndex).append(lastCharPlusOne)
//    }
    
    private func makeStopTerm(term: String) -> String {
        let utf16Chars = term.utf16
        let lastChar = Character(UnicodeScalar(utf16Chars.last! + 1)!)
        return String(describing: utf16Chars.dropLast()) + String(lastChar)
    }

    func search(word: String, lang: String? = nil, attr: String? = nil) -> [Lemma] {
        var values: [Any] = [word]
        
        var sql = "SELECT \(Util.joinWithComma(Lemma.fieldNames)) FROM DictView WHERE word=?"
        if let lang = lang {
            sql += " AND lang=?"
            values.append(lang)
        }
        if let attr = attr {
            sql += " AND attr=?"
            values.append(attr)
        }
        
        let startTime = Date()
        let rs = try! database.executeQuery(sql, values: values)
        let endTime = Date()
        let elapsed = endTime.timeIntervalSince(startTime) * 1000
        
        var lemmas = [Lemma]()
        while rs.next() == true {
            lemmas.append(Lemma.makeLemma(fromResultSet: rs))
        }
        rs.close()
        print("search for \(word) took \(elapsed) ms")
        
        return lemmas
    }
    
    func lookupWord(word: String, lang: String = Constants.ForeignLang) -> ([Lemma], String)? {
        let languageHelper = getLanguageHelper(for: lang)
        let wordVariations = languageHelper.getWordVariations(for: word)
        
        for variation in wordVariations {
            let lemmas = search(word: variation, lang: lang, attr: "k")
            if lemmas.count != 0 {
                return (lemmas, variation)
            }
        }
        
        return nil
    }
}
