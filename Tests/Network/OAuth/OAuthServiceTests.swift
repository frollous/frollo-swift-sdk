//
//  OAuthServiceTests.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 22/2/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import XCTest
@testable import FrolloSDK

import OHHTTPStubs

class OAuthServiceTests: XCTestCase {
    
    private let keychainService = "TokenRequestTests"

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        Keychain(service: keychainService).removeAll()
        OHHTTPStubs.removeAllStubs()
    }

    func testTokenRequestValid() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.tokenEndpoint.host!) && isPath(config.tokenEndpoint.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "token_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authService = OAuthService(tokenEndpoint: config.tokenEndpoint, network: network)
        
        let loginRequest = OAuthTokenRequest.testLoginValidData()
        
        authService.refreshTokens(request: loginRequest) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.accessToken, "MTQ0NjJkZmQ5OTM2NDE1ZTZjNGZmZjI3")
                    XCTAssertEqual(response.createdAt, Date(timeIntervalSince1970: 2550792999))
                    XCTAssertEqual(response.expiresIn, 1800)
                    XCTAssertEqual(response.refreshToken, "IwOGYzYTlmM2YxOTQ5MGE3YmNmMDFkNTVk")
                    XCTAssertEqual(response.tokenType, "Bearer")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        OHHTTPStubs.removeAllStubs()
    }
    
    func testTokenRequestInvalid() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.tokenEndpoint.host!) && isPath(config.tokenEndpoint.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "token_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authService = OAuthService(tokenEndpoint: config.tokenEndpoint, network: network)
        
        let loginRequest = OAuthTokenRequest.testLoginInvalidData()
        
        authService.refreshTokens(request: loginRequest) { (result) in
            switch result {
            case .failure:
                break
            case .success:
                XCTFail("Token request was invalid so should fail")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        OHHTTPStubs.removeAllStubs()
    }

}