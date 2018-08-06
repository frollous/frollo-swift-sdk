//
//  NetworkAuthenticatorTests.swift
//  FrolloSDKTests
//
//  Created by Nick Dawson on 17/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import XCTest
@testable import FrolloSDK

import Alamofire
import OHHTTPStubs

class NetworkAuthenticatorTests: XCTestCase {
    
    private let keychainService = "NetworkAuthenticatorTestsKeychain"

    override func setUp() {
        super.setUp()
        
        
    }
    
    override func tearDown() {
        super.tearDown()
        
        OHHTTPStubs.removeAllStubs()
        Keychain(service: keychainService).removeAll()
    }
    
    // MARK: - Token Refresh Tests
    
    func testTokensPersist() {
        let keychain = Keychain(service: keychainService)
        
        let url = URL(string: "https://api.example.com")!
        
        let refreshToken = "AnExistingRefreshToken"
        let accessToken = "AnExistingAccessToken"
        let expiryDateString = "1721259268.0"
        let expiryDate = Date(timeIntervalSince1970: 1721259268)
        
        var network =  Network(serverURL: url, keychain: keychain)
        network.authenticator.saveTokens(refresh: refreshToken, access: accessToken, expiry: expiryDate)
        
        XCTAssertEqual(keychain["accessToken"], accessToken)
        XCTAssertEqual(keychain["refreshToken"], refreshToken)
        XCTAssertEqual(keychain["accessTokenExpiry"], expiryDateString)
        
        network = Network(serverURL: url, keychain: keychain)
        
        XCTAssertEqual(network.authenticator.accessToken, accessToken)
        XCTAssertEqual(network.authenticator.refreshToken, refreshToken)
        XCTAssertEqual(network.authenticator.expiryDate, expiryDate)
    }
    
    func testForceRefreshingAccessTokens() {
        let expectation1 = expectation(description: "API Response")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + DeviceEndpoint.refreshToken.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "refresh_token_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.refreshToken { (json, error) in
            XCTAssertNil(error)
            XCTAssertEqual(network.authenticator.accessToken, "AValidAccessTokenFromHost")
            XCTAssertEqual(network.authenticator.refreshToken, "AValidRefreshTokenFromHost")
            XCTAssertEqual(network.authenticator.expiryDate, Date(timeIntervalSince1970: 1721259268))
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        OHHTTPStubs.removeAllStubs()
        keychain.removeAll()
    }
    
