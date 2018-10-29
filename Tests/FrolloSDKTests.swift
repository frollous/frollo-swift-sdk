//
//  FrolloSDKTests.swift
//  FrolloSDKTests
//
//  Created by Nick Dawson on 26/6/18.
//

import XCTest
@testable import FrolloSDK

class FrolloSDKTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: - Helpers
    
    func removeDataFolder() {
        // Remove app data folder from disk
        try? FileManager.default.removeItem(atPath: FrolloSDK.dataFolderURL.path)
    }
    
    // MARK: - Tests
    
    func testSDKCreatesDataFolder() {
        let expectation1 = expectation(description: "Setup")
        
        removeDataFolder()
        
        let url = URL(string: "https://api.example.com")!
        
        let sdk = FrolloSDK()
        sdk.setup(serverURL: url) { (error) in
            XCTAssertNil(error)
            XCTAssertTrue(FileManager.default.fileExists(atPath: FrolloSDK.dataFolderURL.path))
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testSDKInitServerURLIsSet() {
        let expectation1 = expectation(description: "Setup")
        
        let url = URL(string: "https://api.example.com")!
        
        let sdk = FrolloSDK()
        sdk.setup(serverURL: url) { (error) in
            XCTAssertNil(error)
            XCTAssertEqual(sdk.network.serverURL, url)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testSDKSetupSuccess() {
        let expectation1 = expectation(description: "Setup")
        
        let url = URL(string: "https://api.example.com")!
        
        let sdk = FrolloSDK()
        sdk.setup(serverURL: url) { (error) in
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testSDKResetSuccess() {
        let expectation1 = expectation(description: "Setup")
        
        let url = URL(string: "https://api.example.com")!

        let sdk = FrolloSDK()
        sdk.setup(serverURL: url) { (error) in
            XCTAssertNil(error)
            
            sdk.reset { (error) in
                XCTAssertNil(error)
                XCTAssertFalse(sdk.setup)
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testPauseScheduledRefresh() {
        let expectation1 = expectation(description: "Setup")
        
        let url = URL(string: "https://api.example.com")!
        
        let sdk = FrolloSDK()
        sdk.setup(serverURL: url) { (error) in
            XCTAssertNil(error)
            
            sdk.applicationDidEnterBackground()
            
            XCTAssertNil(sdk.refreshTimer)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testResumeScheduledRefresh() {
        let expectation1 = expectation(description: "Setup")
        
        let url = URL(string: "https://api.example.com")!
        
        let sdk = FrolloSDK()
        sdk.setup(serverURL: url) { (error) in
            XCTAssertNil(error)
            
            sdk.applicationWillEnterForeground()
            
            XCTAssertNotNil(sdk.refreshTimer)
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
}
