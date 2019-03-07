//
//  AuthenticationTests.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 25/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import XCTest
@testable import FrolloSDK

#if CORE && os(iOS)
import AppAuthCore
#elseif os(tvOS)
import AppAUth
#else
import AppAuth
#endif

import OHHTTPStubs

class AuthenticationTests: XCTestCase, AuthenticationDelegate, NetworkDelegate {
    
    private let keychainService = "AuthenticationTestsKeychain"
    
    private var authentication: Authentication!
    
    override func setUp() {
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
            
            authentication.loginUser(email: "user@frollo.us", password: "password") { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        XCTAssertTrue(authentication.loggedIn)
                        
                        XCTAssertEqual(networkAuthenticator.accessToken, "MTQ0NjJkZmQ5OTM2NDE1ZTZjNGZmZjI3")
                        XCTAssertEqual(networkAuthenticator.refreshToken, "IwOGYzYTlmM2YxOTQ5MGE3YmNmMDFkNTVk")
                        XCTAssertEqual(networkAuthenticator.expiryDate, Date(timeIntervalSince1970: 2550794799))
                        
                        XCTAssertNotNil(authentication.fetchUser(context: database.newBackgroundContext()))
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testInvalidLoginUser() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.tokenEndpoint.host!) && isPath(config.tokenEndpoint.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "error_invalid_username_password", ofType: "json")!, status: 401, headers: [HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.details.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, headers: [HTTPHeader.contentType.rawValue: "application/json"])
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
            
            authentication.loginUser(email: "user@frollo.us", password: "wrong_password") { (result) in
                switch result {
                    case .failure(let error):
                        XCTAssertFalse(authentication.loggedIn)
                        
                        XCTAssertNil(authentication.fetchUser(context: database.newBackgroundContext()))
                    
                        XCTAssertNil(networkAuthenticator.accessToken)
                        XCTAssertNil(networkAuthenticator.refreshToken)
                        XCTAssertNil(networkAuthenticator.expiryDate)
                    
                        if let apiError = error as? APIError {
                            XCTAssertEqual(apiError.type, .invalidUsernamePassword)
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
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.tokenEndpoint.host!) && isPath(config.tokenEndpoint.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "token_valid", ofType: "json")!, headers: [HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.details.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "error_invalid_access_token", ofType: "json")!, status: 401, headers: [HTTPHeader.contentType.rawValue: "application/json"])
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
            
            authentication.loginUser(email: "user@frollo.us", password: "wrong_password") { (result) in
                switch result {
                    case .failure(let error):
                        XCTAssertFalse(authentication.loggedIn)
                        
                        XCTAssertNil(authentication.fetchUser(context: database.newBackgroundContext()))
                        
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
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.tokenEndpoint.host!) && isPath(config.tokenEndpoint.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "token_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.register.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, status: 201, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
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
        authentication.loggedIn = true
        
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
        
        let viewController = UIViewController()
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.loginUserUsingWeb(presenting: viewController) { (result) in
                switch result {
                    case .failure(let error):
                        XCTAssertFalse(authentication.loggedIn)
                        
                        XCTAssertNil(authentication.fetchUser(context: database.newBackgroundContext()))
                        
                        XCTAssertNil(networkAuthenticator.accessToken)
                        XCTAssertNil(networkAuthenticator.refreshToken)
                        XCTAssertNil(networkAuthenticator.expiryDate)
                    
                        if let authError = error as? OAuthError {
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
        
        _ = viewController
        
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
                        
                        if let authError = error as? OAuthError {
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
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.tokenEndpoint.host!) && isPath(config.tokenEndpoint.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "token_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.register.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, status: 201, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
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
            
            authentication.registerUser(firstName: "Frollo", lastName: "User", mobileNumber: "0412345678", postcode: "2060", dateOfBirth: Date(timeIntervalSince1970: 631152000), email: "user@frollo.us", password: "password") { (result) in
                switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    XCTAssertNotNil(authentication.fetchUser(context: database.newBackgroundContext()))
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testRegisterUserInvalid() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.tokenEndpoint.host!) && isPath(config.tokenEndpoint.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "token_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.register.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "error_duplicate", ofType: "json")!, status: 409, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
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
            
            authentication.registerUser(firstName: "Frollo", lastName: "User", mobileNumber: "0412345678", postcode: "2060", dateOfBirth: Date(timeIntervalSince1970: 631152000), email: "user@frollo.us", password: "password") { (result) in
                switch result {
                    case .failure(let error):
                        XCTAssertFalse(authentication.loggedIn)
                        
                        XCTAssertNil(authentication.fetchUser(context: database.newBackgroundContext()))
                        
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
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.tokenEndpoint.host!) && isPath(config.tokenEndpoint.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "error_invalid_username_password", ofType: "json")!, status: 401, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.register.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, status: 201, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
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
            
            authentication.registerUser(firstName: "Frollo", lastName: "User", mobileNumber: "0412345678", postcode: "2060", dateOfBirth: Date(timeIntervalSince1970: 631152000), email: "user@frollo.us", password: "password") { (result) in
                switch result {
                    case .failure(let error):
                        XCTAssertFalse(authentication.loggedIn)
                        
                        XCTAssertNil(authentication.fetchUser(context: database.newBackgroundContext()))
                        
                        XCTAssertNil(networkAuthenticator.accessToken)
                        XCTAssertNil(networkAuthenticator.refreshToken)
                        XCTAssertNil(networkAuthenticator.expiryDate)
                        
                        if let apiError = error as? APIError {
                            XCTAssertEqual(apiError.type, .invalidUsernamePassword)
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
        
        stub(condition: isHost(config.tokenEndpoint.host!) && isPath(config.tokenEndpoint.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "token_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.register.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, status: 201, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
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
        authentication.loggedIn = true
        
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
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.details.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let keychain = validKeychain()
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authService = OAuthService(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, redirectURL: config.redirectURL, network: network)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let authentication = Authentication(database: database, clientID: config.clientID, domain: config.serverEndpoint.host!, networkAuthenticator: networkAuthenticator, authService: authService, service: service, preferences: preferences, delegate: self)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.loggedIn = true
            
            authentication.refreshUser { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        XCTAssertNotNil(authentication.fetchUser(context: database.newBackgroundContext()))
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testUpdateUser() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.details.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let keychain = validKeychain()
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authService = OAuthService(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, redirectURL: config.redirectURL, network: network)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let authentication = Authentication(database: database, clientID: config.clientID, domain: config.serverEndpoint.host!, networkAuthenticator: networkAuthenticator, authService: authService, service: service, preferences: preferences, delegate: self)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.loggedIn = true
            
            let moc = database.newBackgroundContext()
            
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
                        XCTAssertNotNil(authentication.fetchUser(context: database.newBackgroundContext()))
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 5.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testUpdateUserFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.details.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let keychain = validKeychain()
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authService = OAuthService(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, redirectURL: config.redirectURL, network: network)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let authentication = Authentication(database: database, clientID: config.clientID, domain: config.serverEndpoint.host!, networkAuthenticator: networkAuthenticator, authService: authService, service: service, preferences: preferences, delegate: self)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.loggedIn = false
            
            let moc = database.newBackgroundContext()
            
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
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.details.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let keychain = validKeychain()
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authService = OAuthService(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, redirectURL: config.redirectURL, network: network)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let authentication = Authentication(database: database, clientID: config.clientID, domain: config.serverEndpoint.host!, networkAuthenticator: networkAuthenticator, authService: authService, service: service, preferences: preferences, delegate: self)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.loggedIn = true
            
            authentication.updateUser { (result) in
                switch result {
                    case .failure(let error):
                        XCTAssertNil(authentication.fetchUser(context: database.viewContext))
                    
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
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.logout.path)) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 204, headers: nil)
        }
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let keychain = validKeychain()
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authService = OAuthService(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, redirectURL: config.redirectURL, network: network)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let authentication = Authentication(database: database, clientID: config.clientID, domain: config.serverEndpoint.host!, networkAuthenticator: networkAuthenticator, authService: authService, service: service, preferences: preferences, delegate: self)
        authentication.loggedIn = true
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let moc = database.newBackgroundContext()
            
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
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.details.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "error_suspended_device", ofType: "json")!, status: 401, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let keychain = validKeychain()
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authService = OAuthService(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, redirectURL: config.redirectURL, network: network)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        network.delegate = self
        
        let authentication = Authentication(database: database, clientID: config.clientID, domain: config.serverEndpoint.host!, networkAuthenticator: networkAuthenticator, authService: authService, service: service, preferences: preferences, delegate: self)
        authentication.loggedIn = true
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let moc = database.newBackgroundContext()
            
            moc.performAndWait {
                let user = User(context: moc)
                user.populateTestData()
                
                try! moc.save()
            }
            
            authentication.updateUser { (result) in
                switch result {
                    case .failure:
                        XCTAssertNil(network.authenticator.refreshToken)
                        XCTAssertNil(network.authenticator.accessToken)
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
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.user.path)) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 204, headers: nil)
        }
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let keychain = validKeychain()
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authService = OAuthService(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, redirectURL: config.redirectURL, network: network)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let authentication = Authentication(database: database, clientID: config.clientID, domain: config.serverEndpoint.host!, networkAuthenticator: networkAuthenticator, authService: authService, service: service, preferences: preferences, delegate: self)
        authentication.loggedIn = true
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let moc = database.newBackgroundContext()
            
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
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.user.path)) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 204, headers: nil)
        }
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let keychain = validKeychain()
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authService = OAuthService(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, redirectURL: config.redirectURL, network: network)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let authentication = Authentication(database: database, clientID: config.clientID, domain: config.serverEndpoint.host!, networkAuthenticator: networkAuthenticator, authService: authService, service: service, preferences: preferences, delegate: self)
        authentication.loggedIn = true
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let moc = database.newBackgroundContext()
            
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
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.user.path)) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 204, headers: nil)
        }
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let keychain = validKeychain()
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authService = OAuthService(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, redirectURL: config.redirectURL, network: network)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let authentication = Authentication(database: database, clientID: config.clientID, domain: config.serverEndpoint.host!, networkAuthenticator: networkAuthenticator, authService: authService, service: service, preferences: preferences, delegate: self)
        authentication.loggedIn = true
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let moc = database.newBackgroundContext()
            
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
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.user.path)) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 204, headers: nil)
        }
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let keychain = validKeychain()
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authService = OAuthService(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, redirectURL: config.redirectURL, network: network)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let authentication = Authentication(database: database, clientID: config.clientID, domain: config.serverEndpoint.host!, networkAuthenticator: networkAuthenticator, authService: authService, service: service, preferences: preferences, delegate: self)
        authentication.loggedIn = false
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let moc = database.newBackgroundContext()
            
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
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.resetPassword.path)) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 202, headers: nil)
        }
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let keychain = validKeychain()
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authService = OAuthService(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, redirectURL: config.redirectURL, network: network)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let authentication = Authentication(database: database, clientID: config.clientID, domain: config.serverEndpoint.host!, networkAuthenticator: networkAuthenticator, authService: authService, service: service, preferences: preferences, delegate: self)
        authentication.loggedIn = true
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let moc = database.newBackgroundContext()
            
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
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.details.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = validKeychain()
        keychain["refreshToken"] = nil
        keychain["accessToken"] = nil
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authService = OAuthService(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, redirectURL: config.redirectURL, network: network)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        network.delegate = self
        
        let authentication = Authentication(database: database, clientID: config.clientID, domain: config.serverEndpoint.host!, networkAuthenticator: networkAuthenticator, authService: authService, service: service, preferences: preferences, delegate: self)
        authentication.loggedIn = true
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let moc = database.newBackgroundContext()
            
            moc.performAndWait {
                let user = User(context: moc)
                user.populateTestData()
                
                try! moc.save()
            }
            
            authentication.refreshUser { (result) in
                switch result {
                    case .failure:
                        XCTAssertNil(network.authenticator.refreshToken)
                        XCTAssertNil(network.authenticator.accessToken)
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
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + DeviceEndpoint.device.path)) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 204, headers: nil)
        }
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let keychain = validKeychain()
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authService = OAuthService(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, redirectURL: config.redirectURL, network: network)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let authentication = Authentication(database: database, clientID: config.clientID, domain: config.serverEndpoint.host!, networkAuthenticator: networkAuthenticator, authService: authService, service: service, preferences: preferences, delegate: self)
        
        database.setup { (error) in
            XCTAssertNil(error)

            authentication.loggedIn = true
            
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
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + DeviceEndpoint.device.path)) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 204, headers: nil)
        }
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let keychain = validKeychain()
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authService = OAuthService(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, redirectURL: config.redirectURL, network: network)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let authentication = Authentication(database: database, clientID: config.clientID, domain: config.serverEndpoint.host!, networkAuthenticator: networkAuthenticator, authService: authService, service: service, preferences: preferences, delegate: self)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.loggedIn = true
            
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
            
            authentication.loggedIn = false
            
            authentication.exchangeAuthorizationCode(code: String.randomString(length: 32), codeVerifier: String.randomString(length: 32)) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        XCTAssertTrue(authentication.loggedIn)
                        
                        XCTAssertEqual(networkAuthenticator.accessToken, "MTQ0NjJkZmQ5OTM2NDE1ZTZjNGZmZjI3")
                        XCTAssertEqual(networkAuthenticator.refreshToken, "IwOGYzYTlmM2YxOTQ5MGE3YmNmMDFkNTVk")
                        XCTAssertEqual(networkAuthenticator.expiryDate, Date(timeIntervalSince1970: 2550794799))
                    
                        XCTAssertNotNil(authentication.fetchUser(context: database.newBackgroundContext()))
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
        
        stub(condition: isHost(config.tokenEndpoint.host!) && isPath(config.tokenEndpoint.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "error_invalid_username_password", ofType: "json")!, status: 401, headers: [HTTPHeader.contentType.rawValue: "application/json"])
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
            
            authentication.loggedIn = false
            
            authentication.exchangeAuthorizationCode(code: String.randomString(length: 32), codeVerifier: String.randomString(length: 32)) { (result) in
                switch result {
                    case .failure(let error):
                        XCTAssertFalse(authentication.loggedIn)
                        
                        XCTAssertNil(authentication.fetchUser(context: database.newBackgroundContext()))
                        
                        XCTAssertNil(networkAuthenticator.accessToken)
                        XCTAssertNil(networkAuthenticator.refreshToken)
                        XCTAssertNil(networkAuthenticator.expiryDate)
                        
                        if let apiError = error as? APIError {
                            XCTAssertEqual(apiError.type, .invalidUsernamePassword)
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
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.tokenEndpoint.host!) && isPath(config.tokenEndpoint.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "token_valid", ofType: "json")!, status: 401, headers: [HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.details.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "error_invalid_auth_head", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
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
            
            authentication.loggedIn = false
            
            authentication.exchangeAuthorizationCode(code: String.randomString(length: 32), codeVerifier: String.randomString(length: 32)) { (result) in
                switch result {
                    case .failure(let error):
                        XCTAssertFalse(authentication.loggedIn)
                        
                        XCTAssertNil(authentication.fetchUser(context: database.newBackgroundContext()))
                        
                        XCTAssertNil(networkAuthenticator.accessToken)
                        XCTAssertNil(networkAuthenticator.refreshToken)
                        XCTAssertNil(networkAuthenticator.expiryDate)
                        
                        if let apiError = error as? APIError {
                            XCTAssertEqual(apiError.type, .otherAuthorisation)
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
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.tokenEndpoint.host!) && isPath(config.tokenEndpoint.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "token_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let keychain = validKeychain()
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authService = OAuthService(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, redirectURL: config.redirectURL, network: network)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let authentication = Authentication(database: database, clientID: config.clientID, domain: config.serverEndpoint.host!, networkAuthenticator: networkAuthenticator, authService: authService, service: service, preferences: preferences, delegate: self)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.loggedIn = true
            
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
        
        stub(condition: isHost(config.tokenEndpoint.host!) && isPath(config.tokenEndpoint.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "token_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
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
            
            authentication.loggedIn = true
            
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
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let keychain = validKeychain()
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authService = OAuthService(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, redirectURL: config.redirectURL, network: network)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let authentication = Authentication(database: database, clientID: config.clientID, domain: config.serverEndpoint.host!, networkAuthenticator: networkAuthenticator, authService: authService, service: service, preferences: preferences, delegate: self)
        
        let requestURL = URL(string: "https://api.example.com/somewhere")!
        let request = URLRequest(url: requestURL)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
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
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    // MARK: - Auth delegate
    
    func authenticationReset() {
        
    }
    
    // MARK: - Network logged out delegate
    
    func forcedLogout() {
        
    }
    
}
