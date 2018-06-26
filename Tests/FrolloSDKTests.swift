//
//  FrolloSDKTests.swift
//  FrolloSDKTests
//
//  Created by Nick Dawson on 26/6/18.
//

import XCTest
@testable import FrolloSDK

class FrolloSDKTests: XCTestCase {
    
    private let sdk = FrolloSDK()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        XCTAssert(sdk.setup())
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
