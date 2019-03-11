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
    
    func testRegisterUser() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.register.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, status: 201, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let registerRequest = APIUserRegisterRequest.testData()
        
        service.registerUser(request: registerRequest) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.userID, 12345)
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        OHHTTPStubs.removeAllStubs()
    }
    
    // MARK: - Refresh User
    
    func testFetchUserComplete() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.details.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        let date = dateFormatter.date(from: "1990-01")
        
        service.fetchUser { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let userResponse):
                    XCTAssertEqual(userResponse.userID, 12345)
                    XCTAssertEqual(userResponse.firstName, "Jacob")
                    XCTAssertEqual(userResponse.lastName, "Frollo")
                    XCTAssertEqual(userResponse.email, "jacob@frollo.us")
                    XCTAssertEqual(userResponse.emailVerified, true)
                    XCTAssertEqual(userResponse.status, .active)
                    XCTAssertEqual(userResponse.primaryCurrency, "AUD")
                    XCTAssertEqual(userResponse.gender, .male)
                    XCTAssertEqual(userResponse.dateOfBirth, date)
                    XCTAssertEqual(userResponse.mobileNumber, "0412345678")
                    XCTAssertEqual(userResponse.address?.line1, "41 McLaren Street")
                    XCTAssertEqual(userResponse.address?.line2, "Frollo Level 1")
                    XCTAssertEqual(userResponse.address?.postcode, "2060")
                    XCTAssertEqual(userResponse.address?.suburb, "North Sydney")
                    XCTAssertEqual(userResponse.previousAddress?.line1, "Bay 9 Middlemiss St")
                    XCTAssertEqual(userResponse.previousAddress?.line2, "Frollo Unit 13")
                    XCTAssertEqual(userResponse.previousAddress?.postcode, "2060")
                    XCTAssertEqual(userResponse.previousAddress?.suburb, "Lavender Bay")
                    XCTAssertEqual(userResponse.attribution?.adGroup, "ADGROUP1")
                    XCTAssertEqual(userResponse.attribution?.creative, "CREATIVE1")
                    XCTAssertEqual(userResponse.attribution?.campaign, "CAMPAIGN1")
                    XCTAssertEqual(userResponse.attribution?.network, "FACEBOOK")
                    XCTAssertEqual(userResponse.householdType, .single)
                    XCTAssertEqual(userResponse.occupation, .communityAndPersonalServiceWorkers)
                    XCTAssertEqual(userResponse.industry, .electricityGasWaterAndWasteServices)
                    XCTAssertEqual(userResponse.householdSize, 2)
                    XCTAssertEqual(userResponse.facebookID, "1234567890")
                    XCTAssertEqual(userResponse.validPassword, true)
                    XCTAssertEqual(userResponse.features, [User.FeatureFlag(enabled: true, feature: "aggregation")])
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        OHHTTPStubs.removeAllStubs()
    }
    
    func testFetchUserIncomplete() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.details.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_incomplete", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        service.fetchUser { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let userResponse):
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
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        OHHTTPStubs.removeAllStubs()
    }
    
    func testFetchUserInvalid() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.details.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_invalid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        service.fetchUser { (result) in
            switch result {
                case .failure:
                    break
                case .success:
                    XCTFail("User was invalid so should fail")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testChangePassword() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.user.path)) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 204, headers: nil)
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let changePasswordRequest = APIUserChangePasswordRequest.testData()
        
        service.changePassword(request: changePasswordRequest) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        OHHTTPStubs.removeAllStubs()
    }
    
    func testDeleteUser() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.user.path)) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 204, headers: nil)
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        service.deleteUser() { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        OHHTTPStubs.removeAllStubs()
    }
    
}
