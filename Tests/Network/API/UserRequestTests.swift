//
//  UserRequestTests.swift
//  FrolloSDKTests
//
//  Created by Nick Dawson on 13/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import XCTest
@testable import FrolloSDK

class UserRequestTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLogin() {
        let serverURL = URL(string: "https://api.example.com")!
        
        let network = Network(serverURL: serverURL)
        
        
    }
    
}
