//
//  ConsoleLoggerTests.swift
//  FrolloSDKTests
//
//  Created by Nick Dawson on 4/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import XCTest
@testable import FrolloSDK

import asl

class ConsoleLoggerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    private let consoleLogger = ConsoleLogger()
    
    func testDebugMessage() {
        consoleLogger.writeMessage("Test log message", level: .debug)
    }
    
    func testInfoMessage() {
        consoleLogger.writeMessage("Test log message", level: .info)
    }
    
    func testErrorMessage() {
        consoleLogger.writeMessage("Test log message", level: .error)
    }
    
    func testFaultMessage() {
        consoleLogger.writeMessage("Test log message", level: .fault)
    }
    
}
