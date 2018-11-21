//
//  FrolloSDKDelegateTests.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 21/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import XCTest
@testable import FrolloSDK

class FrolloSDKDelegateTests: XCTestCase, FrolloSDKDelegate {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSettingDelegateUpdatesModules() {
        let url = URL(string: "https://api.example.com")!
        
        let sdk = FrolloSDK()
        
        sdk.setup(serverURL: url) { (error) in
            XCTAssertNil(error)
            
            sdk.delegate = self
            
            XCTAssertTrue(sdk.messages.delegate === self)
            XCTAssertTrue(sdk.events.delegate === self)
        }
    }
    
    func testSettingDelegateBeforeSetup() {
        let url = URL(string: "https://api.example.com")!
        
        let sdk = FrolloSDK()
        
        sdk.delegate = self
        
        sdk.setup(serverURL: url) { (error) in
            XCTAssertNil(error)
            
            XCTAssertTrue(sdk.messages.delegate === self)
            XCTAssertTrue(sdk.events.delegate === self)
        }
    }
    
    func messageReceived(_ messageID: Int64) {
        // Stub
    }
    
    func eventTriggered(eventName: String) {
        // Stub
    }

}
