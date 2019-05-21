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
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let accessToken = "AnExistingAccessToken"
        let expiryDateString = "1721259268.0"
        let expiryDate = Date(timeIntervalSince1970: 1721259268)
        
        var networkAuthenticator = NetworkAuthenticator(serverEndpoint: config.serverEndpoint, keychain: keychain)
        networkAuthenticator.saveAccessToken(accessToken, expiry: expiryDate)
        var network =  Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        var service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        XCTAssertEqual(keychain["accessToken"], accessToken)
        XCTAssertEqual(keychain["accessTokenExpiry"], expiryDateString)
        
        networkAuthenticator = NetworkAuthenticator(serverEndpoint: config.serverEndpoint, keychain: keychain)
        network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        XCTAssertEqual(service.network.authenticator.accessToken, accessToken)
        XCTAssertEqual(service.network.authenticator.expiryDate, expiryDate)
    }
    
    func testForceRefreshingAccessTokens() {
        let expectation1 = expectation(description: "API Response")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(FrolloSDKConfiguration.tokenEndpoint.host!) && isPath(FrolloSDKConfiguration.tokenEndpoint.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "token_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let path = tempFolderPath()
        let preferences = Preferences(path: path)
        let networkAuthenticator = NetworkAuthenticator(serverEndpoint: config.serverEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authService = OAuthService(authorizationEndpoint: FrolloSDKConfiguration.authorizationEndpoint, tokenEndpoint: FrolloSDKConfiguration.tokenEndpoint, redirectURL: FrolloSDKConfiguration.redirectURL, network: network)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let authentication = OAuth2Authentication(keychain: keychain, clientID: FrolloSDKConfiguration.clientID, redirectURL: FrolloSDKConfiguration.redirectURL, serverURL: config.serverEndpoint, authService: authService, preferences: preferences, delegate: network)
        
        authentication.refreshTokens { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    XCTAssertEqual(service.network.authenticator.accessToken, "MTQ0NjJkZmQ5OTM2NDE1ZTZjNGZmZjI3")
                    XCTAssertEqual(service.network.authenticator.expiryDate, Date(timeIntervalSince1970: 2550794799))
                
                    XCTAssertEqual(authentication.refreshToken, "IwOGYzYTlmM2YxOTQ5MGE3YmNmMDFkNTVk")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 5.0)
        
        OHHTTPStubs.removeAllStubs()
        keychain.removeAll()
    }
    
    func testForceRefreshingInvalidAccessTokens() {
        let expectation1 = expectation(description: "API Response")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(FrolloSDKConfiguration.tokenEndpoint.host!) && isPath(FrolloSDKConfiguration.tokenEndpoint.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "error_oauth2_invalid_grant", ofType: "json")!, status: 401, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let path = tempFolderPath()
        let preferences = Preferences(path: path)
        let networkAuthenticator = NetworkAuthenticator(serverEndpoint: config.serverEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authService = OAuthService(authorizationEndpoint: FrolloSDKConfiguration.authorizationEndpoint, tokenEndpoint: FrolloSDKConfiguration.tokenEndpoint, redirectURL: FrolloSDKConfiguration.redirectURL, network: network)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let authentication = OAuth2Authentication(keychain: keychain, clientID: FrolloSDKConfiguration.clientID, redirectURL: FrolloSDKConfiguration.redirectURL, serverURL: config.serverEndpoint, authService: authService, preferences: preferences, delegate: network)
        
        networkAuthenticator.authentication = authentication
        
        let resetter = NetworkResetterStub(authentication: authentication)
        network.delegate = resetter
        
        authentication.refreshTokens { (result) in
            switch result {
                case .failure(let error):
                    XCTAssertNil(service.network.authenticator.accessToken)
                    XCTAssertNil(service.network.authenticator.expiryDate)
                    
                    XCTAssertNil(authentication.refreshToken)
                    
                    if let apiError = error as? OAuth2Error {
                        XCTAssertEqual(apiError.type, .invalidGrant)
                    } else {
                        XCTFail("Wrong type of error")
                    }
                case .success:
                    XCTFail("Invalid refresh token should not have succeeded")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 5.0)
        
        OHHTTPStubs.removeAllStubs()
        keychain.removeAll()
    }
    
    func testPreemptiveAccessTokenRefresh() {
        let expectation1 = expectation(description: "API Response")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(FrolloSDKConfiguration.tokenEndpoint.host!) && isPath(FrolloSDKConfiguration.tokenEndpoint.path)) { (request) -> OHHTTPStubsResponse in
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
        let preferences = Preferences(path: path)
        let networkAuthenticator = NetworkAuthenticator(serverEndpoint: config.serverEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authService = OAuthService(authorizationEndpoint: FrolloSDKConfiguration.authorizationEndpoint, tokenEndpoint: FrolloSDKConfiguration.tokenEndpoint, redirectURL: FrolloSDKConfiguration.redirectURL, network: network)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let authentication = OAuth2Authentication(keychain: keychain, clientID: FrolloSDKConfiguration.clientID, redirectURL: FrolloSDKConfiguration.redirectURL, serverURL: config.serverEndpoint, authService: authService, preferences: preferences, delegate: network)
        authentication.loggedIn = true
        
        networkAuthenticator.authentication = authentication
        
        service.fetchUser { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    XCTAssertEqual(service.network.authenticator.accessToken, "MTQ0NjJkZmQ5OTM2NDE1ZTZjNGZmZjI3")
                    XCTAssertEqual(service.network.authenticator.expiryDate, Date(timeIntervalSince1970: 2550794799))
                
                    XCTAssertEqual(authentication.refreshToken, "IwOGYzYTlmM2YxOTQ5MGE3YmNmMDFkNTVk")
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
        
        stub(condition: isHost(FrolloSDKConfiguration.tokenEndpoint.host!) && isPath(FrolloSDKConfiguration.tokenEndpoint.path)) { (request) -> OHHTTPStubsResponse in
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
        let preferences = Preferences(path: path)
        let networkAuthenticator = NetworkAuthenticator(serverEndpoint: config.serverEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authService = OAuthService(authorizationEndpoint: FrolloSDKConfiguration.authorizationEndpoint, tokenEndpoint: FrolloSDKConfiguration.tokenEndpoint, redirectURL: FrolloSDKConfiguration.redirectURL, network: network)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let authentication = OAuth2Authentication(keychain: keychain, clientID: FrolloSDKConfiguration.clientID, redirectURL: FrolloSDKConfiguration.redirectURL, serverURL: config.serverEndpoint, authService: authService, preferences: preferences, delegate: network)
        authentication.loggedIn = true
        
        networkAuthenticator.authentication = authentication
        
        service.fetchUser { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    XCTAssertEqual(service.network.authenticator.accessToken, "MTQ0NjJkZmQ5OTM2NDE1ZTZjNGZmZjI3")
                    XCTAssertEqual(service.network.authenticator.expiryDate, Date(timeIntervalSince1970: 2550794799))
                
                    XCTAssertEqual(authentication.refreshToken, "IwOGYzYTlmM2YxOTQ5MGE3YmNmMDFkNTVk")
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
        let preferences = Preferences(path: path)
        let networkAuthenticator = NetworkAuthenticator(serverEndpoint: config.serverEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authService = OAuthService(authorizationEndpoint: FrolloSDKConfiguration.authorizationEndpoint, tokenEndpoint: FrolloSDKConfiguration.tokenEndpoint, redirectURL: FrolloSDKConfiguration.redirectURL, network: network)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let authentication = OAuth2Authentication(keychain: keychain, clientID: FrolloSDKConfiguration.clientID, redirectURL: FrolloSDKConfiguration.redirectURL, serverURL: config.serverEndpoint, authService: authService, preferences: preferences, delegate: network)
        
        let resetter = NetworkResetterStub(authentication: authentication)
        network.delegate = resetter
        
        networkAuthenticator.authentication = authentication
        
        service.fetchUser { (result) in
            switch result {
                case .failure(let error):
                    XCTAssertNil(service.network.authenticator.accessToken)
                    XCTAssertNil(service.network.authenticator.expiryDate)
                    
                    XCTAssertNil(authentication.refreshToken)
                    
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
        
        stub(condition: isHost(FrolloSDKConfiguration.tokenEndpoint.host!) && isPath(FrolloSDKConfiguration.tokenEndpoint.path)) { (request) -> OHHTTPStubsResponse in
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
        let preferences = Preferences(path: path)
        let networkAuthenticator = NetworkAuthenticator(serverEndpoint: config.serverEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authService = OAuthService(authorizationEndpoint: FrolloSDKConfiguration.authorizationEndpoint, tokenEndpoint: FrolloSDKConfiguration.tokenEndpoint, redirectURL: FrolloSDKConfiguration.redirectURL, network: network)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let authentication = OAuth2Authentication(keychain: keychain, clientID: FrolloSDKConfiguration.clientID, redirectURL: FrolloSDKConfiguration.redirectURL, serverURL: config.serverEndpoint, authService: authService, preferences: preferences, delegate: network)
        authentication.loggedIn = true
        
        networkAuthenticator.authentication = authentication
        
        service.fetchUser { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    XCTAssertEqual(service.network.authenticator.accessToken, "MTQ0NjJkZmQ5OTM2NDE1ZTZjNGZmZjI3")
                    XCTAssertEqual(service.network.authenticator.expiryDate, Date(timeIntervalSince1970: 2550794799))
                
                    XCTAssertEqual(authentication.refreshToken, "IwOGYzYTlmM2YxOTQ5MGE3YmNmMDFkNTVk")
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
        
        stub(condition: isHost(FrolloSDKConfiguration.tokenEndpoint.host!) && isPath(FrolloSDKConfiguration.tokenEndpoint.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "error_oauth2_invalid_grant", ofType: "json")!, status: 401, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.details.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "error_invalid_access_token", ofType: "json")!, status: 401, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let path = tempFolderPath()
        let preferences = Preferences(path: path)
        let networkAuthenticator = NetworkAuthenticator(serverEndpoint: config.serverEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authService = OAuthService(authorizationEndpoint: FrolloSDKConfiguration.authorizationEndpoint, tokenEndpoint: FrolloSDKConfiguration.tokenEndpoint, redirectURL: FrolloSDKConfiguration.redirectURL, network: network)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let authentication = OAuth2Authentication(keychain: keychain, clientID: FrolloSDKConfiguration.clientID, redirectURL: FrolloSDKConfiguration.redirectURL, serverURL: config.serverEndpoint, authService: authService, preferences: preferences, delegate: network)
        authentication.loggedIn = true
        
        let resetter = NetworkResetterStub(authentication: authentication)
        network.delegate = resetter
        
        networkAuthenticator.authentication = authentication
        
        service.fetchUser { (result) in
            switch result {
                case .failure:
                    XCTAssertNil(service.network.authenticator.accessToken)
                    XCTAssertNil(service.network.authenticator.expiryDate)
                
                    XCTAssertNil(authentication.refreshToken)
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
        
        let networkAuthenticator = NetworkAuthenticator(serverEndpoint: config.serverEndpoint, keychain: keychain)
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
    
    func testNoHeaderAppendedToRegistrationRequest() {
        let config = FrolloSDKConfiguration.testConfig()
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(serverEndpoint: config.serverEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let userURL = URL(string: UserEndpoint.register.path, relativeTo: config.serverEndpoint)!
        let request = network.sessionManager.request(userURL, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: nil)
        do {
            let adaptedRequest = try service.network.authenticator.adapt(request.request!)
            
            if adaptedRequest.value(forHTTPHeaderField:  HTTPHeader.authorization.rawValue) != nil {
                XCTFail("Authorization Header found")
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        keychain.removeAll()
    }
    
    func testNoHeaderAppendedToResetPasswordRequest() {
        let config = FrolloSDKConfiguration.testConfig()
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(serverEndpoint: config.serverEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let userURL = URL(string: UserEndpoint.resetPassword.path, relativeTo: config.serverEndpoint)!
        let request = network.sessionManager.request(userURL, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: nil)
        do {
            let adaptedRequest = try service.network.authenticator.adapt(request.request!)
            
            if adaptedRequest.value(forHTTPHeaderField:  HTTPHeader.authorization.rawValue) != nil {
                XCTFail("Authorization Header found")
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        keychain.removeAll()
    }
    
    func testAccessTokenHeaderAppendedToHostRequests() {
        let config = FrolloSDKConfiguration.testConfig()
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(serverEndpoint: config.serverEndpoint, keychain: keychain)
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
        
        let networkAuthenticator = NetworkAuthenticator(serverEndpoint: config.serverEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let request = network.sessionManager.request(FrolloSDKConfiguration.tokenEndpoint, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: nil)
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
        
        let networkAuthenticator = NetworkAuthenticator(serverEndpoint: config.serverEndpoint, keychain: keychain)
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
    
    // MARK: - Auth delegate
    
    func authenticationReset() {
        
    }
    
}
