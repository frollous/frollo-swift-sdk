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
