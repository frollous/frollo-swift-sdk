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

class AuthenticationTests: XCTestCase {
    
    private let keychain = Keychain(service: "AuthenticationTestsKeychain")
    private let serverURL = URL(string: "https://api.example.com")!
    
    private var authentication: Authentication!
    private var network: Network!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        keychain["refreshToken"] = "AnExistingRefreshToken"
        keychain["accessToken"] = "AnExistingAccessToken"
        keychain["accessTokenExpiry"] = String(Date(timeIntervalSinceNow: 1000).timeIntervalSince1970) // Not expired by time
        
        network = Network(serverURL: serverURL, keychain: keychain)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testLoginUser() {
        let expectation1 = expectation(description: "Network Request")
        
        stub(condition: isHost(serverURL.host!) && isPath("/" + UserEndpoint.login.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
        }
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let authentication = Authentication(database: database, network: network, preferences: preferences)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.loginUser(method: .email, email: "user@frollo.us", password: "password") { (error) in
                XCTAssertNil(error)
                
                XCTAssertNotNil(authentication.user)
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testRegisterUser() {
        let expectation1 = expectation(description: "Network Request")
        
        stub(condition: isHost(serverURL.host!) && isPath("/" + UserEndpoint.register.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, status: 201, headers: [Network.HTTPHeader.contentType: "application/json"])
        }
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let authentication = Authentication(database: database, network: network, preferences: preferences)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.registerUser(firstName: "Frollo", lastName: "User", email: "user@frollo.us", password: "password") { (error) in
                XCTAssertNil(error)
                
                XCTAssertNotNil(authentication.user)
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testRefreshUser() {
        let expectation1 = expectation(description: "Network Request")
        
        stub(condition: isHost(serverURL.host!) && isPath("/" + UserEndpoint.details.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
        }
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let authentication = Authentication(database: database, network: network, preferences: preferences)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            authentication.refreshUser { (error) in
                XCTAssertNil(error)
                
                XCTAssertNotNil(authentication.user)
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testUpdateUser() {
        let expectation1 = expectation(description: "Network Request")
        
        stub(condition: isHost(serverURL.host!) && isPath("/" + UserEndpoint.details.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
        }
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let authentication = Authentication(database: database, network: network, preferences: preferences)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let moc = database.newBackgroundContext()
            
            moc.performAndWait {
                let user = User(context: moc)
                user.populateTestData()
                
                try! moc.save()
            }
            
            authentication.updateUser { (error) in
                XCTAssertNil(error)
                
                XCTAssertNotNil(authentication.user)
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
}
