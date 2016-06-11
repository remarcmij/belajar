//
//  TopicRepository.swift
//  Belajar
//
//  Created by Jim Cramer on 09/06/16.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import Foundation
import FMDB

class TopicRepository {
    enum Error: ErrorType {
        case OpenError(String)
    }
    
    private let database: FMDatabase!
    
    static let sharedInstance = TopicRepository()
    
    init() {
        let databasePath = NSBundle.mainBundle().pathForResource("Topics", ofType: "sqlite3")
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
    
    func getPublications() -> [Topic] {
        let sql = "SELECT \(joinWithComma(Topic.fieldNames)) FROM Topics WHERE Chapter='index'"
        return executeTopicQuery(sql, values: nil)
    }
    
    func getTopicsFor(publication: String) -> [Topic] {
        let sql = "SELECT \(joinWithComma(Topic.fieldNames)) FROM Topics WHERE Chapter!='index' AND Publication=?"
        return executeTopicQuery(sql, values: [publication])
    }
    
    func getArticle(topicId: Int) -> Article? {
        let sql = "SELECT \(joinWithComma(Article.fieldNames)) FROM Articles WHERE TopicID=?"
        let rs = try! database.executeQuery(sql, values: [topicId])
        if !rs.next() {
            return nil
        }
        return articleFromResultSet(rs)
    }
    
    private func executeTopicQuery(sql: String, values: [AnyObject]!) -> [Topic] {
        var topics = [Topic]()
        let rs = try! database.executeQuery(sql + " ORDER BY SortIndex", values: values)
        while rs.next() == true {
            topics.append(topicFromResultSet(rs))
        }
        return topics
    }
    
    private func topicFromResultSet(rs: FMResultSet) -> Topic {
        return Topic(
            id: Int(rs.intForColumnIndex(0)),
            filename: rs.stringForColumnIndex(1),
            publication: rs.stringForColumnIndex(2),
            chapter: rs.stringForColumnIndex(3),
            groupName: rs.stringForColumnIndex(4),
            sortIndex: Int(rs.intForColumnIndex(5)),
            title: rs.stringForColumnIndex(6),
            subtitle: rs.stringForColumnIndex(7),
            author: rs.stringForColumnIndex(8),
            publisher: rs.stringForColumnIndex(9),
            pubDate: rs.stringForColumnIndex(10),
            icon: rs.stringForColumnIndex(11),
            lastModified: rs.stringForColumnIndex(12))
    }
    
    private func articleFromResultSet(rs: FMResultSet) -> Article {
        return Article(
            id: Int(rs.intForColumnIndex(0)),
            topicId: Int(rs.intForColumnIndex(1)),
            foreignLang: rs.stringForColumnIndex(2),
            nativeLang: rs.stringForColumnIndex(3),
            style: rs.stringForColumnIndex(4),
            mdText: rs.stringForColumnIndex(5),
            htmlText: rs.stringForColumnIndex(6))
    }
}