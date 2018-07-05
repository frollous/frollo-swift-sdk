//
//  FileLoggerTests.swift
//  FrolloSDKTests
//
//  Created by Nick Dawson on 4/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import XCTest
@testable import FrolloSDK

class FileLoggerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Clean any old log files
        purgeLogFiles()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        purgeLogFiles()
    }
    
    // MARK: - Helpers
    
    private func logPath() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory.appendingPathComponent("test.log")
    }
    
    private func previousLogPath() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory.appendingPathComponent("previous.log")
    }
    
    private func purgeLogFiles() {
        try? FileManager.default.removeItem(at: logPath())
        try? FileManager.default.removeItem(at: previousLogPath())
    }
    
    // MARK: - Tests
    
    func testLogFileCreatesFolderIfMissing() {
        // Delete the container folder
        let logTestPath = logPath()
        let previousTestPath = previousLogPath()
        let folderPath = logTestPath.deletingLastPathComponent()
        
        do {
            try FileManager.default.removeItem(at: folderPath)
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        let testMessage1 = "typewriter four loko tofu disrupt cornhole flexitarian hella"
        
        let fileLogger = FileLogger(path: logTestPath, previousPath: previousTestPath)
        
        fileLogger.writeMessage(testMessage1, level: .debug)
        
        do {
            let logContents = try String(contentsOf: logTestPath)
            
            XCTAssertEqual(testMessage1 + "\n", logContents)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testLogFileLogs() {
        let logTestPath = logPath()
        let previousTestPath = previousLogPath()
        let testMessage1 = "Lorem ipsum dolor amet kale chips offal raw denim humblebrag."
        let testMessage2 = "Man braid umami vegan kitsch raw denim dreamcatcher biodiesel fingerstache"
        let testMessage3 = "typewriter four loko tofu disrupt cornhole flexitarian hella"
        
        let fileLogger = FileLogger(path: logTestPath, previousPath: previousTestPath)
        
        fileLogger.writeMessage(testMessage1, level: .debug)
        fileLogger.writeMessage(testMessage2, level: .debug)
        fileLogger.writeMessage(testMessage3, level: .debug)
        
        do {
            let logContents = try String(contentsOf: logTestPath)
            
            XCTAssertEqual(testMessage1 + "\n" + testMessage2 + "\n" + testMessage3 + "\n", logContents)
        } catch {
            XCTFail("Log file not read")
        }
    }
    
    func testLogFileRotates() {
        let logTestPath = logPath()
        let previousTestPath = previousLogPath()
        let testMessage1 = "Lorem ipsum dolor amet kale chips offal raw denim humblebrag."
        let testMessage2 = "Man braid umami vegan kitsch raw denim dreamcatcher biodiesel fingerstache"
        let testMessage3 = "typewriter four loko tofu disrupt cornhole flexitarian hella"
        
        var fileLogger = FileLogger(path: logTestPath, previousPath: previousTestPath)
        
        fileLogger.writeMessage(testMessage1, level: .debug)
        
        do {
            let logContents = try String(contentsOf: logTestPath)
            
            XCTAssertEqual(testMessage1 + "\n", logContents)
        } catch {
            XCTFail("Log file not read")
        }
        
        fileLogger = FileLogger(path: logTestPath, previousPath: previousTestPath)
        
        fileLogger.writeMessage(testMessage2, level: .debug)
        
        do {
            let logContents = try String(contentsOf: logTestPath)
            
            XCTAssertEqual(testMessage2 + "\n", logContents)
        } catch {
            XCTFail("Log file not read")
        }
        
        do {
            let logContents = try String(contentsOf: previousTestPath)
            
            XCTAssertEqual(testMessage1 + "\n", logContents)
        } catch {
            XCTFail("Previous log file not read")
        }
        
        fileLogger = FileLogger(path: logTestPath, previousPath: previousTestPath)
        
        fileLogger.writeMessage(testMessage3, level: .debug)
        
        do {
            let logContents = try String(contentsOf: logTestPath)
            
            XCTAssertEqual(testMessage3 + "\n", logContents)
        } catch {
            XCTFail("Log file not read")
        }
        
        do {
            let logContents = try String(contentsOf: previousTestPath)
            
            XCTAssertEqual(testMessage2 + "\n", logContents)
        } catch {
            XCTFail("Previous log file not read")
        }
    }
    
}
