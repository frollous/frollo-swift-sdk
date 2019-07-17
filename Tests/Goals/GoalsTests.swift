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
    
    func testFetchGoalByID() {
        let expectation1 = expectation(description: "Completion")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(serverEndpoint: config.serverEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        let authService = OAuthService(authorizationEndpoint: FrolloSDKConfiguration.authorizationEndpoint, tokenEndpoint: FrolloSDKConfiguration.tokenEndpoint, redirectURL: FrolloSDKConfiguration.redirectURL, revokeURL: FrolloSDKConfiguration.revokeTokenEndpoint, network: network)
        let authentication = OAuth2Authentication(keychain: keychain, clientID: FrolloSDKConfiguration.clientID, redirectURL: FrolloSDKConfiguration.redirectURL, serverURL: config.serverEndpoint, authService: authService, preferences: preferences, delegate: nil, tokenDelegate: network)
        authentication.loggedIn = true
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            let id: Int64 = 12345
            
            managedObjectContext.performAndWait {
                let testGoal = Goal(context: managedObjectContext)
                testGoal.populateTestData()
                testGoal.goalID = id
                
                try! managedObjectContext.save()
            }
            
            let goals = Goals(database: database, service: service, authentication: authentication)
            
            let goal = goals.goal(context: database.viewContext, goalID: id)
            
            XCTAssertNotNil(goal)
            XCTAssertEqual(goal?.goalID, id)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchGoals() {
        let expectation1 = expectation(description: "Completion")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(serverEndpoint: config.serverEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        let authService = OAuthService(authorizationEndpoint: FrolloSDKConfiguration.authorizationEndpoint, tokenEndpoint: FrolloSDKConfiguration.tokenEndpoint, redirectURL: FrolloSDKConfiguration.redirectURL, revokeURL: FrolloSDKConfiguration.revokeTokenEndpoint, network: network)
        let authentication = OAuth2Authentication(keychain: keychain, clientID: FrolloSDKConfiguration.clientID, redirectURL: FrolloSDKConfiguration.redirectURL, serverURL: config.serverEndpoint, authService: authService, preferences: preferences, delegate: nil, tokenDelegate: network)
        authentication.loggedIn = true
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
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
            
            let goals = Goals(database: database, service: service, authentication: authentication)
            
            let predicate = NSPredicate(format: #keyPath(Goal.targetRawValue) + " == %@", argumentArray: [Goal.Target.openEnded.rawValue])
            let fetchedGoals = goals.goals(context: database.viewContext, filteredBy: predicate)
            
            XCTAssertNotNil(fetchedGoals)
            XCTAssertEqual(fetchedGoals?.count, 2)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testGoalsFetchedResultsController() {
        let expectation1 = expectation(description: "Completion")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(serverEndpoint: config.serverEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        let authService = OAuthService(authorizationEndpoint: FrolloSDKConfiguration.authorizationEndpoint, tokenEndpoint: FrolloSDKConfiguration.tokenEndpoint, redirectURL: FrolloSDKConfiguration.redirectURL, revokeURL: FrolloSDKConfiguration.revokeTokenEndpoint, network: network)
        let authentication = OAuth2Authentication(keychain: keychain, clientID: FrolloSDKConfiguration.clientID, redirectURL: FrolloSDKConfiguration.redirectURL, serverURL: config.serverEndpoint, authService: authService, preferences: preferences, delegate: nil, tokenDelegate: network)
        authentication.loggedIn = true
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
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
            
            let goals = Goals(database: database, service: service, authentication: authentication)
            
            let predicate = NSPredicate(format: #keyPath(Goal.targetRawValue) + " == %@", argumentArray: [Goal.Target.amount.rawValue])
            let fetchedResultsController = goals.goalsFetchedResultsController(context: managedObjectContext, filteredBy: predicate)
            
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
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + GoalsEndpoint.goal(goalID: 12345).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "goal_id_3211", ofType: "json")!, headers: [HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(serverEndpoint: config.serverEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        let authService = OAuthService(authorizationEndpoint: FrolloSDKConfiguration.authorizationEndpoint, tokenEndpoint: FrolloSDKConfiguration.tokenEndpoint, redirectURL: FrolloSDKConfiguration.redirectURL, revokeURL: FrolloSDKConfiguration.revokeTokenEndpoint, network: network)
        let authentication = OAuth2Authentication(keychain: keychain, clientID: FrolloSDKConfiguration.clientID, redirectURL: FrolloSDKConfiguration.redirectURL, serverURL: config.serverEndpoint, authService: authService, preferences: preferences, delegate: nil, tokenDelegate: network)
        authentication.loggedIn = true
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let goals = Goals(database: database, service: service, authentication: authentication)
            
            goals.refreshGoal(goalID: 12345) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = database.viewContext
                        
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
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + GoalsEndpoint.goals.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "goals_valid", ofType: "json")!, headers: [HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(serverEndpoint: config.serverEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        let authService = OAuthService(authorizationEndpoint: FrolloSDKConfiguration.authorizationEndpoint, tokenEndpoint: FrolloSDKConfiguration.tokenEndpoint, redirectURL: FrolloSDKConfiguration.redirectURL, revokeURL: FrolloSDKConfiguration.revokeTokenEndpoint, network: network)
        let authentication = OAuth2Authentication(keychain: keychain, clientID: FrolloSDKConfiguration.clientID, redirectURL: FrolloSDKConfiguration.redirectURL, serverURL: config.serverEndpoint, authService: authService, preferences: preferences, delegate: nil, tokenDelegate: network)
        authentication.loggedIn = true
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let goals = Goals(database: database, service: service, authentication: authentication)
            
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
    }
    
    func testCreateGoal() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + GoalsEndpoint.goals.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "goal_id_3211", ofType: "json")!, status: 201, headers: [HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(serverEndpoint: config.serverEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        let authService = OAuthService(authorizationEndpoint: FrolloSDKConfiguration.authorizationEndpoint, tokenEndpoint: FrolloSDKConfiguration.tokenEndpoint, redirectURL: FrolloSDKConfiguration.redirectURL, revokeURL: FrolloSDKConfiguration.revokeTokenEndpoint, network: network)
        let authentication = OAuth2Authentication(keychain: keychain, clientID: FrolloSDKConfiguration.clientID, redirectURL: FrolloSDKConfiguration.redirectURL, serverURL: config.serverEndpoint, authService: authService, preferences: preferences, delegate: nil, tokenDelegate: network)
        authentication.loggedIn = true
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let goals = Goals(database: database, service: service, authentication: authentication)
            
            goals.createGoal(name: "My test goal",
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
                        let context = database.viewContext
                        
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
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + GoalsEndpoint.goals.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "goal_id_3211", ofType: "json")!, status: 201, headers: [HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(serverEndpoint: config.serverEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        let authService = OAuthService(authorizationEndpoint: FrolloSDKConfiguration.authorizationEndpoint, tokenEndpoint: FrolloSDKConfiguration.tokenEndpoint, redirectURL: FrolloSDKConfiguration.redirectURL, revokeURL: FrolloSDKConfiguration.revokeTokenEndpoint, network: network)
        let authentication = OAuth2Authentication(keychain: keychain, clientID: FrolloSDKConfiguration.clientID, redirectURL: FrolloSDKConfiguration.redirectURL, serverURL: config.serverEndpoint, authService: authService, preferences: preferences, delegate: nil, tokenDelegate: network)
        authentication.loggedIn = true
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let goals = Goals(database: database, service: service, authentication: authentication)
            
            goals.createGoal(name: "My test goal",
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
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + GoalsEndpoint.goal(goalID: 12345).path)) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 204, headers: nil)
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(serverEndpoint: config.serverEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        let preferences = Preferences(path: tempFolderPath())
        let authService = OAuthService(authorizationEndpoint: FrolloSDKConfiguration.authorizationEndpoint, tokenEndpoint: FrolloSDKConfiguration.tokenEndpoint, redirectURL: FrolloSDKConfiguration.redirectURL, revokeURL: FrolloSDKConfiguration.revokeTokenEndpoint, network: network)
        
        let authentication = OAuth2Authentication(keychain: keychain, clientID: FrolloSDKConfiguration.clientID, redirectURL: FrolloSDKConfiguration.redirectURL, serverURL: config.serverEndpoint, authService: authService, preferences: preferences, delegate: nil, tokenDelegate: network)
        authentication.loggedIn = true
        let goals = Goals(database: database, service: service, authentication: authentication)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let goal = Goal(context: managedObjectContext)
                goal.populateTestData()
                goal.goalID = 12345
                
                try? managedObjectContext.save()
            }
            
            goals.deleteGoal(goalID: 12345) { (result) in
                switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    XCTAssertNil(goals.goal(context: database.viewContext, goalID: 12345))
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testUpdateGoal() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + GoalsEndpoint.goal(goalID: 3211).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "goal_id_3211", ofType: "json")!, headers: [HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(serverEndpoint: config.serverEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        let authService = OAuthService(authorizationEndpoint: FrolloSDKConfiguration.authorizationEndpoint, tokenEndpoint: FrolloSDKConfiguration.tokenEndpoint, redirectURL: FrolloSDKConfiguration.redirectURL, revokeURL: FrolloSDKConfiguration.revokeTokenEndpoint, network: network)
        let authentication = OAuth2Authentication(keychain: keychain, clientID: FrolloSDKConfiguration.clientID, redirectURL: FrolloSDKConfiguration.redirectURL, serverURL: config.serverEndpoint, authService: authService, preferences: preferences, delegate: nil, tokenDelegate: network)
        authentication.loggedIn = true
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let context = database.newBackgroundContext()
            
            context.performAndWait {
                let goal = Goal(context: context)
                goal.populateTestData()
                goal.goalID = 3211
                
                try? context.save()
            }
            
            let goals = Goals(database: database, service: service, authentication: authentication)
            
            goals.updateGoal(goalID: 3211) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = database.viewContext
                        
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
        OHHTTPStubs.removeAllStubs()
    }
    
}

