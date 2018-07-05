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
        removeDataFolder()
        
        let url = URL(string: "https://api.example.com")!
        
        _ = FrolloSDK(serverURL: url)
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: FrolloSDK.dataFolderURL.path))
    }
    
    func testSDKInitServerURLIsSet() {
        let url = URL(string: "https://api.example.com")!
        
        let sdk = FrolloSDK(serverURL: url)
        
        XCTAssertEqual(sdk.network.serverURL, url)
    }
    
    func testSDKSetupSuccess() {
        let url = URL(string: "https://api.example.com")!
        
        let sdk = FrolloSDK(serverURL: url)
        
        sdk.setup { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testSDKResetSuccess() {
        let url = URL(string: "https://api.example.com")!
        
        let sdk = FrolloSDK(serverURL: url)
        
        sdk.reset { (error) in
            XCTAssertNil(error)
        }
    }
    
}
