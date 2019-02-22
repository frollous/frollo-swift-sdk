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
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + DeviceEndpoint.log.path)) { (request) -> OHHTTPStubsResponse in
            expectation1.fulfill()
            return OHHTTPStubsResponse(data: Data(), statusCode: 201, headers: nil)
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let logger = NetworkLogger(service: service)
        
        logger.writeMessage("Test Message", level: .error)
        
        wait(for: [expectation1], timeout: 3.0)
    }

}
