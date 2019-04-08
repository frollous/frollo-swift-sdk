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

class GoalsRequestTests: XCTestCase {
    
    private let keychainService = "GoalsRequestTests"
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        Keychain(service: keychainService).removeAll()
        OHHTTPStubs.removeAllStubs()
    }
    
    // MARK: - Goals Tests

    func testFetchGoals() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + GoalsEndpoint.goals.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "goals_valid", ofType: "json")!, headers: [HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        service.fetchGoals { (result) in
            switch result {
            case .failure(let error):
                XCTFail(error.localizedDescription)
            case .success(let response):
                XCTAssertEqual(response.count, 11)
                
                if let firstGoal = response.first {
                    XCTAssertEqual(firstGoal.id, 24)
                    XCTAssertEqual(firstGoal.community.activeCount, 13)
                    XCTAssertEqual(firstGoal.community.averageMonths, 29)
                    XCTAssertEqual(firstGoal.community.averageTargetAmount, 47999)
                    XCTAssertEqual(firstGoal.community.completedCount, 3)
                    XCTAssertEqual(firstGoal.community.startedCount, 27)
                    XCTAssertEqual(firstGoal.description, "Home improvements cost money. However, if they are done well they should pay a handsome return over time!")
                    XCTAssertEqual(firstGoal.goalType, .save)
                    XCTAssertEqual(firstGoal.largeLogoURL, "https://frollo-sandbox.s3.amazonaws.com/goals/24/large/app/1491914662.png?1491914662")
                    XCTAssertEqual(firstGoal.name, "House renovation")
                    XCTAssertEqual(firstGoal.smallLogoURL, "https://frollo-sandbox.s3.amazonaws.com/goals/24/small/app/1491914661.png?1491914661")
                    XCTAssertEqual(firstGoal.source, .suggested)
                }
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchGoalByID() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + GoalsEndpoint.goal(goalID: 14).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "goal_id_14", ofType: "json")!, headers: [HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        service.fetchGoal(goalID: 14) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.id, 14)
                    XCTAssertEqual(response.community.activeCount, 154)
                    XCTAssertEqual(response.community.averageMonths, 7)
                    XCTAssertEqual(response.community.averageTargetAmount, 10669)
                    XCTAssertEqual(response.community.completedCount, 108)
                    XCTAssertEqual(response.community.startedCount, 194)
                    XCTAssertEqual(response.description, "Saving for a holiday and paying before you go removes the pain of jetlag and a credit card bill when you get home!")
                    XCTAssertEqual(response.goalType, .save)
                    XCTAssertEqual(response.largeLogoURL, "https://frollo-sandbox.s3.amazonaws.com/goals/14/large/app/1491902546.png?1491902546")
                    XCTAssertEqual(response.name, "Save for a holiday")
                    XCTAssertEqual(response.smallLogoURL, "https://frollo-sandbox.s3.amazonaws.com/goals/14/small/app/1491902415.png?1491902415")
                    XCTAssertEqual(response.source, .suggested)
                    XCTAssertNotNil(response.suggestedChallenges)
                    XCTAssertEqual(response.suggestedChallenges?.count, 2)
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    // MARK: - User Goal Tests
    
    func testFetchUserGoals() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + GoalsEndpoint.userGoals.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_goals_valid", ofType: "json")!, headers: [HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        service.fetchUserGoals { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.count, 2)
                    
                    if let firstGoal = response.first {
                        XCTAssertEqual(firstGoal.id, 136)
                        XCTAssertEqual(firstGoal.goalID, 14)
                        XCTAssertEqual(firstGoal.status, .active)
                        XCTAssertEqual(firstGoal.currency, "AUD")
                        XCTAssertEqual(firstGoal.startAmount, 0)
                        XCTAssertEqual(firstGoal.targetAmount, 10000)
                        XCTAssertEqual(firstGoal.monthlySavingAmount, 300)
                        XCTAssertEqual(firstGoal.currentSavedAmount, 0)
                        XCTAssertEqual(firstGoal.currentTargetAmount, 0)
                        XCTAssertEqual(firstGoal.interestRate, "2.90")
                        XCTAssertEqual(firstGoal.startDate, "2019-03-27")
                        XCTAssertEqual(firstGoal.baseEndDate, "2021-12-27")
                        XCTAssertEqual(firstGoal.challengeEndDate, "2020-07-27")
                        XCTAssertEqual(firstGoal.estimatedEndDate, "2021-12-27")
                    }
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchUserGoalByID() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + GoalsEndpoint.userGoal(userGoalID: 137).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_goals_id_137", ofType: "json")!, headers: [HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        service.fetchUserGoal(userGoalID: 137) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.id, 137)
                    XCTAssertEqual(response.goalID, 16)
                    XCTAssertEqual(response.status, .active)
                    XCTAssertEqual(response.currency, "AUD")
                    XCTAssertEqual(response.startAmount, 0)
                    XCTAssertEqual(response.targetAmount, 50000)
                    XCTAssertEqual(response.monthlySavingAmount, 1000)
                    XCTAssertEqual(response.currentSavedAmount, 0)
                    XCTAssertEqual(response.currentTargetAmount, 0)
                    XCTAssertEqual(response.interestRate, "3.00")
                    XCTAssertEqual(response.startDate, "2019-03-28")
                    XCTAssertEqual(response.baseEndDate, "2023-03-28")
                    XCTAssertEqual(response.challengeEndDate, "2023-03-28")
                    XCTAssertEqual(response.estimatedEndDate, "2023-03-28")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }

}
