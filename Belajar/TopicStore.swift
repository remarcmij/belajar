//
//  TopicRepository.swift
//  Belajar
//
//  Created by Jim Cramer on 09/06/16.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import Foundation
import FMDB

class TopicStore {
    
    let database: FMDatabase
    
    init(path: String) {
        database = FMDatabase(path: path)
        if !database.open() {
            fatalError("could not open database at path: \(path)")
        }
        
        #if DEBUG
            print("succesfully opened database at path: \(path)")
        #endif
    }
    
    deinit {
        #if DEBUG
            print("closing database at path: \(database.databasePath())")
        #endif
        database.close()
    }
    
    func getAllTopics() -> [Topic] {
        let sql = "SELECT \(Util.joinWithComma(Topic.fieldNames)) FROM Topics"
        return executeTopicQuery(sql, values: nil)
    }
    
    /// Returns an array for Topics representing "publications", i.e.
    /// with `chapter='index`
    func getCollection() -> [Topic] {
        let sql = "SELECT \(Util.joinWithComma(Topic.fieldNames)) FROM Topics WHERE chapter='index'"
        return executeTopicQuery(sql, values: nil)
    }
    
    /// Returns an array for Topics for a given publication, representing its "topics".
    ///
    /// - Parameter publication: the name of the publication for which topics are
    ///   to be returned
    func getPublicationTopics(for publication: String) -> [Topic] {
        let sql = "SELECT \(Util.joinWithComma(Topic.fieldNames)) FROM Topics WHERE chapter!='index' AND publication=?"
        return executeTopicQuery(sql, values: [NSString(string: publication)])
    }
    
    func getArticle(withTopicId topicId: Int) -> Article? {
        let sql = "SELECT \(Util.joinWithComma(Article.fieldNames)) FROM Articles WHERE topicId=?"
        let rs = try! database.executeQuery(sql, values: [NSNumber(value:topicId)])
        if !rs.next() {
            return nil
        }
        return makeArticle(from: rs)
    }
    
    func executeTopicQuery(_ sql: String, values: [Any]!) -> [Topic] {
        var topics = [Topic]()
        let rs = try! database.executeQuery(sql + " ORDER BY sortIndex, title", values: values)
        while rs.next() == true {
            topics.append(makeTopic(from: rs))
        }
        return topics
    }
    
    func makeTopic(from rs: FMResultSet) -> Topic {
        return Topic(
            id: Int(rs.int(forColumnIndex: 0)),
            fileName: rs.string(forColumnIndex: 1),
            publication: rs.string(forColumnIndex: 2),
            part: rs.string(forColumnIndex: 3),
            chapter: rs.string(forColumnIndex: 4),
            groupName: rs.string(forColumnIndex: 5),
            sortIndex: Int(rs.int(forColumnIndex: 6)),
            title: rs.string(forColumnIndex: 7),
            subtitle: rs.string(forColumnIndex: 8),
            author: rs.string(forColumnIndex: 9),
            publisher: rs.string(forColumnIndex: 10),
            pubDate: rs.string(forColumnIndex: 11),
            isbn: rs.string(forColumnIndex: 12),
            topicHash: rs.string(forColumnIndex: 13),
            lastModified: rs.string(forColumnIndex: 14))
    }
    
    private func makeArticle(from rs: FMResultSet) -> Article {
        return Article(
            id: Int(rs.int(forColumnIndex: 0)),
            topicId: Int(rs.int(forColumnIndex: 1)),
            foreignLang: rs.string(forColumnIndex: 2),
            nativeLang: rs.string(forColumnIndex: 3),
            mdText: rs.string(forColumnIndex: 4),
            htmlText: rs.string(forColumnIndex: 5))
    }
}
