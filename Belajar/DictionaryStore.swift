//
//  DictionaryStore.swift
//  Belajar
//
//  Created by Jim Cramer on 13/06/16.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import Foundation
import FMDB

class DictionaryStore {
    private let database: FMDatabase!
    
    static let sharedInstance = DictionaryStore()
    
    init() {
        let databasePath = NSBundle.mainBundle().pathForResource("Dictionary", ofType: "sqlite")
        database = FMDatabase(path: databasePath)
        if !database.open() {
            fatalError("could not open Dictionary database")
        }
        print("Dictionary database opened")
        
    }
    
    deinit {
        if database != nil {
            database.close()
            print("Dictionary database closed")
        }
    }
    
    func searchWord(word: String, withLang lang: String? = nil, andAttr attr: String? = nil) -> FMResultSet {
        var values: [AnyObject] = [word]
        
        var sql = "SELECT \(joinWithComma(Lemma.fieldNames)) FROM DictView WHERE word=?"
        if let lang = lang {
            sql += " AND lang=?"
            values.append(lang)
        }
        if let attr = attr {
            sql += " AND attr=?"
            values.append(attr)
        }

        let startTime = NSDate()
        let rs = try! database.executeQuery(sql, values: values)
        let endTime = NSDate()

        let elapsed = endTime.timeIntervalSinceDate(startTime) * 1000
        print("search query for \(word) took \(elapsed) ms")
        
        return rs
    }
    
    static func lemmaFromResultSet(rs: FMResultSet) -> Lemma {
        return Lemma(id: Int(rs.intForColumnIndex(0)),
                     word: rs.stringForColumnIndex(1),
                     lang: rs.stringForColumnIndex(2),
                     attr: rs.stringForColumnIndex(3).characters.first!,
                     groupName: rs.stringForColumnIndex(4),
                     dictOrder: Int(rs.intForColumnIndex(5)),
                     homonym: Int(rs.intForColumnIndex(6)),
                     text: rs.stringForColumnIndex(7),
                     base: rs.stringForColumnIndex(8),
                     baseLang: rs.stringForColumnIndex(9))
    }
}