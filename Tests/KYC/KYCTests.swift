//
//  Copyright © 2019 Frollo. All rights reserved.
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

import OHHTTPStubs
#if canImport(OHHTTPStubsSwift)
import OHHTTPStubsSwift
#endif

class KYCTests: XCTestCase {

    let keychainService = "KYCTests"
    var service: APIService!
    
    
    override func setUp() {
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(configuration: config)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        service = APIService(serverEndpoint: config.serverEndpoint, network: network)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        HTTPStubs.removeAllStubs()
        Keychain(service: keychainService).removeAll()
    }
    
    func testFetchKYC() {
        let expectation1 = expectation(description: "Network Request 1")
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + KYCEndpoint.kyc.path)) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "kyc_response_non_existent", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let kyc = KYC(service: service)
        kyc.getKYC { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let userKYC):
                    XCTAssertEqual(userKYC.email, "drsheldon@frollo.us")
                    XCTAssertEqual(userKYC.gender, nil)
                    XCTAssertEqual(userKYC.mobileNumber, nil)
                    XCTAssertEqual(userKYC.name?.givenName, nil)
                    XCTAssertEqual(userKYC.dateOfBirth?.dateOfBirth, nil)
                    XCTAssertEqual(userKYC.dateOfBirth?.yearOfBirth, nil)
                    XCTAssertEqual(userKYC.identityDocuments?.count, nil)
                    XCTAssertEqual(userKYC.status, .nonExistent)
            }
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        HTTPStubs.removeAllStubs()
    }
    
    func testCreateKYC() {
        let expectation1 = expectation(description: "Network Request 1")
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + KYCEndpoint.createVerify.path)) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "kyc_response", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let kyc = KYC(service: service)
        
    
        kyc.submitKYC(userKYC: KYCTests.createTestKyc()) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let userKYC):
                    XCTAssertEqual(userKYC.name?.middleName, "k")
                    XCTAssertEqual(userKYC.gender, "M")
                    XCTAssertEqual(userKYC.mobileNumber, "0421354444")
                    XCTAssertEqual(userKYC.name?.givenName, "Sheldon")
                    XCTAssertEqual(userKYC.dateOfBirth?.dateOfBirth, "1991-01-01")
                    XCTAssertEqual(userKYC.dateOfBirth?.yearOfBirth, "1991")
                    XCTAssertEqual(userKYC.identityDocuments?.count, 3)
                    XCTAssertEqual(userKYC.identityDocuments?[0].idNumber, "123456")
                    XCTAssertEqual(userKYC.identityDocuments?[0].idType, .birthCert)
                    XCTAssertEqual(userKYC.identityDocuments?[0].idSubType, "certificate")
                    XCTAssertEqual(userKYC.identityDocuments?[0].country, "AU")
                    XCTAssertEqual(userKYC.identityDocuments?[0].region, "Sydney")
                    XCTAssertEqual(userKYC.status, .verified)
            }
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        HTTPStubs.removeAllStubs()
    }
    
    func testUpdateKYC() {
        let expectation1 = expectation(description: "Network Request 1")
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + KYCEndpoint.createVerify.path)) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "kyc_response_medicare", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let kyc = KYC(service: service)
        
        kyc.submitKYC(userKYC: KYCTests.createTestKyc()) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let userKYC):
                    XCTAssertEqual(userKYC.name?.middleName, "A")
                    XCTAssertEqual(userKYC.gender, "M")
                    XCTAssertEqual(userKYC.mobileNumber, "+61411458987")
                    XCTAssertEqual(userKYC.name?.givenName, "JAMES")
                    XCTAssertEqual(userKYC.dateOfBirth?.dateOfBirth, "1950-01-01")
                    XCTAssertEqual(userKYC.dateOfBirth?.yearOfBirth, nil)
                    XCTAssertEqual(userKYC.identityDocuments?.count, 2)
                    XCTAssertEqual(userKYC.identityDocuments?[0].idNumber, "283229690")
                    XCTAssertEqual(userKYC.identityDocuments?[0].idType, .driverLicence)
                    XCTAssertEqual(userKYC.identityDocuments?[0].idSubType, nil)
                    XCTAssertEqual(userKYC.identityDocuments?[0].country, "AUS")
                    XCTAssertEqual(userKYC.identityDocuments?[0].region, "VIC")
                    XCTAssertEqual(userKYC.status, .unverified)
            }
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        HTTPStubs.removeAllStubs()
    }
    
    func testSubmitKYCEncodeFail() {
        let expectation1 = expectation(description: "Network Request 1")
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + KYCEndpoint.createVerify.path)) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "kyc_response", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(configuration: config)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication, encoder: InvalidEncoder())
        service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let kyc = KYC(service: service)
        
    
        kyc.submitKYC(userKYC: KYCTests.createTestKyc()) { (result) in
            switch result {
                case .success:
                    XCTFail("Encode data should not success")
                case .failure(let error):
                    if let error = error as? DataError {
                        XCTAssertEqual(error.type, .api)
                        XCTAssertEqual(error.subType, .invalidData)
                    } else {
                        XCTFail("Not correct error type")
                    }
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        HTTPStubs.removeAllStubs()
    }
}


extension KYCTests {
    
    static func createTestKyc() -> UserKYC {
        
        return UserKYC(dateOfBirth: UserKYC.DateOfBirth(dateOfBirth: "1991-01-01", yearOfBirth: "1991"), email: "drsheldon@frollo.us", gender: "M", mobileNumber: "0421354444", name: UserKYC.Name(displayName: "Sheldon", familyName: "Cooper", givenName: "Shelly", honourific: "Dr", middleName: "K"), identityDocuments: [UserKYC.IdentityDocument(country: "AU", idExpiry: "2022-12-12", idNumber: "123456", idSubType: "certificate", idType: .nationalHealthID, region: "Sydney")], status: .verified)
    }
}