    func testForceRefreshingInvalidAccessTokens() {
        let expectation1 = expectation(description: "API Response")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + DeviceEndpoint.refreshToken.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "refresh_token_invalid", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.refreshToken { (json, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(network.authenticator.accessToken)
            XCTAssertNil(network.authenticator.refreshToken)
            XCTAssertNil(network.authenticator.expiryDate)
            
            if let dataError = error as? DataError {
                XCTAssertEqual(dataError.type, .authentication)
                XCTAssertEqual(dataError.subType, .missingAccessToken)
            } else {
                XCTFail("Wrong type of error")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        OHHTTPStubs.removeAllStubs()
        keychain.removeAll()
    }
    
    func testPreemptiveAccessTokenRefresh() {
        let expectation1 = expectation(description: "API Response")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + DeviceEndpoint.refreshToken.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "refresh_token_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
        }
        stub(condition: isHost(url.host!) && isPath("/" + UserEndpoint.details.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
        }
        
        let keychain = Keychain(service: keychainService)
        keychain["refreshToken"] = "AnExistingRefreshToken"
        keychain["accessToken"] = "AnExistingAccessToken"
        keychain["accessTokenExpiry"] = String(Date(timeIntervalSinceNow: 30).timeIntervalSince1970) // 30 seconds in the future falls within the 5 minute access token expiry
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchUser { (json, error) in
            XCTAssertNil(error)
            XCTAssertEqual(network.authenticator.accessToken, "AValidAccessTokenFromHost")
            XCTAssertEqual(network.authenticator.refreshToken, "AValidRefreshTokenFromHost")
            XCTAssertEqual(network.authenticator.expiryDate, Date(timeIntervalSince1970: 1721259268))
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        OHHTTPStubs.removeAllStubs()
        keychain.removeAll()
    }
    
    func testInvalidAccessTokenRefresh() {
        let expectation1 = expectation(description: "API Response")
        
        let url = URL(string: "https://api.example.com")!
        
        var failedOnce = false
        
        stub(condition: isHost(url.host!) && isPath("/" + DeviceEndpoint.refreshToken.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "refresh_token_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
        }
        stub(condition: isHost(url.host!) && isPath("/" + UserEndpoint.details.path)) { (request) -> OHHTTPStubsResponse in
            if failedOnce {
                return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
            } else {
                failedOnce = true
                return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "error_invalid_access_token", ofType: "json")!, status: 401, headers: [Network.HTTPHeader.contentType: "application/json"])
            }
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchUser { (json, error) in
            XCTAssertNil(error)
            XCTAssertEqual(network.authenticator.accessToken, "AValidAccessTokenFromHost")
            XCTAssertEqual(network.authenticator.refreshToken, "AValidRefreshTokenFromHost")
            XCTAssertEqual(network.authenticator.expiryDate, Date(timeIntervalSince1970: 1721259268))
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        OHHTTPStubs.removeAllStubs()
        keychain.removeAll()
    }
    
    func testInvalidRefreshTokenFails() {
        let expectation1 = expectation(description: "API Response")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + UserEndpoint.details.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "error_invalid_refresh_token", ofType: "json")!, status: 401, headers: [Network.HTTPHeader.contentType: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchUser { (json, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(network.authenticator.accessToken)
            XCTAssertNil(network.authenticator.refreshToken)
            XCTAssertNil(network.authenticator.expiryDate)
            
            if let apiError = error as? APIError {
                XCTAssertEqual(apiError.type, .invalidRefreshToken)
            } else {
                XCTFail("Error is of wrong type")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        OHHTTPStubs.removeAllStubs()
        keychain.removeAll()
    }
    
    // MARK: - Retry Tests
    
    func testRequestsGetRetriedAfterRefreshingAccessToken() {
        let expectation1 = expectation(description: "API Response 1")
        let expectation2 = expectation(description: "API Response 2")
        let expectation3 = expectation(description: "API Response 3")
        
        let url = URL(string: "https://api.example.com")!
        
        var userRequestCount = 0
        
        stub(condition: isHost(url.host!) && isPath("/" + DeviceEndpoint.refreshToken.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "refresh_token_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
        }
        stub(condition: isHost(url.host!) && isPath("/" + UserEndpoint.details.path)) { (request) -> OHHTTPStubsResponse in
            let fix: OHHTTPStubsResponse
            if userRequestCount < 3 {
                fix = fixture(filePath: Bundle(for: type(of: self)).path(forResource: "error_invalid_access_token", ofType: "json")!, status: 401, headers: [Network.HTTPHeader.contentType: "application/json"])
            } else {
                fix = fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
            }
            userRequestCount += 1
            return fix
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchUser { (json, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(json)
            XCTAssertEqual(network.authenticator.accessToken, "AValidAccessTokenFromHost")
            XCTAssertEqual(network.authenticator.refreshToken, "AValidRefreshTokenFromHost")
            XCTAssertEqual(network.authenticator.expiryDate, Date(timeIntervalSince1970: 1721259268))
            
            expectation1.fulfill()
        }
        network.fetchUser { (json, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(json)
            
            expectation2.fulfill()
        }
        network.fetchUser { (json, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(json)
            
            expectation3.fulfill()
        }
        
        wait(for: [expectation1, expectation2, expectation3], timeout: 5.0)
        
        OHHTTPStubs.removeAllStubs()
        keychain.removeAll()
    }
    
    func testRequestsGetCancelledAfterRefreshingAccessTokenFails() {
        let expectation1 = expectation(description: "API Response 1")
        let expectation2 = expectation(description: "API Response 2")
        let expectation3 = expectation(description: "API Response 3")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + DeviceEndpoint.refreshToken.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "error_invalid_refresh_token", ofType: "json")!, status: 401, headers: [Network.HTTPHeader.contentType: "application/json"])
        }
        stub(condition: isHost(url.host!) && isPath("/" + UserEndpoint.details.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "error_invalid_access_token", ofType: "json")!, status: 401, headers: [Network.HTTPHeader.contentType: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchUser { (json, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(json)
            XCTAssertNil(network.authenticator.accessToken)
            XCTAssertNil(network.authenticator.refreshToken)
            XCTAssertNil(network.authenticator.expiryDate)
            
            expectation1.fulfill()
        }
        network.fetchUser { (json, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(json)
            
            expectation2.fulfill()
        }
        network.fetchUser { (json, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(json)
            
            expectation3.fulfill()
        }
        
        wait(for: [expectation1, expectation2, expectation3], timeout: 5.0)
        
        OHHTTPStubs.removeAllStubs()
        keychain.removeAll()
    }
    
    func testRateLimitRetries() {
        // TODO: Add more of these
        let expectation1 = expectation(description: "API Response 1")
        
        let url = URL(string: "https://api.example.com")!
        
        var rateLimited = true
        
        stub(condition: isHost(url.host!) && isPath("/" + UserEndpoint.details.path)) { (request) -> OHHTTPStubsResponse in
            if rateLimited {
                rateLimited = false
                return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, status: 429, headers: [Network.HTTPHeader.contentType: "application/json"])
            } else {
                return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
            }
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchUser { (json, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(json)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 15.0)
        
        OHHTTPStubs.removeAllStubs()
        keychain.removeAll()
    }
    
    // MARK: - Adapter Header Tests
    
    func testOTPHeaderAppendedToRegistrationRequest() {
        // TODO: Write this test after OTP feature
    }
    
    func testOTPHeaderAppendedToResetPasswordRequest() {
        // TODO: Write this test after OTP feature
    }
    
    func testAccessTokenHeaderAppendedToHostRequests() {
        let url = URL(string: "https://api.example.com")!
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        let userURL = URL(string: UserEndpoint.details.path, relativeTo: url)!
        let request = network.sessionManager.request(userURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
        do {
            let adaptedRequest = try network.authenticator.adapt(request.request!)
            
            if let authorizationHeader = adaptedRequest.value(forHTTPHeaderField: Network.HTTPHeader.authorization) {
                XCTAssertEqual(authorizationHeader, "Bearer AnExistingAccessToken")
            } else {
                XCTFail("No auth header")
            }
            
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        keychain.removeAll()
    }
    
    func testRefreshTokenHeaderAppendedToRefreshRequests() {
        let url = URL(string: "https://api.example.com")!
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        let refreshURL = URL(string: DeviceEndpoint.refreshToken.path, relativeTo: url)!
        let request = network.sessionManager.request(refreshURL, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: nil)
        do {
            let adaptedRequest = try network.authenticator.adapt(request.request!)
            
            if let authorizationHeader = adaptedRequest.value(forHTTPHeaderField: Network.HTTPHeader.authorization) {
                XCTAssertEqual(authorizationHeader, "Bearer AnExistingRefreshToken")
            } else {
                XCTFail("No auth header")
            }
            
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        keychain.removeAll()
    }
    
    func testNoHeaderAppendedToLoginRequest() {
        let url = URL(string: "https://api.example.com")!
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        let userURL = URL(string: UserEndpoint.login.path, relativeTo: url)!
        let request = network.sessionManager.request(userURL, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: nil)
        do {
            let adaptedRequest = try network.authenticator.adapt(request.request!)
            
            XCTAssertNil(adaptedRequest.value(forHTTPHeaderField: Network.HTTPHeader.authorization))
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        keychain.removeAll()
    }
    
    func testNoHeaderAppendedToExternalHostRequests() {
        let url = URL(string: "https://api.example.com")!
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        let userURL = URL(string: "https://google.com.au")!
        let request = network.sessionManager.request(userURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
        do {
            let adaptedRequest = try network.authenticator.adapt(request.request!)
            
            XCTAssertNil(adaptedRequest.value(forHTTPHeaderField: Network.HTTPHeader.authorization))
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        keychain.removeAll()
    }
    
    
    
}