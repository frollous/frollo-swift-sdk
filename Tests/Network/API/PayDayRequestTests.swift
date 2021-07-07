//
//  Copyright © 2018 Frollo. All rights reserved.
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

class PayDayRequestTests: BaseTestCase {

    var keychain: Keychain!
    var service: APIService!

    override func setUp() {
        testsKeychainService = "PayDayRequestTests"
        
        super.setUp()
        
        keychain = defaultKeychain(isNetwork: true)
        service = defaultService(keychain: keychain)
    }
    
    override func tearDown() {
        Keychain(service: keychainService).removeAll()
        HTTPStubs.removeAllStubs()
        
        super.tearDown()
    }

    func testFetchPayDay() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: PayDayEndpoint.payDay.path.prefixedWithSlash, toResourceWithName: "pay_day", addingStatusCode: 200)
        
        service.fetchPayDay { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.frequency, PayDay.Period.monthly)
                    XCTAssertEqual(response.lastTransactionDate, "2017-12-01")
                    XCTAssertEqual(response.nextTransactionDate, "2018-01-31")
                    XCTAssertEqual(response.status, PayDay.Status.estimated)
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testUpdatePayDay() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: PayDayEndpoint.payDay.path.prefixedWithSlash, toResourceWithName: "pay_day", addingStatusCode: 200)
        
        let request = APIPayDayRequest.testCompleteData()
        
        service.updatePayDay(request: request) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.frequency, PayDay.Period.monthly)
                    XCTAssertEqual(response.lastTransactionDate, "2017-12-01")
                    XCTAssertEqual(response.nextTransactionDate, "2018-01-31")
                    XCTAssertEqual(response.status, PayDay.Status.estimated)
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }

    func testUpdatePayDayEncodeRequestFail() {
        let expectation1 = expectation(description: "Network Request")
        
        service = invalidService(keychain: keychain)
        connect(endpoint: PayDayEndpoint.payDay.path.prefixedWithSlash, toResourceWithName: "pay_day", addingStatusCode: 200)
        
        let request = APIPayDayRequest.testCompleteData()
        
        service.updatePayDay(request: request) { (result) in
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
    }

    
}
