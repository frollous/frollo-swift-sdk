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

class GoalsTests: XCTestCase {
    
    let keychainService = "GoalsTests"
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        Keychain(service: keychainService).removeAll()
    }
    
    // MARK: - Goals
    
    func testRefreshGoals() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + GoalsEndpoint.goals.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "goals_valid", ofType: "json")!, headers: [HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(serverEndpoint: config.serverEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let goals = Goals(database: database, service: service)
            
            goals.refreshGoals() { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = database.viewContext
                        
                        let fetchRequest: NSFetchRequest<Goal> = Goal.fetchRequest()
                        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Goal.goalID), ascending: true)]
                        
                        do {
                            let fetchedGoals = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedGoals.count, 3)
                            
                            if let goal = fetchedGoals.first {
                                XCTAssertEqual(goal.accountID, 45)
                                XCTAssertEqual(goal.currency, "AUD")
                                XCTAssertEqual(goal.currentAmount, 1352.19)
                                XCTAssertEqual(goal.details, "New York")
                                XCTAssertEqual(goal.endDateString, "2019-07-15")
                                XCTAssertEqual(goal.estimatedEndDateString, "2019-07-15")
                                XCTAssertEqual(goal.estimatedTargetAmount, 5555.55)
                                XCTAssertEqual(goal.frequency, .weekly)
                                XCTAssertEqual(goal.goalID, 3211)
                                XCTAssertEqual(goal.imageURL, URL(string: "https://example.com/image.png"))
                                XCTAssertEqual(goal.name, "Holiday Fund")
                                XCTAssertEqual(goal.periodAmount, 400)
                                XCTAssertEqual(goal.periodCount, 10)
                                XCTAssertEqual(goal.startAmount, 0)
                                XCTAssertEqual(goal.startDateString, "2019-07-15")
                                XCTAssertEqual(goal.status, .active)
                                XCTAssertEqual(goal.subType, "USA")
                                XCTAssertEqual(goal.target, .amount)
                                XCTAssertEqual(goal.targetAmount, 5000)
                                XCTAssertEqual(goal.trackingStatus, .ahead)
                                XCTAssertEqual(goal.trackingType, .debit)
                                XCTAssertEqual(goal.type, "Saving for a holiday")
                            } else {
                                XCTFail("Goal missing")
                            }
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }
    
}

