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

class GoalsTests: BaseTestCase {
    
    override func setUp() {
        testsKeychainService = "GoalsTests"
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        Keychain(service: keychainService).removeAll()
    }
    
    var goals: Goals {
        let keychain = defaultKeychain(isNetwork: true)
        
        let networkAuthenticator = defaultNetworkAuthenticator(keychain: keychain)
        let network = defaultNetwork(keychain: keychain, networkAuthenticator: networkAuthenticator)
        let service = defaultService(keychain: keychain, networkAuthenticator: networkAuthenticator)
        let authService = defaultAuthService(keychain: keychain, network: network)
        
        let authentication = OAuth2Authentication(keychain: keychain, clientID: FrolloSDKConfiguration.clientID, redirectURL: FrolloSDKConfiguration.redirectURL, serverURL: config.serverEndpoint, authService: authService, preferences: preferences, delegate: nil, tokenDelegate: network)
        authentication.loggedIn = true
        return Goals(database: database, service: service, authentication: authentication)
    }
    
    // MARK: - Goals
    
    func testFetchGoalByID() {
        let expectation1 = expectation(description: "Completion")
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            let id: Int64 = 12345
            
            managedObjectContext.performAndWait {
                let testGoal = Goal(context: managedObjectContext)
                testGoal.populateTestData()
                testGoal.goalID = id
                
                try! managedObjectContext.save()
            }
            
            
            let goal = self.goals.goal(context: self.database.viewContext, goalID: id)
            
            XCTAssertNotNil(goal)
            XCTAssertEqual(goal?.goalID, id)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchGoals() {
        let expectation1 = expectation(description: "Completion")
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testGoal1 = Goal(context: managedObjectContext)
                testGoal1.populateTestData()
                testGoal1.target = .openEnded
                
                let testGoal2 = Goal(context: managedObjectContext)
                testGoal2.populateTestData()
                testGoal2.target = .amount
                
                let testGoal3 = Goal(context: managedObjectContext)
                testGoal3.populateTestData()
                testGoal3.target = .openEnded
                
                try! managedObjectContext.save()
            }
            
            
            let predicate = NSPredicate(format: #keyPath(Goal.targetRawValue) + " == %@", argumentArray: [Goal.Target.openEnded.rawValue])
            let fetchedGoals = self.goals.goals(context: self.database.viewContext, filteredBy: predicate)
            
            XCTAssertNotNil(fetchedGoals)
            XCTAssertEqual(fetchedGoals?.count, 2)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testGoalsFetchedResultsController() {
        let expectation1 = expectation(description: "Completion")
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testGoal1 = Goal(context: managedObjectContext)
                testGoal1.populateTestData()
                testGoal1.target = .date
                
                let testGoal2 = Goal(context: managedObjectContext)
                testGoal2.populateTestData()
                testGoal2.target = .amount
                
                let testGoal3 = Goal(context: managedObjectContext)
                testGoal3.populateTestData()
                testGoal3.target = .amount
                
                try! managedObjectContext.save()
            }
            
            
            let predicate = NSPredicate(format: #keyPath(Goal.targetRawValue) + " == %@", argumentArray: [Goal.Target.amount.rawValue])
            let fetchedResultsController = self.goals.goalsFetchedResultsController(context: managedObjectContext, filteredBy: predicate)
            
            do {
                try fetchedResultsController?.performFetch()
                
                XCTAssertNotNil(fetchedResultsController?.fetchedObjects)
                XCTAssertEqual(fetchedResultsController?.fetchedObjects?.count, 2)
                
                
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }

    func testRefreshGoalByID() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: GoalsEndpoint.goal(goalID: 12345).path.prefixedWithSlash, toResourceWithName: "goal_id_3211")
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            
            self.goals.refreshGoal(goalID: 12345) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = self.database.viewContext
                        
                        let fetchRequest: NSFetchRequest<Goal> = Goal.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "goalID == %ld", argumentArray: [3211])
                        
                        do {
                            let fetchedGoals = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedGoals.first?.goalID, 3211)
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testRefreshGoals() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: GoalsEndpoint.goals.path.prefixedWithSlash, toResourceWithName: "goals_valid")
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            
            self.goals.refreshGoals() { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = self.database.viewContext
                        
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
    }
    
