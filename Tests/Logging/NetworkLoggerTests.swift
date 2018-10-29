//
//  NetworkLoggerTests.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 29/10/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import XCTest

import OHHTTPStubs

@testable import FrolloSDK

class NetworkLoggerTests: XCTestCase {
    
    let keychainService = "NetworkLoggerKeychainService"

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLogging() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + DeviceEndpoint.log.path)) { (request) -> OHHTTPStubsResponse in
            expectation1.fulfill()
            return OHHTTPStubsResponse(data: Data(), statusCode: 201, headers: nil)
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        let logger = NetworkLogger(network: network)
        
        logger.writeMessage("Test Message", level: .fault)
        
        wait(for: [expectation1], timeout: 3.0)
    }

}
