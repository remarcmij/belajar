//
//  Topic.swift
//  Belajar
//
//  Created by Jim Cramer on 09/06/16.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import Foundation

class Topic: NSObject, NSCoding {
    
    enum TopicError: Error {
        case InvalidJSONData(String)
    }
    
    var id: Int = -1
    let fileName: String
    let publication: String
    let part: String?
    let chapter: String
    let groupName: String
    let sortIndex: Int
    let title: String
    let subtitle: String?
    let author: String?
    let publisher: String?
    let pubDate: String?
    let isbn: String?
    let lastModified: String?
    
    var imageName: String {
        return "\(publication).jpg"
    }
    
    var values: [Any] {
        return [
            NSString(string: fileName),
            NSString(string: publication),
            part != nil ? NSString(string: part!) : NSNull(),
            NSString(string: chapter),
            NSString(string: groupName),
            NSNumber(value: sortIndex),
            NSString(string: title),
            subtitle != nil ? NSString(string: subtitle!) : NSNull(),
            author != nil ? NSString(string: author!) : NSNull(),
            publisher != nil ? NSString(string: publisher!) : NSNull(),
            pubDate != nil ? NSString(string: pubDate!) : NSNull(),
            isbn != nil ? NSString(string: isbn!) : NSNull(),
            lastModified != nil ? NSString(string: lastModified!) : NSNull()
        ]
    }
    
    init(id: Int, fileName: String, publication: String, part: String?, chapter: String, groupName: String,
         sortIndex: Int, title: String, subtitle: String?, author: String?, publisher: String?,
         pubDate: String?, isbn: String?, lastModified: String?) {
        self.id = id
        self.fileName = fileName
        self.publication = publication
        self.part = part
        self.chapter = chapter
        self.groupName = groupName
        self.sortIndex = sortIndex
        self.title = title
        self.subtitle = subtitle
        self.author = author
        self.publisher = publisher
        self.pubDate = pubDate
        self.isbn = isbn
        self.lastModified = lastModified
    }
    
    required init?(coder: NSCoder) {
        id = coder.decodeInteger(forKey: ColumnName.id.rawValue)
        fileName = coder.decodeObject(forKey: ColumnName.fileName.rawValue) as! String
        publication = coder.decodeObject(forKey: ColumnName.publication.rawValue) as! String
        part = coder.decodeObject(forKey: ColumnName.part.rawValue) as? String
        chapter = coder.decodeObject(forKey: ColumnName.chapter.rawValue) as! String
        groupName = coder.decodeObject(forKey: ColumnName.groupName.rawValue) as! String
        sortIndex = coder.decodeInteger(forKey: ColumnName.sortIndex.rawValue)
        title = coder.decodeObject(forKey: ColumnName.title.rawValue) as! String
        subtitle = coder.decodeObject(forKey: ColumnName.subtitle.rawValue) as? String
        author = coder.decodeObject(forKey: ColumnName.author.rawValue) as? String
        publisher = coder.decodeObject(forKey: ColumnName.publisher.rawValue) as? String
        pubDate = coder.decodeObject(forKey: ColumnName.pubDate.rawValue) as? String
        isbn = coder.decodeObject(forKey: ColumnName.isbn.rawValue) as? String
        lastModified = coder.decodeObject(forKey: ColumnName.lastModified.rawValue) as? String
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: ColumnName.id.rawValue)
        coder.encode(fileName, forKey: ColumnName.fileName.rawValue)
        coder.encode(publication, forKey: ColumnName.publication.rawValue)
        coder.encode(part, forKey: ColumnName.part.rawValue)
        coder.encode(chapter, forKey: ColumnName.chapter.rawValue)
        coder.encode(groupName, forKey: ColumnName.groupName.rawValue)
        coder.encode(sortIndex, forKey: ColumnName.sortIndex.rawValue)
        coder.encode(title, forKey: ColumnName.title.rawValue)
        coder.encode(subtitle, forKey: ColumnName.subtitle.rawValue)
        coder.encode(author, forKey: ColumnName.author.rawValue)
        coder.encode(publisher, forKey: ColumnName.publisher.rawValue)
        coder.encode(pubDate, forKey: ColumnName.pubDate.rawValue)
        coder.encode(isbn, forKey: ColumnName.isbn.rawValue)
        coder.encode(lastModified, forKey: ColumnName.lastModified.rawValue)
    }
    
    enum ColumnName: String {
        case id, fileName, publication, part, chapter, groupName, sortIndex,
        title, subtitle, author, publisher, pubDate, isbn, lastModified
    }
    
    static let fieldNames = [
        ColumnName.id.rawValue,
        ColumnName.fileName.rawValue,
        ColumnName.publication.rawValue,
        ColumnName.part.rawValue,
        ColumnName.chapter.rawValue,
        ColumnName.groupName.rawValue,
        ColumnName.sortIndex.rawValue,
        ColumnName.title.rawValue,
        ColumnName.subtitle.rawValue,
        ColumnName.author.rawValue,
        ColumnName.publisher.rawValue,
        ColumnName.pubDate.rawValue,
        ColumnName.isbn.rawValue,
        ColumnName.lastModified.rawValue
    ]
    
    static func create(fromJSONObject json: [String: Any]) -> Topic? {
        
        guard let fileName = json["filename"] as? String,
            let publication = json["publication"] as? String,
            let chapter = json["chapter"] as? String,
            let groupName = json["group"] as? String,
            let sortIndex = json["sortindex"] as? Int,
            let title = json["title"] as? String,
            let lastModified = json["lastmodified"] as? String
            else {
                return nil
        }
        
        let part = json["part"] as? String
        let subtitle = json["subtitle"] as? String
        let author = json["author"] as? String
        let publisher = json["publisher"] as? String
        let pubDate = json["pubdate"] as? String
        let isbn = json["isbn"] as? String
        
        return Topic(id: -1,
                     fileName: fileName,
                     publication: publication,
                     part: part,
                     chapter: chapter,
                     groupName: groupName,
                     sortIndex: sortIndex,
                     title: title,
                     subtitle: subtitle,
                     author: author,
                     publisher: publisher,
                     pubDate: pubDate,
                     isbn: isbn,
                     lastModified: lastModified)
    }
}
