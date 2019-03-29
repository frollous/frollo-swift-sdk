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

class ChallengesTests: XCTestCase {
    
    let keychainService = "ChallengesTests"

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        Keychain(service: keychainService).removeAll()
    }

    func testFetchChallengeByID() {
        let expectation1 = expectation(description: "Completion")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            let id: Int64 = 12345
            
            managedObjectContext.performAndWait {
                let testChallenge = Challenge(context: managedObjectContext)
                testChallenge.populateTestData()
                testChallenge.challengeID = id
                
                try! managedObjectContext.save()
            }
            
            let challenges = Challenges(database: database, service: service)
            
            let challenge = challenges.challenge(context: database.viewContext, challengeID: id)
            
            XCTAssertNotNil(challenge)
            XCTAssertEqual(challenge?.challengeID, id)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchChallenges() {
        let expectation1 = expectation(description: "Completion")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testChallenge1 = Challenge(context: managedObjectContext)
                testChallenge1.populateTestData()
                testChallenge1.challengeType = .transactionCategory
                
                let testChallenge2 = Challenge(context: managedObjectContext)
                testChallenge2.populateTestData()
                testChallenge2.challengeType = .merchant
                
                let testChallenge3 = Challenge(context: managedObjectContext)
                testChallenge3.populateTestData()
                testChallenge3.challengeType = .transactionCategory
                
                try! managedObjectContext.save()
            }
            
            let challenges = Challenges(database: database, service: service)
            
            let predicate = NSPredicate(format: #keyPath(Challenge.challengeTypeRawValue) + " == %@", argumentArray: [Challenge.ChallengeType.transactionCategory.rawValue])
            let fetchedChallenges = challenges.challenges(context: database.viewContext, filteredBy: predicate)
            
            XCTAssertNotNil(fetchedChallenges)
            XCTAssertEqual(fetchedChallenges?.count, 2)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testChallengesFetchedResultsController() {
        let expectation1 = expectation(description: "Completion")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testChallenge1 = Challenge(context: managedObjectContext)
                testChallenge1.populateTestData()
                testChallenge1.challengeType = .transactionCategory
                
                let testChallenge2 = Challenge(context: managedObjectContext)
                testChallenge2.populateTestData()
                testChallenge2.challengeType = .transactionCategory
                
                let testChallenge3 = Challenge(context: managedObjectContext)
                testChallenge3.populateTestData()
                testChallenge3.challengeType = .merchant
                
                try! managedObjectContext.save()
            }
            
            let challenges = Challenges(database: database, service: service)
            
            let predicate = NSPredicate(format: #keyPath(Challenge.challengeTypeRawValue) + " == %@", argumentArray: [Challenge.ChallengeType.merchant.rawValue])
            let fetchedResultsController = challenges.challengesFetchedResultsController(context: managedObjectContext, filteredBy: predicate)
            
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
    
    func testRefreshChallenges() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + ChallengesEndpoint.challenges.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "challenges_valid", ofType: "json")!, headers: [HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let challenges = Challenges(database: database, service: service)
            
            challenges.refreshChallenges() { (result) in
                switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    let context = database.viewContext
                    
                    let fetchRequest: NSFetchRequest<Challenge> = Challenge.fetchRequest()
                    
                    do {
                        let fetchedChallenges = try context.fetch(fetchRequest)
                        
                        XCTAssertEqual(fetchedChallenges.count, 9)
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
    
    func testRefreshChallengeByID() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + ChallengesEndpoint.challenge(challengeID: 15).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "challenge_id_15", ofType: "json")!, headers: [HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let challenges = Challenges(database: database, service: service)
            
            challenges.refreshChallenge(challengeID: 15) { (result) in
                switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    let context = database.viewContext
                    
                    let fetchRequest: NSFetchRequest<Challenge> = Challenge.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "challengeID == %ld", argumentArray: [15])
                    
                    do {
                        let fetchedChallenges = try context.fetch(fetchRequest)
                        
                        XCTAssertEqual(fetchedChallenges.first?.challengeID, 15)
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
    
    // MARK: - User Challenge Tests
    
    func testFetchUserChallengeByID() {
        let expectation1 = expectation(description: "Completion")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            let id: Int64 = 12345
            
            managedObjectContext.performAndWait {
                let testUserChallenge = UserChallenge(context: managedObjectContext)
                testUserChallenge.populateTestData()
                testUserChallenge.userChallengeID = id
                
                try! managedObjectContext.save()
            }
            
            let challenges = Challenges(database: database, service: service)
            
            let userChallenge = challenges.userChallenge(context: database.viewContext, userChallengeID: id)
            
            XCTAssertNotNil(userChallenge)
            XCTAssertEqual(userChallenge?.userChallengeID, id)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchUserChallenges() {
        let expectation1 = expectation(description: "Completion")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testUserChallenge1 = UserChallenge(context: managedObjectContext)
                testUserChallenge1.populateTestData()
                testUserChallenge1.status = .active
                
                let testUserChallenge2 = UserChallenge(context: managedObjectContext)
                testUserChallenge2.populateTestData()
                testUserChallenge2.status = .failed
                
                let testUserChallenge3 = UserChallenge(context: managedObjectContext)
                testUserChallenge3.populateTestData()
                testUserChallenge3.status = .active
                
                try! managedObjectContext.save()
            }
            
            let challenges = Challenges(database: database, service: service)
            
            let predicate = NSPredicate(format: #keyPath(UserChallenge.statusRawValue) + " == %@", argumentArray: [UserChallenge.Status.active.rawValue])
            let fetchedUserChallenges = challenges.userChallenges(context: database.viewContext, filteredBy: predicate)
            
            XCTAssertNotNil(fetchedUserChallenges)
            XCTAssertEqual(fetchedUserChallenges?.count, 2)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testUserChallengesFetchedResultsController() {
        let expectation1 = expectation(description: "Completion")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testUserChallenge1 = UserChallenge(context: managedObjectContext)
                testUserChallenge1.populateTestData()
                testUserChallenge1.status = .completed
                
                let testUserChallenge2 = UserChallenge(context: managedObjectContext)
                testUserChallenge2.populateTestData()
                testUserChallenge2.status = .completed
                
                let testUserChallenge3 = UserChallenge(context: managedObjectContext)
                testUserChallenge3.populateTestData()
                testUserChallenge3.status = .failed
                
                try! managedObjectContext.save()
            }
            
            let challenges = Challenges(database: database, service: service)
            
            let predicate = NSPredicate(format: #keyPath(UserChallenge.statusRawValue) + " == %@", argumentArray: [UserChallenge.Status.failed.rawValue])
            let fetchedResultsController = challenges.userChallengesFetchedResultsController(context: managedObjectContext, filteredBy: predicate)
            
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
    
    func testRefreshUserChallenges() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + ChallengesEndpoint.userChallenges.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_challenges_valid", ofType: "json")!, headers: [HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let challenges = Challenges(database: database, service: service)
            
            challenges.refreshUserChallenges() { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = database.viewContext
                        
                        let fetchRequest: NSFetchRequest<UserChallenge> = UserChallenge.fetchRequest()
                        
                        do {
                            let fetchedUserChallenges = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedUserChallenges.count, 3)
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
    
    func testRefreshUserChallengeByID() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + ChallengesEndpoint.userChallenge(userChallengeID: 521).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_challenge_id_521", ofType: "json")!, headers: [HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let challenges = Challenges(database: database, service: service)
            
            challenges.refreshUserChallenge(userChallengeID: 521) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = database.viewContext
                        
                        let fetchRequest: NSFetchRequest<UserChallenge> = UserChallenge.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "userChallengeID == %ld", argumentArray: [521])
                        
                        do {
                            let fetchedUserChallenges = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedUserChallenges.first?.userChallengeID, 521)
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
    
    func testUserChallengesLinkingToChallenges() {
        let expectation1 = expectation(description: "Database Setup")
        let expectation2 = expectation(description: "Network Challenge Request")
        let expectation3 = expectation(description: "Network User Challenge Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + ChallengesEndpoint.challenges.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "challenges_valid", ofType: "json")!, headers: [HTTPHeader.contentType.rawValue: "application/json"])
        }
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + ChallengesEndpoint.userChallenges.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_challenges_valid", ofType: "json")!, headers: [HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        let challenges = Challenges(database: database, service: service)
        
        challenges.refreshChallenges() { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 3.0)
        
        challenges.refreshUserChallenges() { (result) in
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
        
        let fetchRequest: NSFetchRequest<UserChallenge> = UserChallenge.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userChallengeID == %ld", argumentArray: [524])
        
        do {
            let fetchedUserChallenges = try context.fetch(fetchRequest)
            
            XCTAssertEqual(fetchedUserChallenges.count, 1)
            
            if let userChallenge = fetchedUserChallenges.first {
                XCTAssertNotNil(userChallenge.challenge)
                
                XCTAssertEqual(userChallenge.challengeID, userChallenge.challenge?.challengeID)
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        OHHTTPStubs.removeAllStubs()
    }

}
