//
// Copyright © 2018 Frollo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
        
        XCTAssertTrue((TimeZone.current.abbreviation() == "AEST") || (TimeZone.current.abbreviation() == "GMT+10"), "Time zone doesn't match AEST - tests will fail. Dates are hard coded to AEST")
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
//        XCTAssertTrue((TimeZone.current.abbreviation() == "AEST") || (TimeZone.current.abbreviation() == "GMT+10"), "Time zone doesn't match AEST - tests will fail. Dates are hard coded to AEST")
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
