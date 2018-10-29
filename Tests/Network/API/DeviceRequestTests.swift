//
//  DeviceRequestTests.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 25/10/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import XCTest

import OHHTTPStubs

@testable import FrolloSDK

class DeviceRequestTests: XCTestCase {
    
    private let keychainService = "DeviceRequestTests"

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRefreshTokens() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + DeviceEndpoint.refreshToken.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "refresh_token_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.refreshToken { (response, error) in
            XCTAssertNil(error)
            
            XCTAssertNotNil(network.authenticator.refreshToken)
            XCTAssertNotNil(network.authenticator.accessToken)
            
            let persistedKeychain = Keychain(service: self.keychainService)
            XCTAssertNotNil(persistedKeychain["refreshToken"])
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        OHHTTPStubs.removeAllStubs()
    }
    
    func testLog() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + DeviceEndpoint.log.path)) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 201, headers: nil)
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        let request = APILogRequest(details: "Details Content", message: "Log message", score: .error)
        
        network.createLog(request: request) { (response, error) in
            XCTAssertNil(error)
            XCTAssertNil(response)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        OHHTTPStubs.removeAllStubs()
    }

}
