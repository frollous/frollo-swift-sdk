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

class BudgetsRequestTests: BaseTestCase {
    
    var keychain: Keychain!
    var service: APIService!

    override func setUp() {
        testsKeychainService = "BudgetsRequestTests"
        
        super.setUp()
        
        keychain = defaultKeychain(isNetwork: true)
        service = defaultService(keychain: keychain)
    }
    
    override func tearDown() {
        Keychain(service: keychainService).removeAll()
        
        super.tearDown()
    }

    func testCreateBudget() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: BudgetsEndpoint.budgets.path.prefixedWithSlash, toResourceWithName: "budget_valid_4", addingStatusCode: 201)
        
        let request = APIBudgetCreateRequest.testValidData()
        
        service.createBudget(request: request) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.id, 4)
                    XCTAssertEqual(response.budgetType, .category)
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }

}
