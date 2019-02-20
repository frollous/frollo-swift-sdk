//
//  AuthenticationTests.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 25/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import XCTest
@testable import FrolloSDK

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
    
    // MARK: - Tests
    
    func testLoginUser() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.login.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let keychain = validKeychain()
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authentication = Authentication(database: database, network: network, preferences: preferences, delegate: self)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.loginUser(method: .email, email: "user@frollo.us", password: "password") { (result) in
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
    
    func testInvalidLoginUser() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.login.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "error_invalid_username_password", ofType: "json")!, status: 401, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let keychain = validKeychain()
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authentication = Authentication(database: database, network: network, preferences: preferences, delegate: self)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.loginUser(method: .email, email: "user@frollo.us", password: "wrong_password") { (result) in
                switch result {
                    case .failure:
                        XCTAssertNil(authentication.fetchUser(context: database.newBackgroundContext()))
                    case .success:
                        XCTFail("Wrong password should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testRegisterUser() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.register.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, status: 201, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let keychain = validKeychain()
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authentication = Authentication(database: database, network: network, preferences: preferences, delegate: self)
        
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
    
    func testRefreshUser() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.details.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let keychain = validKeychain()
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authentication = Authentication(database: database, network: network, preferences: preferences, delegate: self)
        
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
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let keychain = validKeychain()
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authentication = Authentication(database: database, network: network, preferences: preferences, delegate: self)
        
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
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authentication = Authentication(database: database, network: network, preferences: preferences, delegate: self)
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
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "error_suspended_device", ofType: "json")!, status: 401, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let keychain = validKeychain()
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        network.delegate = self
        
        let authentication = Authentication(database: database, network: network, preferences: preferences, delegate: self)
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
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authentication = Authentication(database: database, network: network, preferences: preferences, delegate: self)
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
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authentication = Authentication(database: database, network: network, preferences: preferences, delegate: self)
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
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authentication = Authentication(database: database, network: network, preferences: preferences, delegate: self)
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
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authentication = Authentication(database: database, network: network, preferences: preferences, delegate: self)
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
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = validKeychain()
        keychain["refreshToken"] = nil
        keychain["accessToken"] = nil
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        network.delegate = self
        
        let authentication = Authentication(database: database, network: network, preferences: preferences, delegate: self)
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
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authentication = Authentication(database: database, network: network, preferences: preferences, delegate: self)
        
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
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authentication = Authentication(database: database, network: network, preferences: preferences, delegate: self)
        
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
    
    func testAuthenticatingRequestManually() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let keychain = validKeychain()
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authentication = Authentication(database: database, network: network, preferences: preferences, delegate: self)
        
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
