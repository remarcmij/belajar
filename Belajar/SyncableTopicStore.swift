//
//  WritableTopicStore.swift
//  Belajar
//
//  Created by Jim Cramer on 28/08/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import Foundation

private let createTopicsTableSql = "CREATE TABLE IF NOT EXISTS Topics (\n"
    + "id INTEGER PRIMARY KEY AUTOINCREMENT,\n"
    + "fileName TEXT UNIQUE,\n"
    + "publication TEXT NOT NULL,\n"
    + "part TEXT DEFAULT NULL,\n"
    + "chapter TEXT NOT NULL,\n"
    + "groupName TEXT NOT NULL,\n"
    + "sortIndex NUMBER NOT NULL,\n"
    + "title TEXT NOT NULL,\n"
    + "subtitle TEXT DEFAULT NULL,\n"
    + "author TEXT DEFAULT NULL,\n"
    + "publisher TEXT DEFAULT NULL,\n"
    + "pubDate TEXT DEFAULT NULL,\n"
    + "isbn TEXT DEFAULT NULL,\n"
    + "lastModified TEXT)"

private let createArticlesTableSql = "CREATE TABLE IF NOT EXISTS Articles (\n"
    + "id INTEGER PRIMARY KEY AUTOINCREMENT,\n"
    + "topicId INTEGER UNIQUE,\n"
    + "foreignLang TEXT NOT NULL,\n"
    + "nativeLang TEXT NOT NULL,\n"
    + "style TEXT DEFAULT NULL,\n"
    + "mdText TEXT DEFAULT NULL,\n"
    + "htmlText TEXT NOT NULL)"

private let deleteArticleSql = "DELETE FROM Articles WHERE topicId=?"

private let insertArticleSql = "INSERT INTO Articles "
    + "(topicId,foreignLang,nativeLang,style,mdText,htmlText) "
    + "VALUES(?,?,?,?,?,?)"

private let insertTopicSql = "INSERT INTO Topics "
    + "(fileName,publication,part,chapter,groupName,sortIndex,title,"
    + "subtitle,author,publisher,pubDate,isbn,lastModified) "
    + "VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)"

private let updateTopicSql = "UPDATE Topics SET "
    + "fileName=?,"
    + "publication=?,"
    + "part=?,"
    + "chapter=?,"
    + "groupName=?,"
    + "sortIndex=?,"
    + "title=?,"
    + "subtitle=?,"
    + "author=?,"
    + "publisher=?,"
    + "pubDate=?,"
    + "isbn=?,"
    + "lastModified=?"
    + " WHERE id=?"

private let deleteTopicSql = "DELETE FROM Topics WHERE id=?"

class SyncableTopicStore: TopicStore {
    
    override init(path: String) {
        super.init(path: path)
    }
    
    func createTables() -> Bool {
        return database.executeStatements(createTopicsTableSql) &&
            database.executeStatements(createArticlesTableSql)
    }
    
    func upsert(topic: Topic, article: Article?) {
        guard database.beginTransaction()
            else { return }
        
        do {
            // article may or may not exist
            database.executeUpdate(deleteArticleSql, withArgumentsIn: [NSNumber(value: topic.id)])
            
            if topic.id != -1 {
                var values = topic.values
                values.append(NSNumber(value: topic.id))
                try database.executeUpdate(updateTopicSql, values: values)
            } else {
                try database.executeUpdate(insertTopicSql, values: topic.values)
                topic.id = Int(database.lastInsertRowId())
            }
            
            if article != nil {
                article!.topicId = topic.id
                try database.executeUpdate(insertArticleSql, values: article!.values)
            }
            
            database.commit()
            
        } catch {
            database.rollback()
            print(error)
        }
    }
    
    func delete(topic: Topic) {
        guard database.beginTransaction()
            else { return }
        
        do {
            try database.executeUpdate(deleteArticleSql, values: [NSNumber(value: topic.id)])
            try database.executeUpdate(deleteTopicSql, values: [NSNumber(value: topic.id)])
            database.commit()
        } catch {
            database.rollback()
            print(error)
        }
    }
    
    
}
