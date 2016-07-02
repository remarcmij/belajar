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
    private let database: FMDatabase
    
    static let sharedInstance = DictionaryStore()
    
    init() {
        let databasePath = Bundle.main().pathForResource("Dictionary", ofType: "sqlite")
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
    
    func search(word: String, lang: String? = nil, attr: String? = nil) -> [Lemma] {
        var values: [AnyObject] = [word]
        
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
            lemmas.append(self.dynamicType.makeLemma(fromResultSet: rs))
        }
        print("search query for \(word) took \(elapsed) ms")
        
        return lemmas
    }
    
    static func makeLemma(fromResultSet rs: FMResultSet) -> Lemma {
        return Lemma(id: Int(rs.int(forColumnIndex: 0)),
                     word: rs.string(forColumnIndex: 1),
                     lang: rs.string(forColumnIndex: 2),
                     attr: rs.string(forColumnIndex: 3).characters.first!,
                     groupName: rs.string(forColumnIndex: 4),
                     dictOrder: Int(rs.int(forColumnIndex: 5)),
                     homonym: Int(rs.int(forColumnIndex: 6)),
                     text: rs.string(forColumnIndex: 7),
                     base: rs.string(forColumnIndex: 8),
                     baseLang: rs.string(forColumnIndex: 9))
    }
}
