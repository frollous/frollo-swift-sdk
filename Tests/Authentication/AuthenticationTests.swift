//
//  AuthenticationTests.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 25/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import XCTest
@testable import FrolloSDK

import OHHTTPStubs

class AuthenticationTests: XCTestCase {
    
    private let keychain = Keychain(service: "AuthenticationTestsKeychain")
    private let serverURL = URL(string: "https://api.example.com")!
    
    private var authentication: Authentication!
    private var network: Network!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        keychain["refreshToken"] = "AnExistingRefreshToken"
        keychain["accessToken"] = "AnExistingAccessToken"
        keychain["accessTokenExpiry"] = String(Date(timeIntervalSinceNow: 1000).timeIntervalSince1970) // Not expired by time
        
        network = Network(serverURL: serverURL, keychain: keychain)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: - Helpers
    
    private func tempFolderPath() -> URL {
        var tempFolder = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        tempFolder.appendPathComponent(UUID().uuidString, isDirectory: true)
        
        try? FileManager.default.createDirectory(at: tempFolder, withIntermediateDirectories: true, attributes: nil)
        
        return tempFolder
    }
    
    // MARK: - Tests
    
    func testRefreshUser() {
        let expectation1 = expectation(description: "Network Request")
        
        stub(condition: isHost(serverURL.host!) && isPath("/" + UserEndpoint.details.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
        }
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let authentication = Authentication(database: database, network: network)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.refreshUser { (error) in
                XCTAssertNil(error)
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 5.0)
    }
    
}
