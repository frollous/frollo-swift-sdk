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

class GoalsRequestTests: BaseTestCase {
    
    var keychain: Keychain!
    var service: APIService!

    override func setUp() {
        testsKeychainService = "GoalsRequestTests"
        
        super.setUp()
        
        keychain = defaultKeychain(isNetwork: true)
        service = defaultService(keychain: keychain)
    }
    
    override func tearDown() {
        Keychain(service: keychainService).removeAll()
        OHHTTPStubs.removeAllStubs()
        
        super.tearDown()
    }

    func testCreateAmountTargetGoal() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: GoalsEndpoint.goals.path.prefixedWithSlash, toResourceWithName: "goal_id_3211", addingStatusCode: 201)
        
        let request = APIGoalCreateRequest.testAmountTargetData()
        
        service.createGoal(request: request) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.id, 3211)
                    XCTAssertEqual(response.target, .amount)
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testCreateDateTargetGoal() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: GoalsEndpoint.goals.path.prefixedWithSlash, toResourceWithName: "goal_id_3212", addingStatusCode: 201)
        
        let request = APIGoalCreateRequest.testDateTargetData()
        
        service.createGoal(request: request) { (result) in
            switch result {
            case .failure(let error):
                XCTFail(error.localizedDescription)
            case .success(let response):
                XCTAssertEqual(response.id, 3212)
                XCTAssertEqual(response.target, .date)
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testCreateOpenEndedTargetGoal() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: GoalsEndpoint.goals.path.prefixedWithSlash, toResourceWithName: "goal_id_3213", addingStatusCode: 201)
        
        let request = APIGoalCreateRequest.testOpenEndedTargetData()
        
        service.createGoal(request: request) { (result) in
            switch result {
            case .failure(let error):
                XCTFail(error.localizedDescription)
            case .success(let response):
                XCTAssertEqual(response.id, 3213)
                XCTAssertEqual(response.target, .openEnded)
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }

}
