//
//  Topic.swift
//  Belajar
//
//  Created by Jim Cramer on 09/06/16.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import Foundation

class Topic: NSObject {
    var id: Int = -1
    var fileName: String
    var publication: String
    var chapter: String
    var groupName: String
    var sortIndex: Int
    var title: String
    var subtitle: String?
    var author: String?
    var publisher: String?
    var pubDate: String?
    var icon: String?
    var lastModified: String
    
    init(id: Int, fileName: String, publication: String, chapter: String, groupName: String,
         sortIndex: Int, title: String, subtitle: String?, author: String?, publisher: String?,
         pubDate: String?, icon: String?, lastModified: String) {
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
        self.icon = icon
        self.lastModified = lastModified
        
        super.init()
    }
    
    static let fieldNames = [
        "id",
        "fileName",
        "publication",
        "chapter",
        "groupName",
        "sortIndex",
        "title",
        "subTitle",
        "author",
        "publisher",
        "pubDate",
        "icon",
        "lastModified"
    ]
}
