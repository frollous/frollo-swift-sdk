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

class ConsentRequestTests: BaseTestCase {
    
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
                    XCTAssertEqual(response.count, 8)
                    
                    if let firstConsent = response.first {
                        XCTAssertEqual(firstConsent.id, 351)
                        XCTAssertEqual(firstConsent.providerID, 11582)
                        XCTAssertEqual(firstConsent.providerAccountID, 623)
                        XCTAssertEqual(firstConsent.status, "withdrawn")
                        XCTAssertEqual(firstConsent.sharingDuration, 15814800)
                        XCTAssertNil(firstConsent.sharingStartedAt)
                        XCTAssertEqual(firstConsent.sharingStoppedAt, "2020-05-26")
                        XCTAssertEqual(firstConsent.permissions, ["account_details", "transaction_details"])
                        XCTAssertEqual(firstConsent.additionalPermissions, [:])
                        XCTAssertEqual(firstConsent.deleteRedundantData, true)
                        XCTAssertEqual(firstConsent.authorisationRequestURL, nil)
                        XCTAssertEqual(firstConsent.confirmationPDFURL, "https://example.com/api/v2/cdr/consents/351/pdfs/confirmation")
                        XCTAssertEqual(firstConsent.withdrawalPDFURL, "https://example.com/api/v2/cdr/consents/351/pdfs/withdrawal")
                    }
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }

}
