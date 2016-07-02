//
//  LanguageHelperTests.swift
//  Belajar
//
//  Created by Jim Cramer on 01/07/16.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import XCTest
@testable import Belajar

class IndonesianLanguageHelperTests: XCTestCase {

    var helper: LanguageHelper!
    
    override func setUp() {
        super.setUp()
        helper = IndonesianLanguageHelper()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testVariationsDipakai() {
        let result = helper.getWordVariations(for: "dipakai")
        XCTAssertEqual(result, ["dipakai", "memakai"])
    }
    
    func testVariationsHarganya() {
        let result = helper.getWordVariations(for: "harganya")
        XCTAssertEqual(result, ["harganya", "harga"])
        
    }
    
    func testVariationsDibukanya() {
        let result = helper.getWordVariations(for: "dibukanya")
        XCTAssertEqual(result, ["dibukanya", "dibuka", "membuka", "membukanya"])
    }

    func testVariationsDiperbaiki() {
        let result = helper.getWordVariations(for: "diperbaiki")
        XCTAssertEqual(result, ["diperbaiki", "memperbaiki"])
    }
    
    func testVariationsTandatangi() {
        let result = helper.getWordVariations(for: "tandatanangi")
        XCTAssertEqual(result, ["tandatanangi", "menandatanangi"])
    }
    
    func testVariationsBersihkan() {
        let result = helper.getWordVariations(for: "bersihkan")
        XCTAssertEqual(result, ["bersihkan", "membersihkan"])
    }
    
    func testVariationsDuduklah() {
        let result = helper.getWordVariations(for: "duduklah")
        XCTAssertEqual(result, ["duduklah", "duduk"])
    }
    
    func testVariationSekalikali() {
        let result = helper.getWordVariations(for: "sekali-kali")
        XCTAssertEqual(result, ["sekali-kali", "sekali", "menyekali-kali", "menyekali", "kali-kali", "kali"])
        
    }

}
