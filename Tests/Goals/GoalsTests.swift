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
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        let challenges = Challenges(database: database, service: service)
        
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
            
            let goals = Goals(database: database, challenges: challenges, service: service)
            
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
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        let challenges = Challenges(database: database, service: service)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testGoal1 = Goal(context: managedObjectContext)
                testGoal1.populateTestData()
                testGoal1.goalType = .debt
                
                let testGoal2 = Goal(context: managedObjectContext)
                testGoal2.populateTestData()
                testGoal2.goalType = .debt
                
                let testGoal3 = Goal(context: managedObjectContext)
                testGoal3.populateTestData()
                testGoal3.goalType = .save
                
                try! managedObjectContext.save()
            }
            
            let goals = Goals(database: database, challenges: challenges, service: service)
            
            let predicate = NSPredicate(format: #keyPath(Goal.goalTypeRawValue) + " == %@", argumentArray: [Goal.GoalType.save.rawValue])
            let fetchedGoals = goals.goals(context: database.viewContext, filteredBy: predicate)
            
            XCTAssertNotNil(fetchedGoals)
            XCTAssertEqual(fetchedGoals?.count, 1)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testGoalsFetchedResultsController() {
        let expectation1 = expectation(description: "Completion")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        let challenges = Challenges(database: database, service: service)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testGoal1 = Goal(context: managedObjectContext)
                testGoal1.populateTestData()
                testGoal1.goalType = .debt
                
                let testGoal2 = Goal(context: managedObjectContext)
                testGoal2.populateTestData()
                testGoal2.goalType = .loan
                
                let testGoal3 = Goal(context: managedObjectContext)
                testGoal3.populateTestData()
                testGoal3.goalType = .debt
                
                try! managedObjectContext.save()
            }
            
            let goals = Goals(database: database, challenges: challenges, service: service)
            
            let predicate = NSPredicate(format: #keyPath(Goal.goalTypeRawValue) + " == %@", argumentArray: [Goal.GoalType.debt.rawValue])
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
    
    func testRefreshGoals() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + GoalsEndpoint.goals.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "goals_valid", ofType: "json")!, headers: [HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        let challenges = Challenges(database: database, service: service)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let goals = Goals(database: database, challenges: challenges, service: service)
            
            goals.refreshGoals() { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = database.viewContext
                        
                        let fetchRequest: NSFetchRequest<Goal> = Goal.fetchRequest()
                        
                        do {
                            let fetchedGoals = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedGoals.count, 11)
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
    
    func testRefreshGoalByID() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + GoalsEndpoint.goal(goalID: 12345).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "goal_id_14", ofType: "json")!, headers: [HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        let challenges = Challenges(database: database, service: service)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let goals = Goals(database: database, challenges: challenges, service: service)
            
            goals.refreshGoal(goalID: 12345) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = database.viewContext
                        
                        let fetchRequest: NSFetchRequest<Goal> = Goal.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "goalID == %ld", argumentArray: [14])
                        
                        do {
                            let fetchedGoals = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedGoals.first?.goalID, 14)
                            
                            XCTAssertNotNil(fetchedGoals.first?.suggestedChallenges)
                            
                            if let suggestedChallenges = fetchedGoals.first?.suggestedChallenges {
                                XCTAssertEqual(suggestedChallenges.count, 2)
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
    
    // MARK: - User Goals
    
    func testFetchUserGoalByID() {
        let expectation1 = expectation(description: "Completion")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        let challenges = Challenges(database: database, service: service)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            let id: Int64 = 12345
            
            managedObjectContext.performAndWait {
                let testUserGoal = UserGoal(context: managedObjectContext)
                testUserGoal.populateTestData()
                testUserGoal.userGoalID = id
                
                try! managedObjectContext.save()
            }
            
            let goals = Goals(database: database, challenges: challenges, service: service)
            
            let userGoal = goals.userGoal(context: database.viewContext, userGoalID: id)
            
            XCTAssertNotNil(userGoal)
            XCTAssertEqual(userGoal?.userGoalID, id)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchUserGoals() {
        let expectation1 = expectation(description: "Completion")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        let challenges = Challenges(database: database, service: service)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testUserGoal1 = UserGoal(context: managedObjectContext)
                testUserGoal1.populateTestData()
                testUserGoal1.status = .active
                
                let testUserGoal2 = UserGoal(context: managedObjectContext)
                testUserGoal2.populateTestData()
                testUserGoal2.status = .failed
                
                let testUserGoal3 = UserGoal(context: managedObjectContext)
                testUserGoal3.populateTestData()
                testUserGoal3.status = .active
                
                try! managedObjectContext.save()
            }
            
            let goals = Goals(database: database, challenges: challenges, service: service)
            
            let predicate = NSPredicate(format: #keyPath(UserGoal.statusRawValue) + " == %@", argumentArray: [UserGoal.Status.active.rawValue])
            let fetchedUserGoals = goals.userGoals(context: database.viewContext, filteredBy: predicate)
            
            XCTAssertNotNil(fetchedUserGoals)
            XCTAssertEqual(fetchedUserGoals?.count, 2)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testUserGoalsFetchedResultsController() {
        let expectation1 = expectation(description: "Completion")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        let challenges = Challenges(database: database, service: service)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testUserGoal1 = UserGoal(context: managedObjectContext)
                testUserGoal1.populateTestData()
                testUserGoal1.status = .completed
                
                let testUserGoal2 = UserGoal(context: managedObjectContext)
                testUserGoal2.populateTestData()
                testUserGoal2.status = .completed
                
                let testUserGoal3 = UserGoal(context: managedObjectContext)
                testUserGoal3.populateTestData()
                testUserGoal3.status = .failed
                
                try! managedObjectContext.save()
            }
            
            let goals = Goals(database: database, challenges: challenges, service: service)
            
            let predicate = NSPredicate(format: #keyPath(UserGoal.statusRawValue) + " == %@", argumentArray: [UserGoal.Status.failed.rawValue])
            let fetchedResultsController = goals.userGoalsFetchedResultsController(context: managedObjectContext, filteredBy: predicate)
            
            do {
                try fetchedResultsController?.performFetch()
                
                XCTAssertNotNil(fetchedResultsController?.fetchedObjects)
                XCTAssertEqual(fetchedResultsController?.fetchedObjects?.count, 1)
                
                
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testRefreshUserGoals() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + GoalsEndpoint.userGoals.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_goals_valid", ofType: "json")!, headers: [HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        let challenges = Challenges(database: database, service: service)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let goals = Goals(database: database, challenges: challenges, service: service)
            
            goals.refreshUserGoals() { (result) in
                switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    let context = database.viewContext
                    
                    let fetchRequest: NSFetchRequest<UserGoal> = UserGoal.fetchRequest()
                    
                    do {
                        let fetchedUserGoals = try context.fetch(fetchRequest)
                        
                        XCTAssertEqual(fetchedUserGoals.count, 2)
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
    
    func testRefreshUserGoalByID() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + GoalsEndpoint.userGoal(userGoalID: 137).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_goals_id_137", ofType: "json")!, headers: [HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        let challenges = Challenges(database: database, service: service)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let goals = Goals(database: database, challenges: challenges, service: service)
            
            goals.refreshUserGoal(userGoalID: 137) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = database.viewContext
                        
                        let fetchRequest: NSFetchRequest<UserGoal> = UserGoal.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "userGoalID == %ld", argumentArray: [137])
                        
                        do {
                            let fetchedUserGoals = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedUserGoals.first?.userGoalID, 137)
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
    
    func testUserGoalsLinkingToGoals() {
        let expectation1 = expectation(description: "Database Setup")
        let expectation2 = expectation(description: "Network Goal Request")
        let expectation3 = expectation(description: "Network User Goal Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + GoalsEndpoint.goals.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "goals_valid", ofType: "json")!, headers: [HTTPHeader.contentType.rawValue: "application/json"])
        }
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + GoalsEndpoint.userGoals.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_goals_valid", ofType: "json")!, headers: [HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        let challenges = Challenges(database: database, service: service)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        let goals = Goals(database: database, challenges: challenges, service: service)
        
        goals.refreshGoals() { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 3.0)
        
        goals.refreshUserGoals() { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation3.fulfill()
        }
        
        wait(for: [expectation3], timeout: 3.0)
        
        let context = database.viewContext
        
        let fetchRequest: NSFetchRequest<UserGoal> = UserGoal.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userGoalID == %ld", argumentArray: [136])
        
        do {
            let fetchedUserGoals = try context.fetch(fetchRequest)
            
            XCTAssertEqual(fetchedUserGoals.count, 1)
            
            if let userGoal = fetchedUserGoals.first {
                XCTAssertNotNil(userGoal.goal)
                
                XCTAssertEqual(userGoal.goalID, userGoal.goal?.goalID)
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        OHHTTPStubs.removeAllStubs()
    }
    
}
