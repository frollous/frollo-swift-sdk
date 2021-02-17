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
        
        HTTPStubs.removeAllStubs()
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
        let oAuth2Authentication = defaultOAuth2Authentication(keychain: keychain)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            oAuth2Authentication.loginUser(email: "user@frollo.us", password: "password", scopes: ["offline_access", "email", "openid"]) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        XCTAssertTrue(oAuth2Authentication.loggedIn)
                        
                        XCTAssertEqual(oAuth2Authentication.accessToken?.token, "MTQ0NjJkZmQ5OTM2NDE1ZTZjNGZmZjI3")
                        XCTAssertEqual(oAuth2Authentication.accessToken?.expiryDate, Date(timeIntervalSince1970: 2550794799))
                        
                        XCTAssertEqual(oAuth2Authentication.refreshToken, "IwOGYzYTlmM2YxOTQ5MGE3YmNmMDFkNTVk")
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
        let oAuth2Authentication = defaultOAuth2Authentication(keychain: keychain)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            oAuth2Authentication.loginUser(email: "user@frollo.us", password: "wrong_password", scopes: ["offline_access", "email", "openid"]) { (result) in
                switch result {
                    case .failure(let error):
                        XCTAssertFalse(oAuth2Authentication.loggedIn)
                        
                        XCTAssertNil(oAuth2Authentication.accessToken?.token)
                        XCTAssertNil(oAuth2Authentication.accessToken?.expiryDate)
                        
                        XCTAssertNil(oAuth2Authentication.refreshToken)
                        
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
        
        let oAuth2Authentication = defaultOAuth2Authentication(loggedIn: true)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            oAuth2Authentication.loginUser(email: "user@frollo.us", password: "password", scopes: ["offline_access", "email", "openid"]) { (result) in
                switch result {
                    case .failure(let error):
                        XCTAssertTrue(oAuth2Authentication.loggedIn)
                        
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
        let oAuth2Authentication = defaultOAuth2Authentication(keychain: keychain)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            oAuth2Authentication.loginUserUsingWeb(presenting: UIApplication.shared.keyWindow!.rootViewController!, scopes: ["offline_access", "email", "openid"]) { (result) in
                switch result {
                    case .failure(let error):
                        XCTAssertFalse(oAuth2Authentication.loggedIn)
                        
                        XCTAssertNil(oAuth2Authentication.accessToken)
                        XCTAssertNil(oAuth2Authentication.refreshToken)
                        
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
            
            let result = oAuth2Authentication.resumeAuthentication(url: authURL)
            
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

        stub(condition: isHost(FrolloSDKConfiguration.tokenEndpoint.host!) && isPath(FrolloSDKConfiguration.tokenEndpoint.path)) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "token_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.details.path)) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        let path = tempFolderPath()
        let database = Database(path: path)
        let keychain = Keychain(service: keychainService)
        let oAuth2Authentication = defaultOAuth2Authentication(keychain: keychain)

        database.setup { (error) in
            XCTAssertNil(error)

            oAuth2Authentication.loginUserUsingWeb(scopes: ["offline_access", "email", "openid"]) { (result) in
                switch result {
                    case .failure(let error):
                        XCTAssertFalse(oAuth2Authentication.loggedIn)

                        XCTAssertNil(oAuth2Authentication.accessToken)
                        XCTAssertNil(oAuth2Authentication.refreshToken)

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

            let result = oAuth2Authentication.resumeAuthentication(url: authURL)

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
        let oAuth2Authentication = defaultOAuth2Authentication(keychain: keychain)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let moc = self.database.newBackgroundContext()
            
            moc.performAndWait {
                let user = User(context: moc)
                user.populateTestData()
                
                try! moc.save()
            }
            
            oAuth2Authentication.logout()
            
            XCTAssertNil(error)
            
            XCTAssertFalse(oAuth2Authentication.loggedIn)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testUserLoggedOutOn401() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: UserEndpoint.details.path.prefixedWithSlash, toResourceWithName: "error_suspended_device", addingStatusCode: 401)
        
        let keychain = validKeychain()
        let authentication = Authentication(configuration: config)
        let network = defaultNetwork(keychain: keychain, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let oAuth2Authentication = OAuth2Authentication(keychain: keychain, clientID: config.clientID, redirectURL: FrolloSDKConfiguration.redirectURL, serverURL: config.serverEndpoint, authService: defaultAuthService(keychain: keychain, network: network), preferences: preferences, delegate: nil)
        oAuth2Authentication.loggedIn = true
        let user = UserManagement(database: database, service: service, clientID: config.clientID, authentication: oAuth2Authentication, preferences: preferences, delegate: nil)
        
        authentication.dataSource = oAuth2Authentication
        authentication.delegate = oAuth2Authentication
        
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
                        XCTAssertFalse(oAuth2Authentication.loggedIn)
                        
                        XCTAssertNil(oAuth2Authentication.refreshToken)
                        XCTAssertNil(oAuth2Authentication.accessToken)
                    case .success:
                        XCTFail("Update user should fail due to 401")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 5.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    // MARK: - Tokens
    
    func testRefreshTokensFailsIfNoRefreshToken() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(host: tokenEndpointHost, endpoint: FrolloSDKConfiguration.tokenEndpoint.path, toResourceWithName: "token_valid")
        
        let keychain = defaultKeychain(isNetwork: false)
        let oAuth2Authentication = defaultOAuth2Authentication(keychain: keychain)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            oAuth2Authentication.refreshTokens { (result) in
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
        let oAuth2Authentication = defaultOAuth2Authentication(keychain: keychain)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            oAuth2Authentication.exchangeAuthorizationCode(code: String.randomString(length: 32), codeVerifier: String.randomString(length: 32), scopes: ["offline_access", "email", "openid"]) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        XCTAssertTrue(oAuth2Authentication.loggedIn)
                        
                        XCTAssertEqual(oAuth2Authentication.accessToken?.token, "MTQ0NjJkZmQ5OTM2NDE1ZTZjNGZmZjI3")
                        XCTAssertEqual(oAuth2Authentication.accessToken?.expiryDate, Date(timeIntervalSince1970: 2550794799))
                        
                        XCTAssertEqual(oAuth2Authentication.refreshToken, "IwOGYzYTlmM2YxOTQ5MGE3YmNmMDFkNTVk")
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
        let oAuth2Authentication = defaultOAuth2Authentication(keychain: keychain)
        let user = defaultUser(keychain: keychain)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            // Override due to NSUserDefaults on tvOS
            oAuth2Authentication.loggedIn = false
            
            oAuth2Authentication.exchangeAuthorizationCode(code: String.randomString(length: 32), codeVerifier: String.randomString(length: 32), scopes: ["offline_access", "email", "openid"]) { (result) in
                switch result {
                    case .failure(let error):
                        XCTAssertFalse(oAuth2Authentication.loggedIn)
                        
                        XCTAssertNil(user.fetchUser(context: self.database.newBackgroundContext()))
                        
                        XCTAssertNil(oAuth2Authentication.accessToken)
                        XCTAssertNil(oAuth2Authentication.refreshToken)
                        
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
        let oAuth2Authentication = defaultOAuth2Authentication(keychain: keychain, loggedIn: true)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            oAuth2Authentication.exchangeAuthorizationCode(code: String.randomString(length: 32), codeVerifier: String.randomString(length: 32), scopes: ["offline_access", "email", "openid"]) { (result) in
                switch result {
                    case .failure(let error):
                        XCTAssertTrue(oAuth2Authentication.loggedIn)
                        
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
        let oAuth2Authentication = defaultOAuth2Authentication(keychain: keychain, loggedIn: true)
        
        oAuth2Authentication.updateRefreshToken("IwOGYzYTlmM2YxOTQ5MGE3YmNmMDFkNTVk")
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            oAuth2Authentication.exchangeLegacyToken { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        XCTAssertTrue(oAuth2Authentication.loggedIn)
                        
                        XCTAssertEqual(oAuth2Authentication.accessToken?.token, "MTQ0NjJkZmQ5OTM2NDE1ZTZjNGZmZjI3")
                        XCTAssertEqual(oAuth2Authentication.accessToken?.expiryDate, Date(timeIntervalSince1970: 2550794799))
                        
                        XCTAssertEqual(oAuth2Authentication.refreshToken, "IwOGYzYTlmM2YxOTQ5MGE3YmNmMDFkNTVk")
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
        let oAuth2Authentication = defaultOAuth2Authentication(keychain: keychain)
        
        oAuth2Authentication.updateRefreshToken("IwOGYzYTlmM2YxOTQ5MGE3YmNmMDFkNTVk")
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            oAuth2Authentication.exchangeLegacyToken { (result) in
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
        let oAuth2Authentication = defaultOAuth2Authentication(keychain: keychain, loggedIn: true)
        
        oAuth2Authentication.updateRefreshToken("IwOGYzYTlmM2YxOTQ5MGE3YmNmMDFkNTVk")
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            oAuth2Authentication.exchangeLegacyToken { (result) in
                switch result {
                    case .failure(let error):
                        XCTAssertFalse(oAuth2Authentication.loggedIn)
                        
                        XCTAssertNil(oAuth2Authentication.accessToken)
                        XCTAssertNil(oAuth2Authentication.refreshToken)
                        
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
        let oAuth2Authentication = defaultOAuth2Authentication(keychain: keychain, loggedIn: true)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            oAuth2Authentication.exchangeLegacyToken { (result) in
                switch result {
                    case .failure(let error):
                        XCTAssertNil(oAuth2Authentication.accessToken)
                        XCTAssertNil(oAuth2Authentication.refreshToken)
                        
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
        
        let accessToken = "AnExistingAccessToken"
        let expiryDateString = "1721259268.0"
        let expiryDate = Date(timeIntervalSince1970: 1721259268)
        let refreshToken = "AnExistingRefreshToken"
        
        let authentication = Authentication(configuration: config)
        let network =  Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let authService = OAuth2Service(authorizationEndpoint: FrolloSDKConfiguration.authorizationEndpoint, tokenEndpoint: FrolloSDKConfiguration.tokenEndpoint, redirectURL: FrolloSDKConfiguration.redirectURL, revokeURL: FrolloSDKConfiguration.revokeTokenEndpoint, network: network)
        var oAuth2Authentication = OAuth2Authentication(keychain: keychain, clientID: config.clientID, redirectURL: FrolloSDKConfiguration.redirectURL, serverURL: config.serverEndpoint, authService: authService, preferences: preferences, delegate: nil)
        authentication.dataSource = oAuth2Authentication
        authentication.delegate = oAuth2Authentication
        
        oAuth2Authentication.updateAccessToken(accessToken, expiryDate: expiryDate)
        oAuth2Authentication.updateRefreshToken(refreshToken)
        
        XCTAssertEqual(keychain["refreshToken"], refreshToken)
        XCTAssertEqual(keychain["accessToken"], accessToken)
        XCTAssertEqual(keychain["accessTokenExpiry"], expiryDateString)
        
        oAuth2Authentication = OAuth2Authentication(keychain: keychain, clientID: config.clientID, redirectURL: FrolloSDKConfiguration.redirectURL, serverURL: config.serverEndpoint, authService: authService, preferences: preferences, delegate: nil)
        
        XCTAssertEqual(oAuth2Authentication.refreshToken, refreshToken)
        XCTAssertEqual(oAuth2Authentication.accessToken?.token, accessToken)
        XCTAssertEqual(oAuth2Authentication.accessToken?.expiryDate, expiryDate)
    }
    
    func testInvalidRefreshTokenFails() {
        let expectation1 = expectation(description: "API Response")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.details.path)) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "error_invalid_refresh_token", ofType: "json")!, status: 401, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let path = tempFolderPath()
        let preferences = Preferences(path: path)
        let authentication = Authentication(configuration: config)
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
                    XCTAssertNil(oAuth2Authentication.accessToken)
                    XCTAssertNil(oAuth2Authentication.refreshToken)
                    
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
        
        HTTPStubs.removeAllStubs()
        keychain.removeAll()
    }
    
}
