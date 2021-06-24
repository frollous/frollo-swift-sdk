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

import CoreData
import XCTest
import OHHTTPStubs
#if canImport(OHHTTPStubsSwift)
import OHHTTPStubsSwift
#endif
@testable import FrolloSDK

class AddressTests: BaseTestCase {
    
    var address: AddressManagement!

    override func setUp() {
        testsKeychainService = "UserManagementTestsKeychain"
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let config = FrolloSDKConfiguration.testConfig()

        let keychain = validKeychain()
        let networkAuthenticator = defaultAuthentication(keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)

        address = AddressManagement(database: database, service: service)
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
    
    func testCreateAddress() {
        let expectation1 = expectation(description: "Network Request 1")

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AddressEndpoint.addresses.path) && isMethodPOST()) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "create_address", ofType: "json")!, status: 201, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        database.setup { (error) in
            XCTAssertNil(error)
            
            self.address.createAddress(unitNumber: "1", buildingName: "Test building", streetNumber: "22", streetName: "Street name", streetType: "road", suburb: "suburb name", region: "Sycney", state: "NSW", country: "AUD", postcode: "2210") { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = self.database.viewContext

                        let fetchRequest: NSFetchRequest<Address> = Address.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "addressID == %ld", argumentArray: [3])

                        do {
                            let fetchedCards = try context.fetch(fetchRequest)

                            XCTAssertEqual(fetchedCards.first?.addressID, 3)
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                }

                expectation1.fulfill()
            }
        }

        wait(for: [expectation1], timeout: 3.0)
        HTTPStubs.removeAllStubs()
    }
    
    func testRefreshAddresses() {
        let expectation1 = expectation(description: "Network Request 1")

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AddressEndpoint.addresses.path) && isMethodGET()) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "get_addresses", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        database.setup { (error) in
            XCTAssertNil(error)
            
            self.address.refreshAddresses() { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = self.database.viewContext

                        let fetchRequest: NSFetchRequest<Address> = Address.fetchRequest()
                        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Address.addressID), ascending: true)]
                        do {
                            let fetchedAddresses = try context.fetch(fetchRequest)
                            XCTAssertEqual(fetchedAddresses.count, 2)

                            XCTAssertEqual(fetchedAddresses.first?.addressID, 3)
                            XCTAssertEqual(fetchedAddresses.last?.addressID, 4)
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                }

                expectation1.fulfill()
            }
        }

        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testRefreshAddressesFail() {
        let expectation1 = expectation(description: "Network Request 1")
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AddressEndpoint.addresses.path) && isMethodGET()) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "get_addresses", ofType: "json")!, status: 404, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        database.setup { (error) in
            XCTAssertNil(error)


            self.address.refreshAddresses() { (result) in
                switch result {
                    case .failure(let error):
                        XCTAssertTrue(error is APIError)
                        if let error = error as? APIError {
                            XCTAssertEqual(error.statusCode, 404)
                        }
                    case .success:
                        XCTFail("Data response is invalid")
                }

                expectation1.fulfill()
            }
        }

        wait(for: [expectation1], timeout: 3.0)
    }
    
    

    func testRefreshAddressByID() {
        let expectation1 = expectation(description: "Network Request 1")

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AddressEndpoint.address(id: 3).path) && isMethodGET()) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "get_address_by_id", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        database.setup { (error) in
            XCTAssertNil(error)


            self.address.refreshAddress(addressID: 3) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = self.database.viewContext

                        let fetchRequest: NSFetchRequest<Address> = Address.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "addressID == %ld", argumentArray: [3])

                        do {
                            let fetchedAddresses = try context.fetch(fetchRequest)

                            XCTAssertEqual(fetchedAddresses.first?.addressID, 3)
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                }

                expectation1.fulfill()
            }
        }

        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testAdressAutocomplete() {
        let expectation1 = expectation(description: "Network Request")

        let config = FrolloSDKConfiguration.testConfig()

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AddressEndpoint.addressesAutocomplete.path)) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "address_autocomplete", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        address.addressAutocomplete(query: "ashmole", max: 20) { (result) in
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
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AddressEndpoint.addressAutocomplete(addressID: "c3a85816-a9c5-11eb-81f0-68c07153d52e").path)) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "address_get", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        address.fetchAddress(for: "c3a85816-a9c5-11eb-81f0-68c07153d52e") { (result) in
            switch result {
                case .failure(let error):
                    XCTFail("Data response should not fail \(error)")
                case .success(let address):
                    XCTAssertEqual(address.streetNumber!, "105")
                    XCTAssertEqual(address.suburb!, "Redcliffe")
                    XCTAssertEqual(address.country, "AU")
            }

            expectation1.fulfill()
        }
        wait(for: [expectation1], timeout: 3.0)
    }

}
