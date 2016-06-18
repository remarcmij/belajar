//
//  Util.swift
//  Belajar
//
//  Created by Jim Cramer on 09/06/16.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import Foundation

func joinWithComma(_ fieldNames: [String], omitNames: Set<String> = []) -> String {
    return fieldNames
        .filter {fieldName in !omitNames.contains(fieldName)}
        .joined(separator: ",")
}
