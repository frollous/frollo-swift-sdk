//
//  DeviceInfoTests.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 27/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import XCTest
@testable import FrolloSDK

class DeviceInfoTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDeviceInfoValid() {
        let currentDevice = DeviceInfo.current()
        
        XCTAssertNotEqual(currentDevice.deviceID, "Unknown")
        XCTAssertNotEqual(currentDevice.deviceName, "Unknown")
        XCTAssertNotEqual(currentDevice.deviceType, "Unknown")
        
        #if os(macOS)
        XCTAssertTrue(currentDevice.deviceType.contains("Mac"))
        #elseif os(iOS)
        XCTAssertTrue(currentDevice.deviceType.contains("iPhone") || currentDevice.deviceType.contains("iPad") || currentDevice.deviceType.contains("iPod") || currentDevice.deviceType.contains("x86_64"))
        #elseif os(tvOS)
        XCTAssertTrue(currentDevice.deviceType.contains("AppleTV") || currentDevice.deviceType.contains("x86_64"))
        #elseif os(watchOS)
        XCTAssertTrue(currentDevice.deviceType.contains("Watch"))
        #endif
        
    }
    
}
