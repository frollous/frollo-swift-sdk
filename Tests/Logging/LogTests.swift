//
//  LogTests.swift
//  FrolloSDKTests
//
//  Created by Nick Dawson on 4/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import XCTest
@testable import FrolloSDK

class LogTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        try? FileManager.default.removeItem(at: logPath())
        try? FileManager.default.removeItem(at: previousLogPath())
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        try? FileManager.default.removeItem(at: logPath())
        try? FileManager.default.removeItem(at: previousLogPath())
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
    
    private func typesOfLoggerIn(_ loggers: [Logger]) -> (console: Bool, file: Bool, network: Bool) {
        var consoleLoggerFound = false
        var fileLoggerFound = false
        var networkLoggerFound = false
        for logger in loggers {
            if logger is ConsoleLogger {
                consoleLoggerFound = true
            } else if logger is FileLogger {
                fileLoggerFound = true
            } else if logger is NetworkLogger {
                networkLoggerFound = true
            }
        }
        
        return (consoleLoggerFound, fileLoggerFound, networkLoggerFound)
    }
    
    // MARK: - Tests
    
    func testGlobalLogDebug() {
        Log.debug("Log test message")
    }
    
    func testGlobalLogInfo() {
        Log.info("Log test message")
    }
    
    func testGlobalLogError() {
        Log.error("Log test message")
    }
    
    func testDebugLogLevel() {
        Log.logLevel = .debug
        
        XCTAssertGreaterThan(Log.manager.debugLoggers.count, 0)
        let typesOfDebugLogger = typesOfLoggerIn(Log.manager.debugLoggers)
        XCTAssertTrue(typesOfDebugLogger.console)
        XCTAssertFalse(typesOfDebugLogger.file)
        XCTAssertFalse(typesOfDebugLogger.network)
        
        XCTAssertGreaterThan(Log.manager.infoLoggers.count, 0)
        let typesOfInfoLogger = typesOfLoggerIn(Log.manager.infoLoggers)
        XCTAssertTrue(typesOfInfoLogger.console)
        XCTAssertFalse(typesOfInfoLogger.file)
        XCTAssertFalse(typesOfInfoLogger.network)
        
        XCTAssertGreaterThan(Log.manager.errorLoggers.count, 0)
        let typesOfErrorLogger = typesOfLoggerIn(Log.manager.errorLoggers)
        XCTAssertTrue(typesOfErrorLogger.console)
        XCTAssertTrue(typesOfErrorLogger.file)
        XCTAssertTrue(typesOfErrorLogger.network)
    }
    
    func testInfoLogLevel() {
        Log.logLevel = .info
        
        XCTAssertEqual(Log.manager.debugLoggers.count, 0)
        
        XCTAssertGreaterThan(Log.manager.infoLoggers.count, 0)
        let typesOfInfoLogger = typesOfLoggerIn(Log.manager.infoLoggers)
        XCTAssertTrue(typesOfInfoLogger.console)
        XCTAssertFalse(typesOfInfoLogger.file)
        XCTAssertFalse(typesOfInfoLogger.network)
        
        XCTAssertGreaterThan(Log.manager.errorLoggers.count, 0)
        let typesOfErrorLogger = typesOfLoggerIn(Log.manager.errorLoggers)
        XCTAssertTrue(typesOfErrorLogger.console)
        XCTAssertTrue(typesOfErrorLogger.file)
        XCTAssertTrue(typesOfErrorLogger.network)
    }
    
    func testErrorLogLevel() {
        Log.logLevel = .error
        
        XCTAssertEqual(Log.manager.debugLoggers.count, 0)
        
        XCTAssertEqual(Log.manager.infoLoggers.count, 0)
        
        XCTAssertGreaterThan(Log.manager.errorLoggers.count, 0)
        let typesOfErrorLogger = typesOfLoggerIn(Log.manager.errorLoggers)
        XCTAssertTrue(typesOfErrorLogger.console)
        XCTAssertTrue(typesOfErrorLogger.file)
        XCTAssertTrue(typesOfErrorLogger.network)
    }
    
    func testDebugLogSync() {
        testLog(level: .debug, async: false)
    }
    
    func testDebugLogAsync() {
        testLog(level: .debug, async: true)
    }
    
    func testInfoLogSync() {
        testLog(level: .info, async: false)
    }
    
    func testInfoLogAsync() {
        testLog(level: .info, async: true)
    }
    
    func testErrorLogSync() {
        testLog(level: .error, async: false)
    }
    
    func testErrorLogAsync() {
        testLog(level: .error, async: true)
    }
    
    func testLog(level: LogLevel, async: Bool) {
        let logFilePath = logPath()
        let fileLogger = FileLogger(path: logFilePath, previousPath: previousLogPath())
        
        let testMessage1 = "Lorem ipsum dolor amet kale chips offal raw denim humblebrag."
        let testMessage2 = "Man braid umami vegan kitsch raw denim dreamcatcher biodiesel fingerstache"
        let testMessage3 = "typewriter four loko tofu disrupt cornhole flexitarian hella"
        
        let log = Log(synchronous: !async)
        
        switch level {
        case .debug:
            log.debugLoggers = [fileLogger]
            log.debugLog(testMessage1)
            log.debugLog(testMessage2)
            log.debugLog(testMessage3)
        case .info:
            log.infoLoggers = [fileLogger]
            log.infoLog(testMessage1)
            log.infoLog(testMessage2)
            log.infoLog(testMessage3)
        case .error:
            log.errorLoggers = [fileLogger]
            log.errorLog(testMessage1)
            log.errorLog(testMessage2)
            log.errorLog(testMessage3)
        }
        
        if async {
            let expectation1 = expectation(description: "Async Queue Processed")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                do {
                    let logContents = try String(contentsOf: logFilePath)
                    
                    XCTAssertEqual(testMessage1 + "\n" + testMessage2 + "\n" + testMessage3 + "\n", logContents)
                } catch {
                    XCTFail("Log file not read")
                }
                
                expectation1.fulfill()
            }
            
            wait(for: [expectation1], timeout: 1.0)
        } else {
            do {
                let logContents = try String(contentsOf: logFilePath)
                
                XCTAssertEqual(testMessage1 + "\n" + testMessage2 + "\n" + testMessage3 + "\n", logContents)
            } catch {
                XCTFail("Log file not read")
            }
        }
    }
    
    
    
}
