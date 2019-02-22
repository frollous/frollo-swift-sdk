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

class NetworkAuthenticatorTests: XCTestCase, AuthenticationDelegate {
    
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
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let refreshToken = "AnExistingRefreshToken"
        let accessToken = "AnExistingAccessToken"
        let expiryDateString = "1721259268.0"
        let expiryDate = Date(timeIntervalSince1970: 1721259268)
        
        var networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        networkAuthenticator.saveTokens(refresh: refreshToken, access: accessToken, expiry: expiryDate)
        var network =  Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        var service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        XCTAssertEqual(keychain["accessToken"], accessToken)
        XCTAssertEqual(keychain["refreshToken"], refreshToken)
        XCTAssertEqual(keychain["accessTokenExpiry"], expiryDateString)
        
        networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        XCTAssertEqual(service.network.authenticator.accessToken, accessToken)
        XCTAssertEqual(service.network.authenticator.refreshToken, refreshToken)
        XCTAssertEqual(service.network.authenticator.expiryDate, expiryDate)
    }
    
    func testForceRefreshingAccessTokens() {
        let expectation1 = expectation(description: "API Response")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.tokenEndpoint.host!) && isPath(config.tokenEndpoint.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "token_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authService = OAuthService(tokenEndpoint: config.tokenEndpoint, network: network)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let authentication = Authentication(database: database, clientID: config.clientID, domain: config.serverEndpoint.host!, networkAuthenticator: networkAuthenticator, authService: authService, service: service, preferences: preferences, delegate: self)
        
        authentication.refreshTokens { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    XCTAssertEqual(service.network.authenticator.accessToken, "MTQ0NjJkZmQ5OTM2NDE1ZTZjNGZmZjI3")
                    XCTAssertEqual(service.network.authenticator.refreshToken, "IwOGYzYTlmM2YxOTQ5MGE3YmNmMDFkNTVk")
                    XCTAssertEqual(service.network.authenticator.expiryDate, Date(timeIntervalSince1970: 2550794799))
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        OHHTTPStubs.removeAllStubs()
        keychain.removeAll()
    }
    
    func testForceRefreshingInvalidAccessTokens() {
        let expectation1 = expectation(description: "API Response")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.tokenEndpoint.host!) && isPath(config.tokenEndpoint.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "token_invalid", ofType: "json")!, status: 401, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authService = OAuthService(tokenEndpoint: config.tokenEndpoint, network: network)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let authentication = Authentication(database: database, clientID: config.clientID, domain: config.serverEndpoint.host!, networkAuthenticator: networkAuthenticator, authService: authService, service: service, preferences: preferences, delegate: self)
        
        authentication.refreshTokens { (result) in
            switch result {
                case .failure(let error):
                    XCTAssertNil(service.network.authenticator.accessToken)
                    XCTAssertNil(service.network.authenticator.refreshToken)
                    XCTAssertNil(service.network.authenticator.expiryDate)
                    
                    if let dataError = error as? DataError {
                        XCTAssertEqual(dataError.type, .authentication)
                        XCTAssertEqual(dataError.subType, .missingAccessToken)
                    } else {
                        XCTFail("Wrong type of error")
                    }
                case .success:
                    XCTFail("Invalid refresh token should not have succeeded")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        OHHTTPStubs.removeAllStubs()
        keychain.removeAll()
    }
    
    func testPreemptiveAccessTokenRefresh() {
        let expectation1 = expectation(description: "API Response")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.tokenEndpoint.host!) && isPath(config.tokenEndpoint.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "token_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.details.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain(service: keychainService)
        keychain["refreshToken"] = "AnExistingRefreshToken"
        keychain["accessToken"] = "AnExistingAccessToken"
        keychain["accessTokenExpiry"] = String(Date(timeIntervalSinceNow: 30).timeIntervalSince1970) // 30 seconds in the future falls within the 5 minute access token expiry
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authService = OAuthService(tokenEndpoint: config.tokenEndpoint, network: network)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let authentication = Authentication(database: database, clientID: config.clientID, domain: config.serverEndpoint.host!, networkAuthenticator: networkAuthenticator, authService: authService, service: service, preferences: preferences, delegate: self)
        
        service.fetchUser { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    XCTAssertEqual(service.network.authenticator.accessToken, "MTQ0NjJkZmQ5OTM2NDE1ZTZjNGZmZjI3")
                    XCTAssertEqual(service.network.authenticator.refreshToken, "IwOGYzYTlmM2YxOTQ5MGE3YmNmMDFkNTVk")
                    XCTAssertEqual(service.network.authenticator.expiryDate, Date(timeIntervalSince1970: 2550794799))
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 5.0)
        
        OHHTTPStubs.removeAllStubs()
        keychain.removeAll()
    }
    
    func testInvalidAccessTokenRefresh() {
        let expectation1 = expectation(description: "API Response")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        var failedOnce = false
        
        stub(condition: isHost(config.tokenEndpoint.host!) && isPath(config.tokenEndpoint.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "token_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.details.path)) { (request) -> OHHTTPStubsResponse in
            if failedOnce {
                return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
            } else {
                failedOnce = true
                return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "error_invalid_access_token", ofType: "json")!, status: 401, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
            }
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authService = OAuthService(tokenEndpoint: config.tokenEndpoint, network: network)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let authentication = Authentication(database: database, clientID: config.clientID, domain: config.serverEndpoint.host!, networkAuthenticator: networkAuthenticator, authService: authService, service: service, preferences: preferences, delegate: self)
        
        service.fetchUser { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    XCTAssertEqual(service.network.authenticator.accessToken, "MTQ0NjJkZmQ5OTM2NDE1ZTZjNGZmZjI3")
                    XCTAssertEqual(service.network.authenticator.refreshToken, "IwOGYzYTlmM2YxOTQ5MGE3YmNmMDFkNTVk")
                    XCTAssertEqual(service.network.authenticator.expiryDate, Date(timeIntervalSince1970: 2550794799))
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        OHHTTPStubs.removeAllStubs()
        keychain.removeAll()
    }
    
    func testInvalidRefreshTokenFails() {
        let expectation1 = expectation(description: "API Response")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.details.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "error_invalid_refresh_token", ofType: "json")!, status: 401, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authService = OAuthService(tokenEndpoint: config.tokenEndpoint, network: network)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let authentication = Authentication(database: database, clientID: config.clientID, domain: config.serverEndpoint.host!, networkAuthenticator: networkAuthenticator, authService: authService, service: service, preferences: preferences, delegate: self)
        
        service.fetchUser { (result) in
            switch result {
                case .failure(let error):
                    XCTAssertNil(service.network.authenticator.accessToken)
                    XCTAssertNil(service.network.authenticator.refreshToken)
                    XCTAssertNil(service.network.authenticator.expiryDate)
                    
                    if let apiError = error as? APIError {
                        XCTAssertEqual(apiError.type, .invalidRefreshToken)
                    } else {
                        XCTFail("Error is of wrong type")
                    }
                case .success:
                    XCTFail("Invalid token should fail")
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
        
        let config = FrolloSDKConfiguration.testConfig()
        
        var userRequestCount = 0
        
        stub(condition: isHost(config.tokenEndpoint.host!) && isPath(config.tokenEndpoint.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "token_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.details.path)) { (request) -> OHHTTPStubsResponse in
            let fix: OHHTTPStubsResponse
            if userRequestCount < 3 {
                fix = fixture(filePath: Bundle(for: type(of: self)).path(forResource: "error_invalid_access_token", ofType: "json")!, status: 401, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
            } else {
                fix = fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
            }
            userRequestCount += 1
            return fix
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authService = OAuthService(tokenEndpoint: config.tokenEndpoint, network: network)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let authentication = Authentication(database: database, clientID: config.clientID, domain: config.serverEndpoint.host!, networkAuthenticator: networkAuthenticator, authService: authService, service: service, preferences: preferences, delegate: self)
        
        service.fetchUser { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    XCTAssertEqual(service.network.authenticator.accessToken, "MTQ0NjJkZmQ5OTM2NDE1ZTZjNGZmZjI3")
                    XCTAssertEqual(service.network.authenticator.refreshToken, "IwOGYzYTlmM2YxOTQ5MGE3YmNmMDFkNTVk")
                    XCTAssertEqual(service.network.authenticator.expiryDate, Date(timeIntervalSince1970: 2550794799))
            }
            
            expectation1.fulfill()
        }
        service.fetchUser { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation2.fulfill()
        }
        service.fetchUser { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
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
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.tokenEndpoint.host!) && isPath(config.tokenEndpoint.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "error_invalid_refresh_token", ofType: "json")!, status: 401, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.details.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "error_invalid_access_token", ofType: "json")!, status: 401, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authService = OAuthService(tokenEndpoint: config.tokenEndpoint, network: network)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let authentication = Authentication(database: database, clientID: config.clientID, domain: config.serverEndpoint.host!, networkAuthenticator: networkAuthenticator, authService: authService, service: service, preferences: preferences, delegate: self)
        
        service.fetchUser { (result) in
            switch result {
                case .failure:
                    XCTAssertNil(service.network.authenticator.accessToken)
                    XCTAssertNil(service.network.authenticator.refreshToken)
                    XCTAssertNil(service.network.authenticator.expiryDate)
                case .success:
                    XCTFail("Request should fail")
            }
            
            expectation1.fulfill()
        }
        service.fetchUser { (result) in
            switch result {
                case .failure:
                    break
                case .success:
                    XCTFail("Request should fail")
            }
            
            expectation2.fulfill()
        }
        service.fetchUser { (result) in
            switch result {
                case .failure:
                    break
                case .success:
                    XCTFail("Request should fail")
            }
            
            expectation3.fulfill()
        }
        
        wait(for: [expectation1, expectation2, expectation3], timeout: 5.0)
        
        OHHTTPStubs.removeAllStubs()
        keychain.removeAll()
    }
    
    func testRateLimitRetries() {
        // TODO: Add more of these
        let expectation1 = expectation(description: "API Response 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        var rateLimited = true
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.details.path)) { (request) -> OHHTTPStubsResponse in
            if rateLimited {
                rateLimited = false
                return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, status: 429, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
            } else {
                return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
            }
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        service.fetchUser { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 15.0)
        
        OHHTTPStubs.removeAllStubs()
        keychain.removeAll()
    }
    
    // MARK: - Adapter Header Tests
    
    func testOTPHeaderAppendedToRegistrationRequest() {
        let config = FrolloSDKConfiguration.testConfig()
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let bundleID = "us.frollo.FrolloSDK"
        let seed = String(repeating: bundleID, count: 2)
        
        let generator = OTP(factor: .timer(period: 30), secret: seed.data(using: .utf8)!, algorithm: .sha256, digits: 8)
        let password = try! generator?.password(at: Date())
        let bearer = String(format: "Bearer %@", password!)
        
        let userURL = URL(string: UserEndpoint.register.path, relativeTo: config.serverEndpoint)!
        let request = network.sessionManager.request(userURL, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: nil)
        do {
            let adaptedRequest = try service.network.authenticator.adapt(request.request!)
            
            if let authorizationHeader = adaptedRequest.value(forHTTPHeaderField:  HTTPHeader.authorization.rawValue) {
                XCTAssertEqual(authorizationHeader, bearer)
            } else {
                XCTFail("No auth header")
            }
            
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        keychain.removeAll()
    }
    
    func testOTPHeaderAppendedToResetPasswordRequest() {
        let config = FrolloSDKConfiguration.testConfig()
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let bundleID = "us.frollo.FrolloSDK"
        let seed = String(repeating: bundleID, count: 2)
        
        let generator = OTP(factor: .timer(period: 30), secret: seed.data(using: .utf8)!, algorithm: .sha256, digits: 8)
        let password = try! generator?.password(at: Date())
        let bearer = String(format: "Bearer %@", password!)
        
        let userURL = URL(string: UserEndpoint.resetPassword.path, relativeTo: config.serverEndpoint)!
        let request = network.sessionManager.request(userURL, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: nil)
        do {
            let adaptedRequest = try service.network.authenticator.adapt(request.request!)
            
            if let authorizationHeader = adaptedRequest.value(forHTTPHeaderField:  HTTPHeader.authorization.rawValue) {
                XCTAssertEqual(authorizationHeader, bearer)
            } else {
                XCTFail("No auth header")
            }
            
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        keychain.removeAll()
    }
    
    func testAccessTokenHeaderAppendedToHostRequests() {
        let config = FrolloSDKConfiguration.testConfig()
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let userURL = URL(string: UserEndpoint.details.path, relativeTo: config.serverEndpoint)!
        let request = network.sessionManager.request(userURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
        do {
            let adaptedRequest = try service.network.authenticator.adapt(request.request!)
            
            if let authorizationHeader = adaptedRequest.value(forHTTPHeaderField:  HTTPHeader.authorization.rawValue) {
                XCTAssertEqual(authorizationHeader, "Bearer AnExistingAccessToken")
            } else {
                XCTFail("No auth header")
            }
            
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        keychain.removeAll()
    }
    
    func testNoHeaderAppendedToTokenRequest() {
        let config = FrolloSDKConfiguration.testConfig()
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let request = network.sessionManager.request(config.tokenEndpoint, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: nil)
        do {
            let adaptedRequest = try service.network.authenticator.adapt(request.request!)
            
            XCTAssertNil(adaptedRequest.value(forHTTPHeaderField:  HTTPHeader.authorization.rawValue))
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        keychain.removeAll()
    }
    
    func testNoHeaderAppendedToExternalHostRequests() {
        let config = FrolloSDKConfiguration.testConfig()
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let userURL = URL(string: "https://google.com.au")!
        let request = network.sessionManager.request(userURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
        do {
            let adaptedRequest = try service.network.authenticator.adapt(request.request!)
            
            XCTAssertNil(adaptedRequest.value(forHTTPHeaderField:  HTTPHeader.authorization.rawValue))
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        keychain.removeAll()
    }
    
    #warning("Add pinning tests")
    
    // MARK: - Auth delegate
    
    func authenticationReset() {
        
    }
    
}
