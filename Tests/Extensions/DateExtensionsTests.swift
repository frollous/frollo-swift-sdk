//
//  DateExtensionsTests.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 24/10/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import XCTest

@testable import FrolloSDK

class DateExtensionsTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testTimeZoneIsAEDT() {
        // AEDT is UTC +11
        
        XCTAssertEqual(TimeZone.current.abbreviation(), "AEDT", "Time zone doesn't match AEDT - tests will fail. Dates are hard coded to AEDT")
    }

    func testStartOfMonthAEDT() {
        let startMonthDate = Date(timeIntervalSince1970: 1538316000) // 1st October 2018 - 00:00
        let midMonthDate = Date(timeIntervalSince1970: 1540302825) // Weds 24th October 2018 - 11.54AM
        
        let startOfMonth = midMonthDate.startOfMonth()
        
        XCTAssertEqual(startMonthDate, startOfMonth)
    }
    
    func testStartOfLastMonthAEDT() {
        let startLastMonthDate = Date(timeIntervalSince1970: 1535724000) // 1st September 2018 - 00:00
        let midMonthDate = Date(timeIntervalSince1970: 1540302825) // Weds 24th October 2018 - 11.54AM
        
        let startOfLastMonth = midMonthDate.startOfLastMonth()
        
        XCTAssertEqual(startLastMonthDate, startOfLastMonth)
    }
    
    func testEndOfMonthAEDT() {
        let endMonthDate = Date(timeIntervalSince1970: 1540990800) // 1st September 2018 - 00:00
        let midMonthDate = Date(timeIntervalSince1970: 1540302825) // Weds 24th October 2018 - 11.54AM
        
        let endOfMonth = midMonthDate.endOfMonth()
        
        XCTAssertEqual(endMonthDate, endOfMonth)
    }
    
//    func testTimeZoneIsAEST() {
//        // AEST is UTC +10
//
//        XCTAssertEqual(TimeZone.current.abbreviation(), "AEST", "Time zone doesn't match AEST - tests will fail. Dates are hard coded to AEST")
//    }
//
//    func testStartOfMonthAEST() {
//        let startMonthDate = Date(timeIntervalSince1970: 1538312400) // 1st October 2018 - 00:00
//        let midMonthDate = Date(timeIntervalSince1970: 1540299225) // Weds 24th October 2018 - 11.54AM
//
//        let startOfMonth = midMonthDate.startOfMonth()
//
//        XCTAssertEqual(startMonthDate, startOfMonth)
//    }
//
//    func testStartOfLastMonthAEST() {
//        let startLastMonthDate = Date(timeIntervalSince1970: 1535720400) // 1st September 2018 - 00:00
//        let midMonthDate = Date(timeIntervalSince1970: 1540299225) // Weds 24th October 2018 - 11.54AM
//
//        let startOfLastMonth = midMonthDate.startOfLastMonth()
//
//        XCTAssertEqual(startLastMonthDate, startOfLastMonth)
//    }
//
//    func testEndOfMonthAEST() {
//        let endMonthDate = Date(timeIntervalSince1970: 1540987200) // 1st September 2018 - 00:00
//        let midMonthDate = Date(timeIntervalSince1970: 1540299225) // Weds 24th October 2018 - 11.54AM
//
//        let endOfMonth = midMonthDate.endOfMonth()
//
//        XCTAssertEqual(endMonthDate, endOfMonth)
//    }

}
