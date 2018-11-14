//
//  APIMessageResponseTests.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 15/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import XCTest
@testable import FrolloSDK

class APIMessageResponseTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEncoding() {
        let messageResponse = APIMessageResponse.testCompleteData()
        
        let encoder = JSONEncoder()
        
        do {
            let encodedMessage = try encoder.encode(messageResponse)
            
            let encodedMessageString = String(data: encodedMessage, encoding: .utf8)
            
            if let message = encodedMessageString {
                XCTAssertTrue(message.contains("\"id\":" +  String(messageResponse.id)))
            } else {
                XCTFail("Empty String")
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

}
