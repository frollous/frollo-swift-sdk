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
    
    func testForceRefreshingAccessTokens() {
        let expectation1 = expectation(description: "API Response")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(FrolloSDKConfiguration.tokenEndpoint.host!) && isPath(FrolloSDKConfiguration.tokenEndpoint.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "token_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let path = tempFolderPath()
        let preferences = Preferences(path: path)
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let authService = OAuth2Service(authorizationEndpoint: FrolloSDKConfiguration.authorizationEndpoint, tokenEndpoint: FrolloSDKConfiguration.tokenEndpoint, redirectURL: FrolloSDKConfiguration.redirectURL, revokeURL: FrolloSDKConfiguration.revokeTokenEndpoint, network: network)
        
        let oAuth2Authentication = OAuth2Authentication(keychain: keychain, clientID: config.clientID, redirectURL: FrolloSDKConfiguration.redirectURL, serverURL: config.serverEndpoint, authService: authService, preferences: preferences, delegate: nil)
        
        oAuth2Authentication.refreshTokens { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    XCTAssertEqual(oAuth2Authentication.accessToken?.token, "MTQ0NjJkZmQ5OTM2NDE1ZTZjNGZmZjI3")
                    XCTAssertEqual(oAuth2Authentication.accessToken?.expiryDate, Date(timeIntervalSince1970: 2550794799))
                
                    XCTAssertEqual(oAuth2Authentication.refreshToken, "IwOGYzYTlmM2YxOTQ5MGE3YmNmMDFkNTVk")
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
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let authService = OAuth2Service(authorizationEndpoint: FrolloSDKConfiguration.authorizationEndpoint, tokenEndpoint: FrolloSDKConfiguration.tokenEndpoint, redirectURL: FrolloSDKConfiguration.redirectURL, revokeURL: FrolloSDKConfiguration.revokeTokenEndpoint, network: network)
        let oAuth2Authentication = OAuth2Authentication(keychain: keychain, clientID: config.clientID, redirectURL: FrolloSDKConfiguration.redirectURL, serverURL: config.serverEndpoint, authService: authService, preferences: preferences, delegate: nil)
        
        authentication.dataSource = oAuth2Authentication
        authentication.delegate = oAuth2Authentication
        
        oAuth2Authentication.refreshTokens { (result) in
            switch result {
                case .failure(let error):
                    XCTAssertNil(oAuth2Authentication.accessToken)
                    XCTAssertNil(oAuth2Authentication.refreshToken)
                    
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
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let authService = OAuth2Service(authorizationEndpoint: FrolloSDKConfiguration.authorizationEndpoint, tokenEndpoint: FrolloSDKConfiguration.tokenEndpoint, redirectURL: FrolloSDKConfiguration.redirectURL, revokeURL: FrolloSDKConfiguration.revokeTokenEndpoint, network: network)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let oAuth2Authentication = OAuth2Authentication(keychain: keychain, clientID: config.clientID, redirectURL: FrolloSDKConfiguration.redirectURL, serverURL: config.serverEndpoint, authService: authService, preferences: preferences, delegate: nil)
        oAuth2Authentication.loggedIn = true
        
        authentication.dataSource = oAuth2Authentication
        authentication.delegate = oAuth2Authentication
        
        service.fetchUser { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    XCTAssertEqual(oAuth2Authentication.accessToken?.token, "MTQ0NjJkZmQ5OTM2NDE1ZTZjNGZmZjI3")
                    XCTAssertEqual(oAuth2Authentication.accessToken?.expiryDate, Date(timeIntervalSince1970: 2550794799))
                
                    XCTAssertEqual(oAuth2Authentication.refreshToken, "IwOGYzYTlmM2YxOTQ5MGE3YmNmMDFkNTVk")
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
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let authService = OAuth2Service(authorizationEndpoint: FrolloSDKConfiguration.authorizationEndpoint, tokenEndpoint: FrolloSDKConfiguration.tokenEndpoint, redirectURL: FrolloSDKConfiguration.redirectURL, revokeURL: FrolloSDKConfiguration.revokeTokenEndpoint, network: network)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let oAuth2Authentication = OAuth2Authentication(keychain: keychain, clientID: config.clientID, redirectURL: FrolloSDKConfiguration.redirectURL, serverURL: config.serverEndpoint, authService: authService, preferences: preferences, delegate: nil)
        oAuth2Authentication.loggedIn = true
        
        authentication.dataSource = oAuth2Authentication
        authentication.delegate = oAuth2Authentication
        
        service.fetchUser { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    XCTAssertEqual(oAuth2Authentication.accessToken?.token, "MTQ0NjJkZmQ5OTM2NDE1ZTZjNGZmZjI3")
                    XCTAssertEqual(oAuth2Authentication.accessToken?.expiryDate, Date(timeIntervalSince1970: 2550794799))
                
                    XCTAssertEqual(oAuth2Authentication.refreshToken, "IwOGYzYTlmM2YxOTQ5MGE3YmNmMDFkNTVk")
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
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let authService = OAuth2Service(authorizationEndpoint: FrolloSDKConfiguration.authorizationEndpoint, tokenEndpoint: FrolloSDKConfiguration.tokenEndpoint, redirectURL: FrolloSDKConfiguration.redirectURL, revokeURL: FrolloSDKConfiguration.revokeTokenEndpoint, network: network)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let oAuth2Authentication = OAuth2Authentication(keychain: keychain, clientID: config.clientID, redirectURL: FrolloSDKConfiguration.redirectURL, serverURL: config.serverEndpoint, authService: authService, preferences: preferences, delegate: nil)
        oAuth2Authentication.loggedIn = true
        
        authentication.dataSource = oAuth2Authentication
        authentication.delegate = oAuth2Authentication
        
        service.fetchUser { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    XCTAssertEqual(oAuth2Authentication.accessToken?.token, "MTQ0NjJkZmQ5OTM2NDE1ZTZjNGZmZjI3")
                    XCTAssertEqual(oAuth2Authentication.accessToken?.expiryDate, Date(timeIntervalSince1970: 2550794799))
                
                    XCTAssertEqual(oAuth2Authentication.refreshToken, "IwOGYzYTlmM2YxOTQ5MGE3YmNmMDFkNTVk")
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
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let authService = OAuth2Service(authorizationEndpoint: FrolloSDKConfiguration.authorizationEndpoint, tokenEndpoint: FrolloSDKConfiguration.tokenEndpoint, redirectURL: FrolloSDKConfiguration.redirectURL, revokeURL: FrolloSDKConfiguration.revokeTokenEndpoint, network: network)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let oAuth2Authentication = OAuth2Authentication(keychain: keychain, clientID: config.clientID, redirectURL: FrolloSDKConfiguration.redirectURL, serverURL: config.serverEndpoint, authService: authService, preferences: preferences, delegate: nil)
        oAuth2Authentication.loggedIn = true
        
        authentication.dataSource = oAuth2Authentication
        authentication.delegate = oAuth2Authentication
        
        service.fetchUser { (result) in
            switch result {
                case .failure:
                    XCTAssertNil(oAuth2Authentication.accessToken)
                    XCTAssertNil(oAuth2Authentication.refreshToken)
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
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
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
    }
    
    // MARK: - Adapter Header Tests
    
    func testNoHeaderAppendedToRegistrationRequest() {
        let config = FrolloSDKConfiguration.testConfig()
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let userURL = URL(string: UserEndpoint.register.path, relativeTo: config.serverEndpoint)!
        let request = network.sessionManager.request(userURL, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: nil)
        do {
            let adaptedRequest = try service.network.authentication.adapt(request.request!)
            
            if adaptedRequest.value(forHTTPHeaderField:  HTTPHeader.authorization.rawValue) != nil {
                XCTFail("Authorization Header found")
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testNoHeaderAppendedToResetPasswordRequest() {
        let config = FrolloSDKConfiguration.testConfig()
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let userURL = URL(string: UserEndpoint.resetPassword.path, relativeTo: config.serverEndpoint)!
        let request = network.sessionManager.request(userURL, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: nil)
        do {
            let adaptedRequest = try service.network.authentication.adapt(request.request!)
            
            if adaptedRequest.value(forHTTPHeaderField:  HTTPHeader.authorization.rawValue) != nil {
                XCTFail("Authorization Header found")
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testHeaderRemainsIntactMigrateUserRequest() {
        let config = FrolloSDKConfiguration.testConfig()
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let userURL = URL(string: UserEndpoint.migrate.path, relativeTo: config.serverEndpoint)!
        
        let body = APIUserMigrationRequest(password: "12345678")
        var urlRequest = network.contentRequest(url: userURL, method: .post, content: body)
        
        let bearer = "Bearer MyRefreshToken"
        urlRequest?.setValue(bearer, forHTTPHeaderField: HTTPHeader.authorization.rawValue)
        
        let request = network.sessionManager.request(urlRequest!)
        
        do {
            let adaptedRequest = try service.network.authentication.adapt(request.request!)
            
            XCTAssertEqual(adaptedRequest.value(forHTTPHeaderField:  HTTPHeader.authorization.rawValue), bearer)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testAccessTokenHeaderAppendedToHostRequests() {
        let config = FrolloSDKConfiguration.testConfig()
        
        let mockAuthentication = MockAuthentication(token: "AnExistingAccessToken")
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let userURL = URL(string: UserEndpoint.details.path, relativeTo: config.serverEndpoint)!
        let request = network.sessionManager.request(userURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
        do {
            let adaptedRequest = try service.network.authentication.adapt(request.request!)
            
            if let authorizationHeader = adaptedRequest.value(forHTTPHeaderField:  HTTPHeader.authorization.rawValue) {
                XCTAssertEqual(authorizationHeader, "Bearer AnExistingAccessToken")
            } else {
                XCTFail("No auth header")
            }
            
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testNoHeaderAppendedToTokenRequest() {
        let config = FrolloSDKConfiguration.testConfig()
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let request = network.sessionManager.request(FrolloSDKConfiguration.tokenEndpoint, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: nil)
        do {
            let adaptedRequest = try service.network.authentication.adapt(request.request!)
            
            XCTAssertNil(adaptedRequest.value(forHTTPHeaderField:  HTTPHeader.authorization.rawValue))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testNoHeaderAppendedToExternalHostRequests() {
        let config = FrolloSDKConfiguration.testConfig()
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let userURL = URL(string: "https://google.com.au")!
        let request = network.sessionManager.request(userURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
        do {
            let adaptedRequest = try service.network.authentication.adapt(request.request!)
            
            XCTAssertNil(adaptedRequest.value(forHTTPHeaderField:  HTTPHeader.authorization.rawValue))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
}
