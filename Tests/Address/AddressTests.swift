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
import Alamofire

class AddressTests: BaseTestCase {

    override func setUp() {
        testsKeychainService = "UserManagementTestsKeychain"
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }

    override func tearDown() {
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
    
    
    func testAdressAutocomplete() {
        let expectation1 = expectation(description: "Network Request")

        let config = FrolloSDKConfiguration.testConfig()

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.addressesAutocomplete.path)) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "address_autocomplete", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }


        let keychain = validKeychain()
        let networkAuthenticator = defaultAuthentication(keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)

        let authentication = defaultOAuth2Authentication(keychain: keychain, loggedIn: true)
        let user = UserManagement(database: database, service: service, clientID: config.clientID, authentication: authentication, preferences: preferences, delegate: nil)

        user.addressAutocomplete(query: "ashmole", max: 20) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail("Data response should not fail \(error)")
                case .success(let addresses):
                    XCTAssertEqual(addresses.count, 20)
                    XCTAssertEqual(addresses.first!.id, "c3a85816-a9c5-11eb-81f0-68c07153d52e")
                    XCTAssertEqual(addresses.last!.address, "65 Ashmole Road, REDCLIFFE QLD 4020")
            }

            expectation1.fulfill()
        }
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchAddressByID() {
        let expectation1 = expectation(description: "Network Request")

        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.address(addressID: "c3a85816-a9c5-11eb-81f0-68c07153d52e").path)) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "address_get", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        let keychain = validKeychain()
        let networkAuthenticator = defaultAuthentication(keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)

        let authentication = defaultOAuth2Authentication(keychain: keychain, loggedIn: true)
        let user = UserManagement(database: database, service: service, clientID: config.clientID, authentication: authentication, preferences: preferences, delegate: nil)

        user.getAddress(for: "c3a85816-a9c5-11eb-81f0-68c07153d52e") { (result) in
            switch result {
                case .failure(let error):
                    XCTFail("Data response should not fail \(error)")
                case .success(let address):
                    XCTAssertEqual(address.streetNumber!, "105")
                    XCTAssertEqual(address.suburb!, "Redcliffe")
                    XCTAssertEqual(address.country!, "AU")
            }

            expectation1.fulfill()
        }
        wait(for: [expectation1], timeout: 3.0)
    }

}
