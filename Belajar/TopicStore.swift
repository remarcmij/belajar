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

    private let database: FMDatabase!
    
    static let sharedInstance = TopicStore()
    
    init() {
        let databasePath = Bundle.main().pathForResource("Topics", ofType: "sqlite")
        database = FMDatabase(path: databasePath)
        if !database.open() {
            fatalError("could not open Topics database")
        }
        print("Topics database opened")
    }
    
    deinit {
        if database != nil {
            database.close()
            print("Topics database closed")
        }
    }
    
    /// Returns an array for Topics representing "publications", i.e.
    /// with `chapter='index`
    func getCollection() -> [Topic] {
        let sql = "SELECT \(joinWithComma(Topic.fieldNames)) FROM Topics WHERE chapter='index'"
        return executeTopicQuery(sql, values: nil)
    }
    
    /// Returns an array for Topics for a given publication, representing its "topics".
    ///
    /// - Parameter publication: the name of the publication for which topics are
    ///   to be returned
    func getPublicationTopics(for publication: String) -> [Topic] {
        let sql = "SELECT \(joinWithComma(Topic.fieldNames)) FROM Topics WHERE chapter!='index' AND publication=?"
        return executeTopicQuery(sql, values: [publication])
    }
    
    func getArticle(withTopicId topicId: Int) -> Article? {
        let sql = "SELECT \(joinWithComma(Article.fieldNames)) FROM Articles WHERE topicId=?"
        let rs = try! database.executeQuery(sql, values: [topicId])
        if !rs.next() {
            return nil
        }
        return makeArticle(from: rs)
    }
    
    private func executeTopicQuery(_ sql: String, values: [AnyObject]!) -> [Topic] {
        var topics = [Topic]()
        let rs = try! database.executeQuery(sql + " ORDER BY sortIndex", values: values)
        while rs.next() == true {
            topics.append(makeTopic(from: rs))
        }
        return topics
    }
    
    private func makeTopic(from rs: FMResultSet) -> Topic {
        return Topic(
            id: Int(rs.int(forColumnIndex: 0)),
            fileName: rs.string(forColumnIndex: 1),
            publication: rs.string(forColumnIndex: 2),
            chapter: rs.string(forColumnIndex: 3),
            groupName: rs.string(forColumnIndex: 4),
            sortIndex: Int(rs.int(forColumnIndex: 5)),
            title: rs.string(forColumnIndex: 6),
            subtitle: rs.string(forColumnIndex: 7),
            author: rs.string(forColumnIndex: 8),
            publisher: rs.string(forColumnIndex: 9),
            pubDate: rs.string(forColumnIndex: 10),
            icon: rs.string(forColumnIndex: 11),
            lastModified: rs.string(forColumnIndex: 12))
    }
    
    private func makeArticle(from rs: FMResultSet) -> Article {
        return Article(
            id: Int(rs.int(forColumnIndex: 0)),
            topicId: Int(rs.int(forColumnIndex: 1)),
            foreignLang: rs.string(forColumnIndex: 2),
            nativeLang: rs.string(forColumnIndex: 3),
            style: rs.string(forColumnIndex: 4),
            mdText: rs.string(forColumnIndex: 5),
            htmlText: rs.string(forColumnIndex: 6))
    }
}