    func testRefreshGoalsFiltered() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: GoalsEndpoint.goals.path.prefixedWithSlash, toResourceWithName: "goals_filtered_cancelled_ontrack")
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let context = self.database.newBackgroundContext()
            
            context.performAndWait {
                let goal = Goal(context: context)
                goal.populateTestData()
                goal.goalID = 3211
                goal.status = .active
                goal.trackingStatus = .behind
                
                try? context.save()
            }
            
            self.goals.refreshGoals(status: .cancelled, trackingStatus: .onTrack) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = self.database.viewContext
                        
                        // Check goal still exists that doesn't match filter
                        let fetchRequest: NSFetchRequest<Goal> = Goal.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "goalID == %ld", argumentArray: [3211])
                        
                        do {
                            let fetchedGoals = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedGoals.first?.goalID, 3211)
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                    
                        // Check new goals added
                        let fetchFilteredRequest: NSFetchRequest<Goal> = Goal.fetchRequest()
                        fetchFilteredRequest.predicate = NSPredicate(format: #keyPath(Goal.statusRawValue) + " == %@ &&" + #keyPath(Goal.trackingStatusRawValue) + " == %@", argumentArray: [Goal.Status.cancelled.rawValue, Goal.TrackingStatus.onTrack.rawValue])
                        
                        do {
                            let fetchedFilteredGoals = try context.fetch(fetchFilteredRequest)
                            
                            XCTAssertEqual(fetchedFilteredGoals.count, 2)
                        } catch {
                            XCTFail(error.localizedDescription)
                    }
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testCreateGoal() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: GoalsEndpoint.goals.path.prefixedWithSlash, toResourceWithName: "goal_id_3211", addingStatusCode: 201)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            
            self.goals.createGoal(name: "My test goal",
                             description: "The bestest test goal",
                             imageURL: URL(string: "https://example.com/image.png"),
                             type: "Holiday",
                             subType: "Winter",
                             target: .amount,
                             trackingType: .credit,
                             frequency: .weekly,
                             startDate: nil,
                             endDate: Date().addingTimeInterval(100000),
                             periodAmount: 700,
                             startAmount: 0,
                             targetAmount: 20000,
                             accountID: 123) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = self.database.viewContext
                        
                        let fetchRequest: NSFetchRequest<Goal> = Goal.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "goalID == %ld", argumentArray: [3211])
                        
                        do {
                            let fetchedGoals = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedGoals.first?.goalID, 3211)
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testCreateGoalInvalidDataFails() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: GoalsEndpoint.goals.path.prefixedWithSlash, toResourceWithName: "goal_id_3211", addingStatusCode: 201)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            
            self.goals.createGoal(name: "My test goal",
                             description: "The bestest test goal",
                             imageURL: URL(string: "https://example.com/image.png"),
                             type: "Holiday",
                             subType: "Winter",
                             target: .amount,
                             trackingType: .credit,
                             frequency: .weekly,
                             startDate: nil,
                             endDate: Date().addingTimeInterval(100000),
                             periodAmount: 700,
                             startAmount: 0,
                             targetAmount: nil,
                             accountID: 123) { (result) in
                                switch result {
                                    case .failure(let error):
                                        XCTAssertNotNil(error)
                                        
                                        if let dataError = error as? DataError {
                                            XCTAssertEqual(dataError.type, .api)
                                            XCTAssertEqual(dataError.subType, .invalidData)
                                        } else {
                                            XCTFail("Wrong error returned")
                                        }
                                    case .success:
                                        XCTFail("Invalid data should fail")
                                }
                                
                                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testDeleteGoal() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: GoalsEndpoint.goal(goalID: 12345).path.prefixedWithSlash, addingData: Data(), addingStatusCode: 204)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let goal = Goal(context: managedObjectContext)
                goal.populateTestData()
                goal.goalID = 12345
                
                try? managedObjectContext.save()
            }
            
            self.goals.deleteGoal(goalID: 12345) { (result) in
                switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    XCTAssertNil(self.goals.goal(context: self.database.viewContext, goalID: 12345))
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testUpdateGoal() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: GoalsEndpoint.goal(goalID: 3211).path.prefixedWithSlash, toResourceWithName: "goal_id_3211")
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let context = self.database.newBackgroundContext()
            
            context.performAndWait {
                let goal = Goal(context: context)
                goal.populateTestData()
                goal.goalID = 3211
                
                try? context.save()
            }
            
            
            self.goals.updateGoal(goalID: 3211) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = self.database.viewContext
                        
                        let fetchRequest: NSFetchRequest<Goal> = Goal.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "goalID == %ld", argumentArray: [3211])
                        
                        do {
                            let fetchedGoals = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedGoals.first?.goalID, 3211)
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

