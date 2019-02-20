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
        let config = FrolloSDKConfiguration.testConfig()
        let sdk = FrolloSDK()
        sdk.setup(configuration: config) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    sdk.delegate = self
                    
                    XCTAssertTrue(sdk.messages.delegate === self)
                    XCTAssertTrue(sdk.events.delegate === self)
            }
        }
    }
    
    func testSettingDelegateBeforeSetup() {
        let config = FrolloSDKConfiguration.testConfig()
        let sdk = FrolloSDK()
        
        sdk.delegate = self
        
        sdk.setup(configuration: config) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    XCTAssertTrue(sdk.messages.delegate === self)
                    XCTAssertTrue(sdk.events.delegate === self)
            }
        }
    }
    
    func messageReceived(_ messageID: Int64) {
        // Stub
    }
    
    func eventTriggered(eventName: String) {
        // Stub
    }

}
