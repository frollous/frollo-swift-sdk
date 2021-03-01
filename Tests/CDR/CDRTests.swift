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
#if canImport(OHHTTPStubsSwift)
import OHHTTPStubsSwift
#endif

class CDRTests: BaseTestCase {
    
    override func setUp() {
        testsKeychainService = "CDRTests"
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        HTTPStubs.removeAllStubs()
        Keychain(service: keychainService).removeAll()
    }
    
    private func aggregation(loggedIn: Bool) -> Aggregation {
        return self.aggregation(keychain: self.defaultKeychain(isNetwork: true), loggedIn: loggedIn)
    }
    
    // MARK: - Provider Tests
    
    func testSubmitConsent_ShouldSubmitProperly() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: CDREndpoint.consents.path.prefixedWithSlash, method: .post, toResourceWithName: "post_consent")
        connect(endpoint: CDREndpoint.consents.path.prefixedWithSlash, method: .get, toResourceWithName: "consents_valid")
        
        database.setup { error in
            XCTAssertNil(error)
            
            let aggregation = self.aggregation(loggedIn: true)
            let consent = CDRConsentForm.Post(providerID: 1, sharingDuration: 100, permissions: [], existingConsentID: 1)
            aggregation.submitCDRConsent(consent: consent) { (result) in
                switch result {
                    case .success:
                        break
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testWithdrawConsent_ShouldWithdrawProperly() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: CDREndpoint.consents(id: 1).path.prefixedWithSlash, method: .put, toResourceWithName: "put_consent")
        connect(endpoint: CDREndpoint.consents(id: 1).path.prefixedWithSlash, method: .get, toResourceWithName: "get_consent")
        
        database.setup { error in
            XCTAssertNil(error)
            
            let aggregation = self.aggregation(loggedIn: true)
            aggregation.withdrawCDRConsent(id: 1) { (result) in
                switch result {
                    case .success:
                        break
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testUpdateConsent_ShouldWUpdateSharingPeriod() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: CDREndpoint.consents(id: 1).path.prefixedWithSlash, method: .put, toResourceWithName: "consent_update_period_response")
        
        database.setup { error in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let consent1 = Consent(context: managedObjectContext)
                consent1.populateTestData()
                consent1.consentID = 39
                consent1.sharingDuration = 15778476
                try! managedObjectContext.save()
            }
            
            let aggregation = self.aggregation(loggedIn: true)
            aggregation.updateCDRConsentSharingPeriod(id: 1, sharingDuration: 15778476) { (result) in
                switch result {
                case .success:
                    
                    let context = self.context
                                           
                     let fetchRequest: NSFetchRequest<Consent> = Consent.fetchRequest()
                                           
                    do {
                        let fetchedConsent = try context.fetch(fetchRequest).first
                        XCTAssertEqual(fetchedConsent?.consentID, 39)
                        XCTAssertEqual(fetchedConsent?.sharingDuration, 31556952)
                    } catch {
                        XCTFail(error.localizedDescription)
                    }
                    
                    expectation1.fulfill()
                    break
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                }
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchProductsByAccountID() {

        let expectation1 = expectation(description: "Network Request 1")
               
        connect(endpoint: CDREndpoint.products.path.prefixedWithSlash, toResourceWithName: "products_account_id_542")
               
        let aggregation = self.aggregation(loggedIn: true)
        
        aggregation.fetchProducts(accountID: 542) { result in
            switch result {
                case .failure(let error):
                    XCTFail("Fetching products failed with error \(error)")
                case .success(let products):
                    XCTAssertEqual(products.count, 131)
                    XCTAssertEqual(products.first?.id, 1)
                    XCTAssertEqual(products.first?.providerID, 22580)
                    XCTAssertEqual(products.first?.providerCategory, CDRProduct.CDRProductCategory.residentialMortgages)
                    XCTAssertEqual(products.first?.productName, "Fixed Rate Investment Property Loan Interest Only")
            }
            
            expectation1.fulfill()
        }
               
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchConfiguration() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: CDREndpoint.configuration.path.prefixedWithSlash, method: .get, toResourceWithName: "get_configuration")
        
        database.setup { error in
            XCTAssertNil(error)
            
            let aggregation = self.aggregation(loggedIn: true)
            aggregation.refreshCDRConfiguration() { (result) in
                switch result {
                    case .success:
                        let configuration = aggregation.cdrConfiguration(context: self.database.viewContext)
                        XCTAssertEqual(configuration?.adrID, "ADBK0001")
                        XCTAssertEqual(configuration?.adrName, "ACME")
                        XCTAssertEqual(configuration?.supportEmail, "suppert@acme.com")
                        XCTAssertEqual(configuration?.sharingDurations.count, 1)
                        break
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
}


