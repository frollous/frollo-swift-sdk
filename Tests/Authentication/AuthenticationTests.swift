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

#if CORE && os(iOS)
import AppAuthCore
#else
import AppAuth
#endif

import OHHTTPStubs

class AuthenticationTests: BaseTestCase, AuthenticationDelegate, NetworkDelegate {
    
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
        
        connect(host: tokenEndpointHost, endpoint: config.tokenEndpoint.path, toResourceWithName: "token_valid")
        connect(endpoint: UserEndpoint.details.path.prefixedWithSlash, toResourceWithName: "user_details_complete")
        
        let keychain = Keychain(service: keychainService)
        let networkAuthenticator = defaultNetworkAuthenticator(keychain: keychain)
        let authentication = defaultAuthentication(keychain: keychain, networkAuthenticator: networkAuthenticator)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.loginUser(email: "user@frollo.us", password: "password") { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        XCTAssertTrue(authentication.loggedIn)
                        
                        XCTAssertEqual(networkAuthenticator.accessToken, "MTQ0NjJkZmQ5OTM2NDE1ZTZjNGZmZjI3")
                        XCTAssertEqual(networkAuthenticator.refreshToken, "IwOGYzYTlmM2YxOTQ5MGE3YmNmMDFkNTVk")
                        XCTAssertEqual(networkAuthenticator.expiryDate, Date(timeIntervalSince1970: 2550794799))
                        
                        XCTAssertNotNil(authentication.fetchUser(context: self.database.newBackgroundContext()))
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testInvalidLoginUser() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(host: tokenEndpointHost, endpoint: config.tokenEndpoint.path, toResourceWithName: "error_oauth2_invalid_grant", addingStatusCode: 401)
        connect(endpoint: UserEndpoint.details.path.prefixedWithSlash, toResourceWithName: "user_details_complete")

        let keychain = defaultKeychain(isNetwork: false)
        let networkAuthenticator = defaultNetworkAuthenticator(keychain: keychain)
        let authentication = defaultAuthentication(keychain: keychain, networkAuthenticator: networkAuthenticator)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.loginUser(email: "user@frollo.us", password: "wrong_password") { (result) in
                switch result {
                    case .failure(let error):
                        XCTAssertFalse(authentication.loggedIn)
                        
                        XCTAssertNil(authentication.fetchUser(context: self.database.newBackgroundContext()))
                        
                        XCTAssertNil(networkAuthenticator.accessToken)
                        XCTAssertNil(networkAuthenticator.refreshToken)
                        XCTAssertNil(networkAuthenticator.expiryDate)
                    
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
    
    func testInvalidLoginUserSecondaryFailure() {
        // Test that the user details fetch causes a logged out failure
        let expectation1 = expectation(description: "Network Request")
        
        connect(host: tokenEndpointHost, endpoint: config.tokenEndpoint.path, toResourceWithName: "token_valid")
        connect(endpoint: UserEndpoint.details.path.prefixedWithSlash, toResourceWithName: "error_invalid_access_token", addingStatusCode: 401)
        
        let keychain = defaultKeychain(isNetwork: false)
        let networkAuthenticator = defaultNetworkAuthenticator(keychain: keychain)
        let authentication = defaultAuthentication(keychain: keychain, networkAuthenticator: networkAuthenticator)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.loginUser(email: "user@frollo.us", password: "wrong_password") { (result) in
                switch result {
                    case .failure(let error):
                        XCTAssertFalse(authentication.loggedIn)
                        
                        XCTAssertNil(authentication.fetchUser(context: self.database.newBackgroundContext()))
                        
                        XCTAssertNil(networkAuthenticator.accessToken)
                        XCTAssertNil(networkAuthenticator.refreshToken)
                        XCTAssertNil(networkAuthenticator.expiryDate)
                        
                        if let apiError = error as? APIError {
                            XCTAssertEqual(apiError.type, .invalidAccessToken)
                        } else {
                            XCTFail("Wrong error returned")
                        }
                    case .success:
                        XCTFail("Wrong password should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 5.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testLoginUserFailsIfLoggedIn() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(host: tokenEndpointHost, endpoint: config.tokenEndpoint.path, toResourceWithName: "token_valid")
        connect(endpoint: UserEndpoint.register.path.prefixedWithSlash, toResourceWithName: "user_details_complete")
        
        let authentication = defaultAuthentication(loggedIn: true)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.loginUser(email: "user@frollo.us", password: "password") { (result) in
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
        
        connect(host: tokenEndpointHost, endpoint: config.tokenEndpoint.path, toResourceWithName: "token_valid")
        connect(endpoint: UserEndpoint.details.path.prefixedWithSlash, toResourceWithName: "user_details_complete")
        
        let keychain = defaultKeychain(isNetwork: false)
        let networkAuthenticator = defaultNetworkAuthenticator(keychain: keychain)
        let authentication = defaultAuthentication(keychain: keychain, networkAuthenticator: networkAuthenticator, loggedIn: false)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.loginUserUsingWeb(presenting: UIApplication.shared.keyWindow!.rootViewController!) { (result) in
                switch result {
                    case .failure(let error):
                        XCTAssertFalse(authentication.loggedIn)
                        
                        XCTAssertNil(authentication.fetchUser(context: self.database.newBackgroundContext()))
                        
                        XCTAssertNil(networkAuthenticator.accessToken)
                        XCTAssertNil(networkAuthenticator.refreshToken)
                        XCTAssertNil(networkAuthenticator.expiryDate)
                    
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
            let authURL = URL(string: "app://redirect?code=4VbXuJz8dfFiCaJh&state=smpNp40xhOR5hDUQRevUtPDjkEV5e9Xh0k7dtjaTelA")
            
            authentication.authorizationFlow?.resumeExternalUserAgentFlow(with: authURL)
            
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
        
        stub(condition: isHost(config.tokenEndpoint.host!) && isPath(config.tokenEndpoint.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "token_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.details.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let keychain = Keychain(service: keychainService)
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authService = OAuthService(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, redirectURL: config.redirectURL, network: network)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let authentication = Authentication(database: database, clientID: config.clientID, domain: config.serverEndpoint.host!, networkAuthenticator: networkAuthenticator, authService: authService, service: service, preferences: preferences, delegate: self)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.loginUserUsingWeb { (result) in
                switch result {
                    case .failure(let error):
                        XCTAssertFalse(authentication.loggedIn)
                        
                        XCTAssertNil(authentication.fetchUser(context: database.newBackgroundContext()))
                        
                        XCTAssertNil(networkAuthenticator.accessToken)
                        XCTAssertNil(networkAuthenticator.refreshToken)
                        XCTAssertNil(networkAuthenticator.expiryDate)
                        
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
            let authURL = URL(string: "app://redirect?code=4VbXuJz8dfFiCaJh&state=smpNp40xhOR5hDUQRevUtPDjkEV5e9Xh0k7dtjaTelA")
            
            authentication.authorizationFlow?.resumeExternalUserAgentFlow(with: authURL)
            
            expectation2.fulfill()
        }
        
        wait(for: [expectation1, expectation2], timeout: 5.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    #endif
    
    // MARK: - Register User
    
    func testRegisterUser() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(host: tokenEndpointHost, endpoint: config.tokenEndpoint.path, toResourceWithName: "token_valid")
        connect(endpoint: UserEndpoint.register.path.prefixedWithSlash, toResourceWithName: "user_details_complete", addingStatusCode: 201)
        
        let authentication = defaultAuthentication()
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.registerUser(firstName: "Frollo", lastName: "User", mobileNumber: "0412345678", postcode: "2060", dateOfBirth: Date(timeIntervalSince1970: 631152000), email: "user@frollo.us", password: "password") { (result) in
                switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    XCTAssertNotNil(authentication.fetchUser(context: self.database.newBackgroundContext()))
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testRegisterUserInvalid() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(host: tokenEndpointHost, endpoint: config.tokenEndpoint.path, toResourceWithName: "token_valid")
        connect(endpoint: UserEndpoint.register.path.prefixedWithSlash, toResourceWithName: "error_duplicate", addingStatusCode: 409)
        
        let keychain = defaultKeychain(isNetwork: false)
        let networkAuthenticator = defaultNetworkAuthenticator(keychain: keychain)
        let authentication = defaultAuthentication(keychain: keychain, networkAuthenticator: networkAuthenticator)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.registerUser(firstName: "Frollo", lastName: "User", mobileNumber: "0412345678", postcode: "2060", dateOfBirth: Date(timeIntervalSince1970: 631152000), email: "user@frollo.us", password: "password") { (result) in
                switch result {
                    case .failure(let error):
                        XCTAssertFalse(authentication.loggedIn)
                        
                        XCTAssertNil(authentication.fetchUser(context: self.database.newBackgroundContext()))
                        
                        XCTAssertNil(networkAuthenticator.accessToken)
                        XCTAssertNil(networkAuthenticator.refreshToken)
                        XCTAssertNil(networkAuthenticator.expiryDate)
                        
                        if let apiError = error as? APIError {
                            XCTAssertEqual(apiError.type, .alreadyExists)
                        } else {
                            XCTFail("Wrong error returned")
                        }
                    case .success:
                       XCTFail("Invalid registration data should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testRegisterUserInvalidSecondaryFailure() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(host: tokenEndpointHost, endpoint: config.tokenEndpoint.path, toResourceWithName: "error_oauth2_invalid_request", addingStatusCode: 400)
        connect(endpoint: UserEndpoint.register.path.prefixedWithSlash, toResourceWithName: "user_details_complete", addingStatusCode: 201)
        
        let keychain = defaultKeychain(isNetwork: false)
        let networkAuthenticator = defaultNetworkAuthenticator(keychain: keychain)
        let authentication = defaultAuthentication(keychain: keychain, networkAuthenticator: networkAuthenticator)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.registerUser(firstName: "Frollo", lastName: "User", mobileNumber: "0412345678", postcode: "2060", dateOfBirth: Date(timeIntervalSince1970: 631152000), email: "user@frollo.us", password: "password") { (result) in
                switch result {
                    case .failure(let error):
                        XCTAssertFalse(authentication.loggedIn)
                        
                        XCTAssertNil(authentication.fetchUser(context: self.database.newBackgroundContext()))
                        
                        XCTAssertNil(networkAuthenticator.accessToken)
                        XCTAssertNil(networkAuthenticator.refreshToken)
                        XCTAssertNil(networkAuthenticator.expiryDate)
                        
                        if let oAuthError = error as? OAuth2Error {
                            XCTAssertEqual(oAuthError.type, OAuth2Error.OAuth2ErrorType.invalidRequest)
                        } else {
                            XCTFail("Wrong error returned")
                        }
                    case .success:
                        XCTFail("Invalid registration data should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testRegisterUserFailsIfLoggedIn() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        connect(host: tokenEndpointHost, endpoint: config.tokenEndpoint.path, toResourceWithName: "token_valid")
        connect(endpoint: UserEndpoint.register.path.prefixedWithSlash, toResourceWithName: "user_details_complete", addingStatusCode: 201)
        
        let authentication = defaultAuthentication(loggedIn: true)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.registerUser(firstName: "Frollo", lastName: "User", mobileNumber: "0412345678", postcode: "2060", dateOfBirth: Date(timeIntervalSince1970: 631152000), email: "user@frollo.us", password: "password") { (result) in
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
    
    // MARK: - User Details
    
    func testRefreshUser() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: UserEndpoint.details.path.prefixedWithSlash, toResourceWithName: "user_details_complete")
        
        let keychain = validKeychain()
        let authentication = defaultAuthentication(keychain: keychain, loggedIn: true)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.refreshUser { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        XCTAssertNotNil(authentication.fetchUser(context: self.database.newBackgroundContext()))
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testUpdateUser() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: UserEndpoint.details.path.prefixedWithSlash, toResourceWithName: "user_details_complete")
        
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
            
            authentication.updateUser { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        XCTAssertNotNil(authentication.fetchUser(context: self.database.newBackgroundContext()))
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 5.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testUpdateUserFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: UserEndpoint.details.path, toResourceWithName: "user_details_complete")

        let keychain = validKeychain()
        let authentication = defaultAuthentication(keychain: keychain)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let moc = self.database.newBackgroundContext()
            
            moc.performAndWait {
                let user = User(context: moc)
                user.populateTestData()
                
                try! moc.save()
            }
            
            authentication.updateUser { (result) in
                switch result {
                    case .failure(let error):
                        if let dataError = error as? DataError {
                            XCTAssertEqual(dataError.type, .authentication)
                            XCTAssertEqual(dataError.subType, .loggedOut)
                        } else {
                            XCTFail("Wrong error type")
                        }
                    case .success:
                        XCTFail("Logged out, should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 5.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testUpdateUserFailsIfNonexistant() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: UserEndpoint.details.path, toResourceWithName: "user_details_complete")
        
        let keychain = validKeychain()
        let authentication = defaultAuthentication(keychain: keychain, loggedIn: true)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.updateUser { (result) in
                switch result {
                    case .failure(let error):
                        XCTAssertNil(authentication.fetchUser(context: self.database.viewContext))
                    
                        if let dataError = error as? DataError {
                            XCTAssertEqual(dataError.type, .database)
                            XCTAssertEqual(dataError.subType, .notFound)
                        } else {
                            XCTFail("Wrong error returned")
                        }
                    case .success:
                        XCTFail("User missing. Should fail.")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 5.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
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
            
            authentication.logoutUser()
            
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
        let authentication = defaultAuthentication(keychain: keychain, networkAuthenticator: networkAuthenticator, loggedIn: true)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let moc = self.database.newBackgroundContext()
            
            moc.performAndWait {
                let user = User(context: moc)
                user.populateTestData()
                
                try! moc.save()
            }
            
            authentication.updateUser { (result) in
                switch result {
                    case .failure:
                        XCTAssertNil(networkAuthenticator.refreshToken)
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
    
    func testChangePassword() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: UserEndpoint.user.path.prefixedWithSlash, addingData: Data(), addingStatusCode: 204)
        
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
            
            authentication.changePassword(currentPassword: UUID().uuidString, newPassword: UUID().uuidString, completion: { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        break
                }
                
                expectation1.fulfill()
            })
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testChangePasswordFailsIfTooShort() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: UserEndpoint.user.path.prefixedWithSlash, addingData: Data(), addingStatusCode: 204)
        
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
            
            authentication.changePassword(currentPassword: UUID().uuidString, newPassword: "1234", completion: { (result) in
                switch result {
                    case .failure(let error):
                        if let dataError = error as? DataError {
                            XCTAssertEqual(dataError.type, .api)
                            XCTAssertEqual(dataError.subType, .passwordTooShort)
                        } else {
                            XCTFail("Wrong error returned")
                        }
                    case .success:
                        XCTFail("Change password should fail")
                }
                
                expectation1.fulfill()
            })
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testDeleteUser() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: UserEndpoint.user.path.prefixedWithSlash, addingData: Data(), addingStatusCode: 204)
        
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
            
            authentication.deleteUser(completion: { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        XCTAssertFalse(authentication.loggedIn)
                }
                
                expectation1.fulfill()
            })
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testDeleteUserFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: UserEndpoint.user.path.prefixedWithSlash, addingData: Data(), addingStatusCode: 204)
        
        let keychain = validKeychain()
        let authentication = defaultAuthentication(keychain: keychain)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let moc = self.database.newBackgroundContext()
            
            moc.performAndWait {
                let user = User(context: moc)
                user.populateTestData()
                
                try! moc.save()
            }
            
            authentication.deleteUser(completion: { (result) in
                switch result {
                    case .failure(let error):
                        if let dataError = error as? DataError {
                            XCTAssertEqual(dataError.type, .authentication)
                            XCTAssertEqual(dataError.subType, .loggedOut)
                        } else {
                            XCTFail("Wrong error type")
                        }
                    case .success:
                        XCTFail("User logged out. Should fail")
                }
                
                expectation1.fulfill()
            })
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testResetPassword() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: UserEndpoint.resetPassword.path.prefixedWithSlash, addingData: Data(), addingStatusCode: 202)
        
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
            
            authentication.resetPassword(email: "test@domain.com", completion: { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        break
                }
                
                expectation1.fulfill()
            })
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testForcedLogoutIfMissingRefreshToken() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: UserEndpoint.details.path.prefixedWithSlash, toResourceWithName: "user_details_complete")
        
        let keychain = validKeychain()
        keychain["refreshToken"] = nil
        keychain["accessToken"] = nil
        
        let networkAuthenticator = defaultNetworkAuthenticator(keychain: keychain)
        let authentication = defaultAuthentication(keychain: keychain, networkAuthenticator: networkAuthenticator, loggedIn: true)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let moc = self.database.newBackgroundContext()
            
            moc.performAndWait {
                let user = User(context: moc)
                user.populateTestData()
                
                try! moc.save()
            }
            
            authentication.refreshUser { (result) in
                switch result {
                    case .failure:
                        XCTAssertNil(networkAuthenticator.refreshToken)
                        XCTAssertNil(networkAuthenticator.accessToken)
                    case .success:
                        XCTFail("Auth should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    // MARK: - Device
    
    func testUpdateDevice() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: DeviceEndpoint.device.path.prefixedWithSlash, addingData: Data(), addingStatusCode: 204)
        
        let keychain = validKeychain()
        let authentication = defaultAuthentication(keychain: keychain, loggedIn: true)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.updateDevice(notificationToken: "SomeToken12345", completion: { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        break
                }
                
                expectation1.fulfill()
            })
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testUpdateDeviceCompliance() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: DeviceEndpoint.device.path.prefixedWithSlash, addingData: Data(), addingStatusCode: 204)

        let keychain = validKeychain()
        let authentication = defaultAuthentication(keychain: keychain, loggedIn: true)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.updateDeviceCompliance(true) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        break
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    // MARK: - Tokens
    
    func testExchangeAuthorizationCode() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        connect(host: tokenEndpointHost, endpoint: config.tokenEndpoint.path, toResourceWithName: "token_valid")
        connect(endpoint: UserEndpoint.details.path.prefixedWithSlash, toResourceWithName: "user_details_complete")
        
        let keychain = defaultKeychain(isNetwork: false)
        let networkAuthenticator = defaultNetworkAuthenticator(keychain: keychain)
        let authentication = defaultAuthentication(keychain: keychain, networkAuthenticator: networkAuthenticator)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.exchangeAuthorizationCode(code: String.randomString(length: 32), codeVerifier: String.randomString(length: 32)) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        XCTAssertTrue(authentication.loggedIn)
                        
                        XCTAssertEqual(networkAuthenticator.accessToken, "MTQ0NjJkZmQ5OTM2NDE1ZTZjNGZmZjI3")
                        XCTAssertEqual(networkAuthenticator.refreshToken, "IwOGYzYTlmM2YxOTQ5MGE3YmNmMDFkNTVk")
                        XCTAssertEqual(networkAuthenticator.expiryDate, Date(timeIntervalSince1970: 2550794799))
                    
                        XCTAssertNotNil(authentication.fetchUser(context: self.database.newBackgroundContext()))
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testExchangeAuthorizationCodeInvalid() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        connect(host: tokenEndpointHost, endpoint: config.tokenEndpoint.path, toResourceWithName: "error_oauth2_invalid_grant", addingStatusCode: 401)
        connect(endpoint: UserEndpoint.details.path.prefixedWithSlash, toResourceWithName: "user_details_complete")

        let keychain = Keychain(service: keychainService)
        let networkAuthenticator = defaultNetworkAuthenticator(keychain: keychain)
        let authentication = defaultAuthentication(keychain: keychain, networkAuthenticator: networkAuthenticator)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.exchangeAuthorizationCode(code: String.randomString(length: 32), codeVerifier: String.randomString(length: 32)) { (result) in
                switch result {
                    case .failure(let error):
                        XCTAssertFalse(authentication.loggedIn)
                        
                        XCTAssertNil(authentication.fetchUser(context: self.database.newBackgroundContext()))
                        
                        XCTAssertNil(networkAuthenticator.accessToken)
                        XCTAssertNil(networkAuthenticator.refreshToken)
                        XCTAssertNil(networkAuthenticator.expiryDate)
                        
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
    
    func testExchangeAuthorizationCodeInvalidSecondaryFailure() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(host: tokenEndpointHost, endpoint: config.tokenEndpoint.path, toResourceWithName: "token_valid")
        connect(endpoint: UserEndpoint.details.path.prefixedWithSlash, toResourceWithName: "error_invalid_auth_head")

        let keychain = Keychain(service: keychainService)
        let networkAuthenticator = defaultNetworkAuthenticator(keychain: keychain)
        let authentication = defaultAuthentication(keychain: keychain, networkAuthenticator: networkAuthenticator)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.exchangeAuthorizationCode(code: String.randomString(length: 32), codeVerifier: String.randomString(length: 32)) { (result) in
                switch result {
                    case .failure(let error):
                        XCTAssertFalse(authentication.loggedIn)
                        
                        XCTAssertNil(authentication.fetchUser(context: self.database.newBackgroundContext()))
                        
                        XCTAssertNil(networkAuthenticator.accessToken)
                        XCTAssertNil(networkAuthenticator.refreshToken)
                        XCTAssertNil(networkAuthenticator.expiryDate)
                        
                        if let apiError = error as? DataError {
                            XCTAssertEqual(apiError.type, .api)
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
    
    func testExchangeLegacyAccessToken() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(host: tokenEndpointHost, endpoint: config.tokenEndpoint.path, toResourceWithName: "token_valid")
        
        let keychain = validKeychain()
        let networkAuthenticator = defaultNetworkAuthenticator(keychain: keychain)
        let authentication = defaultAuthentication(keychain: keychain, networkAuthenticator: networkAuthenticator, loggedIn: true)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.exchangeLegacyToken { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        XCTAssertTrue(authentication.loggedIn)
                        
                        XCTAssertEqual(networkAuthenticator.accessToken, "MTQ0NjJkZmQ5OTM2NDE1ZTZjNGZmZjI3")
                        XCTAssertEqual(networkAuthenticator.refreshToken, "IwOGYzYTlmM2YxOTQ5MGE3YmNmMDFkNTVk")
                        XCTAssertEqual(networkAuthenticator.expiryDate, Date(timeIntervalSince1970: 2550794799))
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testExchangeMissingRefreshTokenFails() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        connect(host: tokenEndpointHost, endpoint: config.tokenEndpoint.path, toResourceWithName: "token_valid")
        
        let keychain = Keychain(service: keychainService)
        let networkAuthenticator = defaultNetworkAuthenticator(keychain: keychain)
        let authentication = defaultAuthentication(keychain: keychain, networkAuthenticator: networkAuthenticator, loggedIn: true)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.exchangeLegacyToken { (result) in
                switch result {
                    case .failure(let error):
                        XCTAssertNil(networkAuthenticator.accessToken)
                        XCTAssertNil(networkAuthenticator.refreshToken)
                        XCTAssertNil(networkAuthenticator.expiryDate)
                    
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
    
    // MARK: - Web view
    
    func testAuthenticatingRequestManually() {
        let keychain = validKeychain()
        let authentication = defaultAuthentication(keychain: keychain)
        
        let requestURL = URL(string: "https://api.example.com/somewhere")!
        let request = URLRequest(url: requestURL)
        do {
            let adaptedRequest = try authentication.authenticateRequest(request)
            
            guard let authHeader = adaptedRequest.allHTTPHeaderFields?["Authorization"]
                else {
                    XCTFail("No auth header")
                    return
            }
            
            XCTAssertTrue(authHeader.contains("Bearer"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    // MARK: - Auth delegate
    
    func authenticationReset() {
        
    }
    
    // MARK: - Network logged out delegate
    
    func forcedLogout() {
        
    }
    
}
