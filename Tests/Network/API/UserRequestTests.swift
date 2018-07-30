//
//  UserRequestTests.swift
//  FrolloSDKTests
//
//  Created by Nick Dawson on 13/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import XCTest
@testable import FrolloSDK

import OHHTTPStubs

class UserRequestTests: XCTestCase {
    
    private let keychainService = "UserRequestTests"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        Keychain(service: keychainService).removeAll()
        OHHTTPStubs.removeAllStubs()
    }
    
    // MARK: - Login User
    
    func testLoginUserEmail() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + UserEndpoint.login.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        let loginRequest = APIUserLoginRequest.testEmailData()
        
        network.loginUser(request: loginRequest) { (response, error) in
            XCTAssertNil(error)
            
            if let userResponse = response {
                XCTAssertEqual(userResponse.userID, 12345)
            } else {
                XCTFail("No response object")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        OHHTTPStubs.removeAllStubs()
    }
    
    func testLoginUserFacebook() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + UserEndpoint.login.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        let loginRequest = APIUserLoginRequest.testFacebookData()
        
        network.loginUser(request: loginRequest) { (response, error) in
            XCTAssertNil(error)
            
            if let userResponse = response {
                XCTAssertEqual(userResponse.userID, 12345)
            } else {
                XCTFail("No response object")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        OHHTTPStubs.removeAllStubs()
    }
    
    func testLoginUserVolt() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + UserEndpoint.login.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        let loginRequest = APIUserLoginRequest.testVoltData()
        
        network.loginUser(request: loginRequest) { (response, error) in
            XCTAssertNil(error)
            
            if let userResponse = response {
                XCTAssertEqual(userResponse.userID, 12345)
            } else {
                XCTFail("No response object")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        OHHTTPStubs.removeAllStubs()
    }
    
    func testLoginUserInvalid() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        let loginRequest = APIUserLoginRequest.testInvalidData()
        
        network.loginUser(request: loginRequest) { (response, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(response)
            
            if let dataError = error as? DataError {
                XCTAssertEqual(dataError.type, .api)
                XCTAssertEqual(dataError.subType, .invalidData)
            } else {
                XCTFail("Wrong error")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    // MARK: - Refresh User
    
    func testFetchUserComplete() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + UserEndpoint.details.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        let date = dateFormatter.date(from: "1990-01")
        
        network.fetchUser { (response, error) in
            XCTAssertNil(error)
            
            if let userResponse = response {
                XCTAssertEqual(userResponse.userID, 12345)
                XCTAssertEqual(userResponse.firstName, "Jacob")
                XCTAssertEqual(userResponse.lastName, "Frollo")
                XCTAssertEqual(userResponse.email, "jacob@frollo.us")
                XCTAssertEqual(userResponse.emailVerified, true)
                XCTAssertEqual(userResponse.status, .active)
                XCTAssertEqual(userResponse.primaryCurrency, "AUD")
                XCTAssertEqual(userResponse.gender, .male)
                XCTAssertEqual(userResponse.dateOfBirth, date)
                XCTAssertEqual(userResponse.address?.postcode, "2060")
                XCTAssertEqual(userResponse.householdType, .single)
                XCTAssertEqual(userResponse.occupation, .communityAndPersonalServiceWorkers)
                XCTAssertEqual(userResponse.industry, .electricityGasWaterAndWasteServices)
                XCTAssertEqual(userResponse.householdSize, 2)
                XCTAssertEqual(userResponse.facebookID, "1234567890")
                XCTAssertEqual(userResponse.validPassword, true)
                XCTAssertEqual(userResponse.features, [User.FeatureFlag(enabled: true, feature: .aggregation)])
            } else {
                XCTFail("No response object")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        OHHTTPStubs.removeAllStubs()
    }
    
    func testFetchUserIncomplete() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + UserEndpoint.details.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_incomplete", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchUser { (response, error) in
            XCTAssertNil(error)
            
            if let userResponse = response {
                XCTAssertEqual(userResponse.userID, 12345)
                XCTAssertEqual(userResponse.firstName, "Jacob")
                XCTAssertNil(userResponse.lastName)
                XCTAssertEqual(userResponse.email, "jacob@frollo.us")
                XCTAssertEqual(userResponse.emailVerified, true)
                XCTAssertEqual(userResponse.status, .active)
                XCTAssertEqual(userResponse.primaryCurrency, "AUD")
                XCTAssertNil(userResponse.gender)
                XCTAssertNil(userResponse.dateOfBirth)
                XCTAssertNil(userResponse.address?.postcode)
                XCTAssertNil(userResponse.householdType)
                XCTAssertNil(userResponse.occupation)
                XCTAssertNil(userResponse.industry)
                XCTAssertNil(userResponse.householdSize)
                XCTAssertNil(userResponse.facebookID)
                XCTAssertNil(userResponse.features)
                XCTAssertEqual(userResponse.validPassword, true)
            } else {
                XCTFail("No response object")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        OHHTTPStubs.removeAllStubs()
    }
    
    func testFetchUserInvalid() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + UserEndpoint.details.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_invalid", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchUser { (response, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(response)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
}
