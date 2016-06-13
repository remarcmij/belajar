//
//  Topic.swift
//  Belajar
//
//  Created by Jim Cramer on 09/06/16.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import Foundation

struct Topic {
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
