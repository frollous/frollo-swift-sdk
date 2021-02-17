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

import CoreData
import XCTest
@testable import FrolloSDK

import OHHTTPStubs

class PayDaysTests: BaseTestCase {
    
    var payDays: PayDays!

    override func setUp() {
        testsKeychainService = "GoalsTests"
        super.setUp()
        
        let keychain = defaultKeychain(isNetwork: true)
        
        let authentication = defaultAuthentication(keychain: keychain)
        let network = defaultNetwork(keychain: keychain, authentication: authentication)
        let service = defaultService(keychain: keychain, authentication: authentication)
        let authService = defaultAuthService(keychain: keychain, network: network)
        
        let oAuth2Authentication = OAuth2Authentication(keychain: keychain, clientID: config.clientID, redirectURL: FrolloSDKConfiguration.redirectURL, serverURL: config.serverEndpoint, authService: authService, preferences: preferences, delegate: nil)
        oAuth2Authentication.loggedIn = true
        
        payDays = PayDays(database: database, service: service)
    }
    
    override func tearDown() {
        HTTPStubs.removeAllStubs()
        Keychain(service: keychainService).removeAll()
    }
    
    // MARK: - PayDay

    func testFetchPayDay() {
        let expectation1 = expectation(description: "Completion")
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testPayDay = PayDay(context: managedObjectContext)
                testPayDay.populateTestData()
                
                try! managedObjectContext.save()
            }
            
            let payDay = self.payDays.payDay(context: self.database.viewContext)
            
            XCTAssertNotNil(payDay)
            XCTAssertEqual(payDay?.lastDateString, "2019-12-31")
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testRefreshPayDay() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: PayDayEndpoint.payDay.path.prefixedWithSlash, toResourceWithName: "pay_day")
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            self.payDays.refreshPayDay() { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = self.database.viewContext
                        
                        let fetchRequest: NSFetchRequest<PayDay> = PayDay.fetchRequest()
                        
                        do {
                            let fetchedPayDays = try context.fetch(fetchRequest)
                            
                            if let payDay = fetchedPayDays.first {
                                XCTAssertTrue(PayDay.Status.allCases.contains(payDay.status))
                            } else {
                                XCTFail("PayDay not found")
                            }
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testUpdatePayDay() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: PayDayEndpoint.payDay.path.prefixedWithSlash, toResourceWithName: "pay_day")
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            self.payDays.updatePayDay(period: PayDay.Period.allCases.randomElement()!, nextDate: Date()) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = self.database.viewContext
                        
                        let fetchRequest: NSFetchRequest<PayDay> = PayDay.fetchRequest()
                        
                        do {
                            let fetchedPayDays = try context.fetch(fetchRequest)
                            
                            if let payDay = fetchedPayDays.first {
                                XCTAssertTrue(PayDay.Status.allCases.contains(payDay.status))
                            } else {
                                XCTFail("PayDay not found")
                            }
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }

}
