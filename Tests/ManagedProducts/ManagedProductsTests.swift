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

class ManagedProductsTests: XCTestCase {

    let keychainService = "ManagedProductsTests"
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
    
    func testFetchAllProducts() {
        
        let expectation1 = expectation(description: "Network Request 1")
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + ManagedProductEndpoint.availableProducts.path)) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "managed_products_response", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let managedProducts = ManagedProducts(service: service)
        managedProducts.listAvailableProducts(before: "20", after: "10", size: 10)  { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.data.count, 3)
                    XCTAssertEqual(response.total, 3)
                    XCTAssertEqual(response.before, nil)
                    XCTAssertEqual(response.after, nil)
                    XCTAssertEqual(response.data.first?.id, 1)
                    XCTAssertEqual(response.data.first?.accountType, "savings")
                    XCTAssertEqual(response.data.last?.container, "bank")
                    XCTAssertEqual(response.data.last?.termsConditions.first?.name, "Volt Bank Cash Terms & Conditions")
                    XCTAssertEqual(response.data.first?.termsConditions.count, 1)
            }
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        HTTPStubs.removeAllStubs()
    }
    
    func testFetchManagedProducts() {
        
        let expectation1 = expectation(description: "Network Request 1")
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + ManagedProductEndpoint.managedProducts.path)) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "managed_products_response", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let managedProducts = ManagedProducts(service: service)
        managedProducts.listManagedProducts(before: "10", size: 10) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.data.count, 3)
                    XCTAssertEqual(response.total, 3)
                    XCTAssertEqual(response.before, nil)
                    XCTAssertEqual(response.after, nil)
                    XCTAssertEqual(response.data.first?.id, 1)
                    XCTAssertEqual(response.data.first?.accountType, "savings")
                    XCTAssertEqual(response.data.last?.container, "bank")
                    XCTAssertEqual(response.data.last?.termsConditions.first?.name, "Volt Bank Cash Terms & Conditions")
                    XCTAssertEqual(response.data.first?.termsConditions.count, 1)
            }
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        HTTPStubs.removeAllStubs()
    }
    
    func testCreateProducts() {
        
        let expectation1 = expectation(description: "Network Request 1")
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + ManagedProductEndpoint.managedProducts.path)) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "managed_product_response", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let managedProducts = ManagedProducts(service: service)
        managedProducts.createManagedProduct(productID: 1, acceptedTermsConditionsIDs: [1,2], completion: { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.id, 1)
                    XCTAssertEqual(response.accountType, "savings")
                    XCTAssertEqual(response.container, "bank")
                    XCTAssertEqual(response.termsConditions.first?.name, "Volt Bank Savings Terms & Conditions")
                    XCTAssertEqual(response.termsConditions.count, 1)
            }
            expectation1.fulfill()
        })
        
        wait(for: [expectation1], timeout: 3.0)
        HTTPStubs.removeAllStubs()
    }
    
    func testCreateProductsEncodeFail() {
        
        let expectation1 = expectation(description: "Network Request 1")
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + ManagedProductEndpoint.managedProducts.path)) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "managed_product_response", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(configuration: config)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication, encoder: InvalidEncoder())
        service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let managedProducts = ManagedProducts(service: service)
        managedProducts.createManagedProduct(productID: 1, acceptedTermsConditionsIDs: [1,2], completion: { (result) in
            switch result {
            case .failure(let error):
                XCTAssertTrue(error is DataError)
                if let error = error as? DataError {
                    XCTAssertEqual(error.type, DataError.DataErrorType.api)
                    XCTAssertEqual(error.subType, DataError.DataErrorSubType.invalidData)
                }
            case .success:
                XCTFail("Invalid service throw Error when encoding")
            }
            
            expectation1.fulfill()
        })
        
        wait(for: [expectation1], timeout: 3.0)
        HTTPStubs.removeAllStubs()
    }
    
    func testDeleteProduct() {
        
        let expectation1 = expectation(description: "Network Request 1")
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + ManagedProductEndpoint.product(productID: 1).path)) { (request) -> HTTPStubsResponse in
            return HTTPStubsResponse(data: Data(), statusCode: 204, headers: nil)
        }
        
        let managedProducts = ManagedProducts(service: service)
        managedProducts.deleteManagedProduct(productID: 1) { result in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    XCTAssertTrue(true)
            }

            expectation1.fulfill()
        }
        wait(for: [expectation1], timeout: 3.0)
    }
}
