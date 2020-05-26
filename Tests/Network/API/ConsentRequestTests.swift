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

import OHHTTPStubs

@testable import FrolloSDK

class CDRRequestTests: BaseTestCase {
    
    var keychain: Keychain!
    var service: APIService!

    override func setUpWithError() throws {
        testsKeychainService = "ConsentRequestTests"
        
        super.setUp()
        
        keychain = defaultKeychain(isNetwork: true)
        service = defaultService(keychain: keychain)
    }

    override func tearDownWithError() throws {
        Keychain(service: keychainService).removeAll()
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testFetchConsents() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: CDREndpoint.consents.path.prefixedWithSlash, toResourceWithName: "consents_valid")
        
        service.fetchConsents() { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.count, 7)
                    
                    if let firstBill = response.first {
//                        XCTAssertEqual(firstBill.id, 1059)
//                        XCTAssertEqual(firstBill.name, "McDonald's Really Really Long Transaction Name for Bill Test")
//                        XCTAssertEqual(firstBill.description, "MCDONALDS AUS")
//                        XCTAssertEqual(firstBill.billType, .bill)
//                        XCTAssertEqual(firstBill.status, .confirmed)
//                        XCTAssertEqual(firstBill.dueAmount, "8.0")
//                        XCTAssertEqual(firstBill.averageAmount, "8.0")
//                        XCTAssertEqual(firstBill.frequency, .weekly)
//                        XCTAssertEqual(firstBill.paymentStatus, .overdue)
//                        XCTAssertEqual(firstBill.nextPaymentDate, "2018-08-19")
//                        XCTAssertEqual(firstBill.category?.id, 75)
//                        XCTAssertEqual(firstBill.category?.name, "Personal/Family")
//                        XCTAssertEqual(firstBill.merchant?.id, 81)
//                        XCTAssertEqual(firstBill.merchant?.name, "McDonald's")
//                        XCTAssertNil(firstBill.note)
//                        XCTAssertNil(firstBill.accountID)
//                        XCTAssertNil(firstBill.lastPaymentDate)
                    }
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }

}
