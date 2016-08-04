//
//  Topic.swift
//  Belajar
//
//  Created by Jim Cramer on 09/06/16.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import Foundation

class Topic: NSObject, NSCoding {
    let id: Int
    let fileName: String
    let publication: String
    let chapter: String
    let groupName: String
    let sortIndex: Int
    let title: String
    let subtitle: String?
    let author: String?
    let publisher: String?
    let pubDate: String?
    let lastModified: String
    
    var imageName: String {
        return "\(publication).png"
    }
    
    init(id: Int, fileName: String, publication: String, chapter: String, groupName: String,
         sortIndex: Int, title: String, subtitle: String?, author: String?, publisher: String?,
         pubDate: String?, lastModified: String) {
        self.id = id
        self.fileName = fileName
        self.publication = publication
        self.chapter = chapter
        self.groupName = groupName
        self.sortIndex = sortIndex
        self.title = title
        self.subtitle = subtitle
        self.author = author
        self.publisher = publisher
        self.pubDate = pubDate
        self.lastModified = lastModified
    }
    
    required init?(coder: NSCoder) {
        id = coder.decodeInteger(forKey: ColumnName.id.rawValue)
        fileName = coder.decodeObject(forKey: ColumnName.fileName.rawValue) as! String
        publication = coder.decodeObject(forKey: ColumnName.publication.rawValue) as! String
        chapter = coder.decodeObject(forKey: ColumnName.chapter.rawValue) as! String
        groupName = coder.decodeObject(forKey: ColumnName.groupName.rawValue) as! String
        sortIndex = coder.decodeInteger(forKey: ColumnName.sortIndex.rawValue)
        title = coder.decodeObject(forKey: ColumnName.title.rawValue) as! String
        subtitle = coder.decodeObject(forKey: ColumnName.subtitle.rawValue) as? String
        author = coder.decodeObject(forKey: ColumnName.author.rawValue) as? String
        publisher = coder.decodeObject(forKey: ColumnName.publisher.rawValue) as? String
        pubDate = coder.decodeObject(forKey: ColumnName.pubDate.rawValue) as? String
        lastModified = coder.decodeObject(forKey: ColumnName.lastModified.rawValue) as! String
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: ColumnName.id.rawValue)
        coder.encode(fileName, forKey: ColumnName.fileName.rawValue)
        coder.encode(publication, forKey: ColumnName.publication.rawValue)
        coder.encode(chapter, forKey: ColumnName.chapter.rawValue)
        coder.encode(groupName, forKey: ColumnName.groupName.rawValue)
        coder.encode(sortIndex, forKey: ColumnName.sortIndex.rawValue)
        coder.encode(title, forKey: ColumnName.title.rawValue)
        coder.encode(author, forKey: ColumnName.author.rawValue)
        coder.encode(publisher, forKey: ColumnName.publisher.rawValue)
        coder.encode(pubDate, forKey: ColumnName.pubDate.rawValue)
        coder.encode(lastModified, forKey: ColumnName.lastModified.rawValue)
    }
    
    enum ColumnName: String {
        case id, fileName, publication, chapter, groupName, sortIndex,
        title, subtitle, author, publisher, pubDate, icon, lastModified
    }
    
    static let fieldNames = [
        ColumnName.id.rawValue,
        ColumnName.fileName.rawValue,
        ColumnName.publication.rawValue,
        ColumnName.chapter.rawValue,
        ColumnName.groupName.rawValue,
        ColumnName.sortIndex.rawValue,
        ColumnName.title.rawValue,
        ColumnName.subtitle.rawValue,
        ColumnName.author.rawValue,
        ColumnName.publisher.rawValue,
        ColumnName.pubDate.rawValue,
        ColumnName.lastModified.rawValue
    ]
}
