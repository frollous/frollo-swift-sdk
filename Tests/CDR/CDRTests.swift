//
// Copyright © 2018 Frollo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import CoreData
@testable import FrolloSDK
import XCTest

import OHHTTPStubs

class CDRTests: BaseTestCase {
    
    override func setUp() {
        testsKeychainService = "CDRTests"
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        OHHTTPStubs.removeAllStubs()
        Keychain(service: keychainService).removeAll()
    }
    
    private func aggregation(loggedIn: Bool) -> Aggregation {
        return self.aggregation(keychain: self.defaultKeychain(isNetwork: true), loggedIn: loggedIn)
    }
    
    // MARK: - Provider Tests
    
    func testSubmitConsent_ShouldSubmitProperly() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: CDREndpoint.consents.path.prefixedWithSlash, toResourceWithName: "consent_submit")
        
        database.setup { error in
            XCTAssertNil(error)
            
            let aggregation = self.aggregation(loggedIn: true)
            let consent = CDRConsentForm(providerID: 1, sharingDuration: 100, permissions: [], deleteRedundantData: true)
            aggregation.submitCDRConsent(consent: consent) { (result) in
                switch result {
                case .success:
                    expectation1.fulfill()
                    break
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                }
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
    }
}


