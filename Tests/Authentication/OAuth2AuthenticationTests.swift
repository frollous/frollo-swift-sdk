//
//  Copyright © 2018 Frollo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
// 
//      http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import XCTest
@testable import FrolloSDK

#if CORE && os(iOS)
import AppAuthCore
#else
import AppAuth
#endif

import OHHTTPStubs

class OAuth2AuthenticationTests: BaseTestCase {
    
    override func setUp() {
        testsKeychainService = "AuthenticationTestsKeychain"
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        
        OHHTTPStubs.removeAllStubs()
        Keychain(service: keychainService).removeAll()
    }
    
    private func validKeychain() -> Keychain {
        let keychain = Keychain(service: keychainService)
        keychain["refreshToken"] = "AnExistingRefreshToken"
        keychain["accessToken"] = "AnExistingAccessToken"
        keychain["accessTokenExpiry"] = String(Date(timeIntervalSinceNow: 1000).timeIntervalSince1970) // Not expired by time
        return keychain
    }
    
    // MARK: - Login User
    
    func testLoginUser() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(host: tokenEndpointHost, endpoint: FrolloSDKConfiguration.tokenEndpoint.path, toResourceWithName: "token_valid")
        
        let keychain = Keychain(service: keychainService)
        let networkAuthenticator = defaultNetworkAuthenticator(keychain: keychain)
        let authentication = defaultAuthentication(keychain: keychain, networkAuthenticator: networkAuthenticator)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.loginUser(email: "user@frollo.us", password: "password", scopes: ["offline_access", "email", "openid"]) { (result) in
                switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    XCTAssertTrue(authentication.loggedIn)
                    
                    XCTAssertEqual(networkAuthenticator.accessToken, "MTQ0NjJkZmQ5OTM2NDE1ZTZjNGZmZjI3")
                    XCTAssertEqual(networkAuthenticator.expiryDate, Date(timeIntervalSince1970: 2550794799))
                    
                    XCTAssertEqual(authentication.refreshToken, "IwOGYzYTlmM2YxOTQ5MGE3YmNmMDFkNTVk")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testInvalidLoginUser() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(host: tokenEndpointHost, endpoint: FrolloSDKConfiguration.tokenEndpoint.path, toResourceWithName: "error_oauth2_invalid_grant", addingStatusCode: 401)
        
        let keychain = defaultKeychain(isNetwork: false)
        let networkAuthenticator = defaultNetworkAuthenticator(keychain: keychain)
        let authentication = defaultAuthentication(keychain: keychain, networkAuthenticator: networkAuthenticator)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.loginUser(email: "user@frollo.us", password: "wrong_password", scopes: ["offline_access", "email", "openid"]) { (result) in
                switch result {
                case .failure(let error):
                    XCTAssertFalse(authentication.loggedIn)
                    
                    XCTAssertNil(networkAuthenticator.accessToken)
                    XCTAssertNil(networkAuthenticator.expiryDate)
                    
                    XCTAssertNil(authentication.refreshToken)
                    
                    if let apiError = error as? OAuth2Error {
                        XCTAssertEqual(apiError.type, .invalidGrant)
                    } else {
                        XCTFail("Wrong error returned")
                    }
                case .success:
                    XCTFail("Wrong password should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testLoginUserFailsIfLoggedIn() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(host: tokenEndpointHost, endpoint: FrolloSDKConfiguration.tokenEndpoint.path, toResourceWithName: "token_valid")
        connect(endpoint: UserEndpoint.register.path.prefixedWithSlash, toResourceWithName: "user_details_complete")
        
        let authentication = defaultAuthentication(loggedIn: true)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.loginUser(email: "user@frollo.us", password: "password", scopes: ["offline_access", "email", "openid"]) { (result) in
                switch result {
                case .failure(let error):
                    XCTAssertTrue(authentication.loggedIn)
                    
                    if let dataError = error as? DataError {
                        XCTAssertEqual(dataError.type, .authentication)
                        XCTAssertEqual(dataError.subType, .alreadyLoggedIn)
                    } else {
                        XCTFail("Wrong error returned")
                    }
                case .success:
                    XCTFail("User was already logged in. Should fail.")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    #if os(iOS)
    func testLoginUserViaWebFails() {
        let expectation1 = expectation(description: "Network Request")
        let expectation2 = expectation(description: "Network Request")
        
        connect(host: tokenEndpointHost, endpoint: FrolloSDKConfiguration.tokenEndpoint.path, toResourceWithName: "token_valid")
        connect(endpoint: UserEndpoint.details.path.prefixedWithSlash, toResourceWithName: "user_details_complete")
        
        let keychain = defaultKeychain(isNetwork: false)
        let networkAuthenticator = defaultNetworkAuthenticator(keychain: keychain)
        let authentication = defaultAuthentication(keychain: keychain, networkAuthenticator: networkAuthenticator, loggedIn: false)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.loginUserUsingWeb(presenting: UIApplication.shared.keyWindow!.rootViewController!, scopes: ["offline_access", "email", "openid"]) { (result) in
                switch result {
                    case .failure(let error):
                        XCTAssertFalse(authentication.loggedIn)
                        
                        XCTAssertNil(networkAuthenticator.accessToken)
                        XCTAssertNil(networkAuthenticator.expiryDate)
                        
                        XCTAssertNil(authentication.refreshToken)
                        
                        if let authError = error as? OAuth2Error {
                            XCTAssertEqual(authError.type, .clientError)
                        } else {
                            XCTFail("Wrong error returned")
                        }
                    case .success:
                        XCTFail("Wrong password should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let authURL = URL(string: "app://redirect?code=4VbXuJz8dfFiCaJh&state=smpNp40xhOR5hDUQRevUtPDjkEV5e9Xh0k7dtjaTelA")!
            
            let result = authentication.resumeAuthentication(url: authURL)
            
            XCTAssertTrue(result)
            
            expectation2.fulfill()
        }
        
        wait(for: [expectation1, expectation2], timeout: 5.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    #endif
    
    #if os(macOS)
    func testLoginUserViaWebFails() {
        let expectation1 = expectation(description: "Network Request")
        let expectation2 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(FrolloSDKConfiguration.tokenEndpoint.host!) && isPath(FrolloSDKConfiguration.tokenEndpoint.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "token_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.details.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let keychain = Keychain(service: keychainService)
        let networkAuthenticator = NetworkAuthenticator(serverEndpoint: config.serverEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authService = OAuthService(authorizationEndpoint: FrolloSDKConfiguration.authorizationEndpoint, tokenEndpoint: FrolloSDKConfiguration.tokenEndpoint, redirectURL: FrolloSDKConfiguration.redirectURL, revokeURL: FrolloSDKConfiguration.revokeTokenEndpoint, network: network)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let authentication = OAuth2Authentication(keychain: keychain, clientID: config.clientID, redirectURL: FrolloSDKConfiguration.redirectURL, serverURL: config.serverEndpoint, authService: authService, preferences: preferences, delegate: nil, tokenDelegate: network)
        let user = UserManagement(database: database, service: service, clientID: config.clientID, authentication: authentication, preferences: preferences, delegate: nil)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.loginUserUsingWeb(scopes: ["offline_access", "email", "openid"]) { (result) in
                switch result {
                    case .failure(let error):
                        XCTAssertFalse(authentication.loggedIn)
                        
                        XCTAssertNil(user.fetchUser(context: database.newBackgroundContext()))
                        
                        XCTAssertNil(networkAuthenticator.accessToken)
                        XCTAssertNil(networkAuthenticator.expiryDate)
                        
                        XCTAssertNil(authentication.refreshToken)
                        
                        if let authError = error as? OAuth2Error {
                            XCTAssertEqual(authError.type, .clientError)
                        } else {
                            XCTFail("Wrong error returned")
                        }
                    case .success:
                        XCTFail("Wrong password should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let authURL = URL(string: "app://redirect?code=4VbXuJz8dfFiCaJh&state=smpNp40xhOR5hDUQRevUtPDjkEV5e9Xh0k7dtjaTelA")!
            
            let result = authentication.resumeAuthentication(url: authURL)
            
            XCTAssertTrue(result)
            
            expectation2.fulfill()
        }
        
        wait(for: [expectation1, expectation2], timeout: 5.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    #endif
    
    func testLogoutUser() {
        let expectation1 = expectation(description: "Network Request")
        
        let keychain = validKeychain()
        let authentication = defaultAuthentication(keychain: keychain, loggedIn: true)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let moc = self.database.newBackgroundContext()
            
            moc.performAndWait {
                let user = User(context: moc)
                user.populateTestData()
                
                try! moc.save()
            }
            
            authentication.logout()
            
            XCTAssertNil(error)
            
            XCTAssertFalse(authentication.loggedIn)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testUserLoggedOutOn401() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: UserEndpoint.details.path.prefixedWithSlash, toResourceWithName: "error_suspended_device", addingStatusCode: 401)
        
        let keychain = validKeychain()
        let networkAuthenticator = defaultNetworkAuthenticator(keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let authentication = defaultAuthentication(keychain: keychain, networkAuthenticator: networkAuthenticator, loggedIn: true)
        let user = UserManagement(database: database, service: service, clientID: config.clientID, authentication: authentication, preferences: preferences, delegate: nil)
        
        let resetter = NetworkResetterStub(authentication: authentication)
        network.delegate = resetter
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let moc = self.database.newBackgroundContext()
            
            moc.performAndWait {
                let user = User(context: moc)
                user.populateTestData()
                
                try! moc.save()
            }
            
            user.updateUser { (result) in
                switch result {
                case .failure:
                    XCTAssertFalse(authentication.loggedIn)
                    
                    XCTAssertNil(authentication.refreshToken)
                    XCTAssertNil(networkAuthenticator.accessToken)
                case .success:
                    XCTFail("Update user should fail due to 401")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    // MARK: - Tokens
    
    func testRefreshTokensFailsIfNoRefreshToken() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(host: tokenEndpointHost, endpoint: FrolloSDKConfiguration.tokenEndpoint.path, toResourceWithName: "token_valid")
        
        let keychain = defaultKeychain(isNetwork: false)
        let networkAuthenticator = defaultNetworkAuthenticator(keychain: keychain)
        let authentication = defaultAuthentication(keychain: keychain, networkAuthenticator: networkAuthenticator)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.refreshTokens { (result) in
                switch result {
                case .failure(let error):
                    if let tokenError = error as? DataError {
                        XCTAssertEqual(tokenError.type, .authentication)
                        XCTAssertEqual(tokenError.subType, .missingRefreshToken)
                    } else {
                        XCTFail("Wrong error returned")
                    }
                case .success:
                    XCTFail("Refresh token was missing, this should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testExchangeAuthorizationCode() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(host: tokenEndpointHost, endpoint: FrolloSDKConfiguration.tokenEndpoint.path, toResourceWithName: "token_valid")
        
        let keychain = defaultKeychain(isNetwork: false)
        let networkAuthenticator = defaultNetworkAuthenticator(keychain: keychain)
        let authentication = defaultAuthentication(keychain: keychain, networkAuthenticator: networkAuthenticator)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.exchangeAuthorizationCode(code: String.randomString(length: 32), codeVerifier: String.randomString(length: 32), scopes: ["offline_access", "email", "openid"]) { (result) in
                switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    XCTAssertTrue(authentication.loggedIn)
                    
                    XCTAssertEqual(networkAuthenticator.accessToken, "MTQ0NjJkZmQ5OTM2NDE1ZTZjNGZmZjI3")
                    XCTAssertEqual(networkAuthenticator.expiryDate, Date(timeIntervalSince1970: 2550794799))
                    
                    XCTAssertEqual(authentication.refreshToken, "IwOGYzYTlmM2YxOTQ5MGE3YmNmMDFkNTVk")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testExchangeAuthorizationCodeInvalid() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(host: tokenEndpointHost, endpoint: FrolloSDKConfiguration.tokenEndpoint.path, toResourceWithName: "error_oauth2_invalid_grant", addingStatusCode: 401)
        connect(endpoint: UserEndpoint.details.path.prefixedWithSlash, toResourceWithName: "user_details_complete")
        
        let keychain = Keychain(service: keychainService)
        let networkAuthenticator = defaultNetworkAuthenticator(keychain: keychain)
        let authentication = defaultAuthentication(keychain: keychain, networkAuthenticator: networkAuthenticator, loggedIn: false)
        let user = defaultUser(keychain: keychain)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            // Override due to NSUserDefaults on tvOS
            authentication.loggedIn = false
            
            authentication.exchangeAuthorizationCode(code: String.randomString(length: 32), codeVerifier: String.randomString(length: 32), scopes: ["offline_access", "email", "openid"]) { (result) in
                switch result {
                    case .failure(let error):
                        XCTAssertFalse(authentication.loggedIn)
                        
                        XCTAssertNil(user.fetchUser(context: self.database.newBackgroundContext()))
                        
                        XCTAssertNil(networkAuthenticator.accessToken)
                        XCTAssertNil(networkAuthenticator.expiryDate)
                        
                        XCTAssertNil(authentication.refreshToken)
                        
                        if let oAuthError = error as? OAuth2Error {
                            XCTAssertEqual(oAuthError.type, .invalidGrant)
                        } else {
                            XCTFail("Wrong error returned")
                        }
                    case .success:
                        XCTFail("Wrong password should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testExchangeAuthorizationCodeFailsIfLoggedIn() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(host: tokenEndpointHost, endpoint: FrolloSDKConfiguration.tokenEndpoint.path, toResourceWithName: "token_valid")
        
        let keychain = defaultKeychain(isNetwork: false)
        let networkAuthenticator = defaultNetworkAuthenticator(keychain: keychain)
        let authentication = defaultAuthentication(keychain: keychain, networkAuthenticator: networkAuthenticator, loggedIn: true)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.exchangeAuthorizationCode(code: String.randomString(length: 32), codeVerifier: String.randomString(length: 32), scopes: ["offline_access", "email", "openid"]) { (result) in
                switch result {
                    case .failure(let error):
                        XCTAssertTrue(authentication.loggedIn)
                        
                        if let dataError = error as? DataError {
                            XCTAssertEqual(dataError.type, .authentication)
                            XCTAssertEqual(dataError.subType, .alreadyLoggedIn)
                        } else {
                            XCTFail("Wrong error returned")
                        }
                    case .success:
                        XCTFail("Not logged in, this should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testExchangeLegacyAccessToken() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(host: tokenEndpointHost, endpoint: FrolloSDKConfiguration.tokenEndpoint.path, toResourceWithName: "token_valid")
        
        let keychain = validKeychain()
        let networkAuthenticator = defaultNetworkAuthenticator(keychain: keychain)
        let authentication = defaultAuthentication(keychain: keychain, networkAuthenticator: networkAuthenticator, loggedIn: true)
        
        authentication.updateToken("IwOGYzYTlmM2YxOTQ5MGE3YmNmMDFkNTVk")
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.exchangeLegacyToken { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        XCTAssertTrue(authentication.loggedIn)
                        
                        XCTAssertEqual(networkAuthenticator.accessToken, "MTQ0NjJkZmQ5OTM2NDE1ZTZjNGZmZjI3")
                        XCTAssertEqual(networkAuthenticator.expiryDate, Date(timeIntervalSince1970: 2550794799))
                        
                        XCTAssertEqual(authentication.refreshToken, "IwOGYzYTlmM2YxOTQ5MGE3YmNmMDFkNTVk")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testExchangeLegacyTokenFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(host: tokenEndpointHost, endpoint: FrolloSDKConfiguration.tokenEndpoint.path, toResourceWithName: "token_valid")
        
        let keychain = validKeychain()
        let networkAuthenticator = defaultNetworkAuthenticator(keychain: keychain)
        let authentication = defaultAuthentication(keychain: keychain, networkAuthenticator: networkAuthenticator, loggedIn: false)
        
        authentication.updateToken("IwOGYzYTlmM2YxOTQ5MGE3YmNmMDFkNTVk")
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.exchangeLegacyToken { (result) in
                switch result {
                    case .failure(let error):
                        XCTAssertNotNil(error)
                        
                        if let loggedOutError = error as? DataError {
                            XCTAssertEqual(loggedOutError.type, .authentication)
                            XCTAssertEqual(loggedOutError.subType, .loggedOut)
                        } else {
                            XCTFail("Wrong error type returned")
                        }
                    case .success:
                        XCTFail("User logged out, request should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testExchangeLegacyTokenFailure() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(host: tokenEndpointHost, endpoint: FrolloSDKConfiguration.tokenEndpoint.path, toResourceWithName: "error_oauth2_invalid_grant", addingStatusCode: 401)
        
        let keychain = validKeychain()
        let networkAuthenticator = defaultNetworkAuthenticator(keychain: keychain)
        let authentication = defaultAuthentication(keychain: keychain, networkAuthenticator: networkAuthenticator, loggedIn: true)
        
        authentication.updateToken("IwOGYzYTlmM2YxOTQ5MGE3YmNmMDFkNTVk")
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.exchangeLegacyToken { (result) in
                switch result {
                    case .failure(let error):
                        XCTAssertFalse(authentication.loggedIn)
                        
                        XCTAssertNil(networkAuthenticator.accessToken)
                        XCTAssertNil(networkAuthenticator.expiryDate)
                        
                        XCTAssertNil(authentication.refreshToken)
                        
                        if let oAuthError = error as? OAuth2Error {
                            XCTAssertEqual(oAuthError.type, .invalidGrant)
                        } else {
                            XCTFail("Wrong error returned")
                        }
                    case .success:
                        XCTFail("Invalid grant should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testExchangeMissingRefreshTokenFails() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(host: tokenEndpointHost, endpoint: FrolloSDKConfiguration.tokenEndpoint.path, toResourceWithName: "token_valid")
        
        let keychain = Keychain(service: keychainService)
        let networkAuthenticator = defaultNetworkAuthenticator(keychain: keychain)
        let authentication = defaultAuthentication(keychain: keychain, networkAuthenticator: networkAuthenticator, loggedIn: true)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.exchangeLegacyToken { (result) in
                switch result {
                case .failure(let error):
                    XCTAssertNil(networkAuthenticator.accessToken)
                    XCTAssertNil(networkAuthenticator.expiryDate)
                    
                    XCTAssertNil(authentication.refreshToken)
                    
                    if let authError = error as? DataError {
                        XCTAssertEqual(authError.type, .authentication)
                        XCTAssertEqual(authError.subType, .missingRefreshToken)
                    } else {
                        XCTFail("Wrong error returned")
                    }
                case .success:
                    XCTFail("Missing refresh token should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }

    func testTokensPersist() {
        let keychain = Keychain(service: keychainService)
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let refreshToken = "AnExistingRefreshToken"
        
        let networkAuthenticator = NetworkAuthenticator(serverEndpoint: config.serverEndpoint, keychain: keychain)
        let network =  Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        
        let authService = OAuthService(authorizationEndpoint: FrolloSDKConfiguration.authorizationEndpoint, tokenEndpoint: FrolloSDKConfiguration.tokenEndpoint, redirectURL: FrolloSDKConfiguration.redirectURL, revokeURL: FrolloSDKConfiguration.revokeTokenEndpoint, network: network)
        var authentication = OAuth2Authentication(keychain: keychain, clientID: config.clientID, redirectURL: FrolloSDKConfiguration.redirectURL, serverURL: config.serverEndpoint, authService: authService, preferences: preferences, delegate: nil, tokenDelegate: network)
        
        authentication.updateToken(refreshToken)
        
        XCTAssertEqual(keychain["refreshToken"], refreshToken)
        
        authentication = OAuth2Authentication(keychain: keychain, clientID: config.clientID, redirectURL: FrolloSDKConfiguration.redirectURL, serverURL: config.serverEndpoint, authService: authService, preferences: preferences, delegate: nil, tokenDelegate: network)
        
        XCTAssertEqual(authentication.refreshToken, refreshToken)
    }
}
