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
import XCTest
@testable import FrolloSDK

import OHHTTPStubs

class AggregationTests: XCTestCase {
    
    let keychainService = "AggregationTests"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        OHHTTPStubs.removeAllStubs()
        Keychain(service: keychainService).removeAll()
    }
    
    func testFetchProviderByID() {
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
                let testProvider = Provider(context: managedObjectContext)
                testProvider.populateTestData(withID: id)
                
                try! managedObjectContext.save()
            }
            
            let aggregation = Aggregation(database: database, service: service)
            
            let provider = aggregation.provider(context: database.viewContext, providerID: id)
            
            XCTAssertNotNil(provider)
            XCTAssertEqual(provider?.providerID, id)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchProviders() {
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
                let testProvider1 = Provider(context: managedObjectContext)
                testProvider1.populateTestData()
                testProvider1.containerLoan = true
                
                let testProvider2 = Provider(context: managedObjectContext)
                testProvider2.populateTestData()
                testProvider2.containerLoan = false
                
                let testProvider3 = Provider(context: managedObjectContext)
                testProvider3.populateTestData()
                testProvider3.containerLoan = true
                
                try! managedObjectContext.save()
            }
            
            let aggregation = Aggregation(database: database, service: service)
            
            let predicate = NSPredicate(format: "containerLoan == true", argumentArray: nil)
            let providers = aggregation.providers(context: database.viewContext, filteredBy: predicate)
            
            XCTAssertNotNil(providers)
            XCTAssertEqual(providers?.count, 2)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testProvidersFetchedResultsController() {
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
                let testProvider1 = Provider(context: managedObjectContext)
                testProvider1.populateTestData()
                testProvider1.containerLoan = true
                
                let testProvider2 = Provider(context: managedObjectContext)
                testProvider2.populateTestData()
                testProvider2.containerLoan = false
                
                let testProvider3 = Provider(context: managedObjectContext)
                testProvider3.populateTestData()
                testProvider3.containerLoan = true
                
                try! managedObjectContext.save()
            }
            
            let aggregation = Aggregation(database: database, service: service)
            
            let predicate = NSPredicate(format: "containerLoan == true", argumentArray: nil)
            let fetchedResultsController = aggregation.providersFetchedResultsController(context: database.viewContext, filteredBy: predicate)
            
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
    
    func testRefreshProvidersIsCached() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.providers.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "providers_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, service: service)
            
            aggregation.refreshProviders { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = database.viewContext
                        
                        let fetchRequest: NSFetchRequest<Provider> = Provider.fetchRequest()
                        
                        do {
                            let fetchedProviders = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedProviders.count, 311)
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
    
    func testRefreshProviderByIDIsCached() {
        let expectation1 = expectation(description: "Database")
        let expectation2 = expectation(description: "Network Request 1")
        let expectation3 = expectation(description: "Fetch Request 1")
        let expectation4 = expectation(description: "Network Request 2")
        let expectation5 = expectation(description: "Fetch Request 2")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let providerStub = stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.providers.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "providers_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
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
            
        let aggregation = Aggregation(database: database, service: service)
        
        aggregation.refreshProviders() { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 3.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let context = database.viewContext
            
            let totalFetchRequest: NSFetchRequest<Provider> = Provider.fetchRequest()
            
            do {
                let fetchedTotalProviders = try context.fetch(totalFetchRequest)
                
                XCTAssertEqual(fetchedTotalProviders.count, 311)
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            let individualFetchRequest: NSFetchRequest<Provider> = Provider.fetchRequest()
            individualFetchRequest.predicate = NSPredicate(format: "providerID == %ld", argumentArray: [15441])
            
            do {
                let fetchedIndividualProviders = try context.fetch(individualFetchRequest)
                
                XCTAssertEqual(fetchedIndividualProviders.count, 1)
                
                if let provider = fetchedIndividualProviders.first {
                    XCTAssertEqual(provider.providerID, 15441)
                } else {
                    XCTFail("Provider not found")
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            expectation3.fulfill()
        }
        
        wait(for: [expectation3], timeout: 3.0)
        
        OHHTTPStubs.removeStub(providerStub)
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.providers.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "providers_updated", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        aggregation.refreshProviders() { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation4.fulfill()
        }
        
        wait(for: [expectation4], timeout: 3.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let context = database.viewContext
            
            let totalFetchRequest: NSFetchRequest<Provider> = Provider.fetchRequest()
            
            do {
                let fetchedTotalProviders = try context.fetch(totalFetchRequest)
                
                XCTAssertEqual(fetchedTotalProviders.count, 313)
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            let individualFetchRequest: NSFetchRequest<Provider> = Provider.fetchRequest()
            individualFetchRequest.predicate = NSPredicate(format: "providerID == %ld", argumentArray: [15441])
            
            do {
                let fetchedIndividualProviders = try context.fetch(individualFetchRequest)
                
                XCTAssertEqual(fetchedIndividualProviders.count, 0)
                XCTAssertNil(fetchedIndividualProviders.first)
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            expectation5.fulfill()
        }
        
        wait(for: [expectation5], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testRefreshProvidersUpdate() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.providers.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "providers_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, service: service)
            
            aggregation.refreshProviders { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = database.viewContext
                        
                        let fetchRequest: NSFetchRequest<Provider> = Provider.fetchRequest()
                        
                        do {
                            let fetchedProviders = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedProviders.count, 311)
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
    
    // MARK: - Provider Account Tests
    
    func testFetchProviderAccountByID() {
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
                let testProviderAccount = ProviderAccount(context: managedObjectContext)
                testProviderAccount.populateTestData(withID: id)
                
                try! managedObjectContext.save()
            }
            
            let aggregation = Aggregation(database: database, service: service)
            
            let providerAccount = aggregation.providerAccount(context: database.viewContext, providerAccountID: id)
            
            XCTAssertNotNil(providerAccount)
            XCTAssertEqual(providerAccount?.providerAccountID, id)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchProviderAccounts() {
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
                let testProviderAccount1 = ProviderAccount(context: managedObjectContext)
                testProviderAccount1.populateTestData()
                testProviderAccount1.providerID = 69
                
                let testProviderAccount2 = ProviderAccount(context: managedObjectContext)
                testProviderAccount2.populateTestData()
                testProviderAccount2.providerID = 12
                
                let testProviderAccount3 = ProviderAccount(context: managedObjectContext)
                testProviderAccount3.populateTestData()
                testProviderAccount3.providerID = 69
                
                try! managedObjectContext.save()
            }
            
            let aggregation = Aggregation(database: database, service: service)
            
            let predicate = NSPredicate(format: "providerID == 69", argumentArray: nil)
            let providerAccounts = aggregation.providerAccounts(context: database.viewContext, filteredBy: predicate, limit: 1)
            
            XCTAssertNotNil(providerAccounts)
            XCTAssertEqual(providerAccounts?.count, 1)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testProviderAccountsFetchedResultsController() {
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
                let testProviderAccount1 = ProviderAccount(context: managedObjectContext)
                testProviderAccount1.populateTestData()
                testProviderAccount1.providerID = 69
                
                let testProviderAccount2 = ProviderAccount(context: managedObjectContext)
                testProviderAccount2.populateTestData()
                testProviderAccount2.providerID = 12
                
                let testProviderAccount3 = ProviderAccount(context: managedObjectContext)
                testProviderAccount3.populateTestData()
                testProviderAccount3.providerID = 69
                
                try! managedObjectContext.save()
            }
            
            let aggregation = Aggregation(database: database, service: service)
            
            let predicate = NSPredicate(format: "providerID == 69", argumentArray: nil)
            let fetchedResultsController = aggregation.providerAccountsFetchedResultsController(context: database.viewContext, filteredBy: predicate)
            
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
    
    func testRefreshProviderAccountsIsCached() {
        let expectation1 = expectation(description: "Database Setup")
        let expectation2 = expectation(description: "Network Request 1")
        let expectation3 = expectation(description: "Network Request 2")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.providerAccounts.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "provider_accounts_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
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
            
        let aggregation = Aggregation(database: database, service: service)
        
        aggregation.refreshProviderAccounts { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    let context = database.viewContext
                    
                    let fetchRequest: NSFetchRequest<ProviderAccount> = ProviderAccount.fetchRequest()
                    
                    do {
                        let fetchedProviderAccounts = try context.fetch(fetchRequest)
                        
                        XCTAssertEqual(fetchedProviderAccounts.count, 4)
                    } catch {
                        XCTFail(error.localizedDescription)
                    }
            }

            expectation2.fulfill()
        }
                
        wait(for: [expectation2], timeout: 5.0)

        aggregation.refreshProviderAccounts { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    let context = database.viewContext
                    
                    let fetchRequest: NSFetchRequest<ProviderAccount> = ProviderAccount.fetchRequest()
                    
                    do {
                        let fetchedProviderAccounts = try context.fetch(fetchRequest)
                        
                        XCTAssertEqual(fetchedProviderAccounts.count, 4, "Provider Accounts Duplicated")
                    } catch {
                        XCTFail(error.localizedDescription)
                    }
            }
            
            expectation3.fulfill()
        }
        
        wait(for: [expectation3], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testRefreshProviderAccountByIDIsCached() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.providerAccount(providerAccountID: 123).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "provider_account_id_123", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, service: service)
            
            aggregation.refreshProviderAccount(providerAccountID: 123) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = database.viewContext
                        
                        let fetchRequest: NSFetchRequest<ProviderAccount> = ProviderAccount.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "providerAccountID == %ld", argumentArray: [123])
                        
                        do {
                            let fetchedProviderAccounts = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedProviderAccounts.first?.providerAccountID, 123)
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
    
    func testProviderAccountsLinkToProviders() {
        let expectation1 = expectation(description: "Network Provider Request")
        let expectation2 = expectation(description: "Network Provider Account Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.provider(providerID: 12345).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "provider_id_12345", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.providerAccounts.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "provider_accounts_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, service: service)
            
            aggregation.refreshProviderAccounts() { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        break
                }
            
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            let context = database.viewContext
            
            let fetchRequest: NSFetchRequest<ProviderAccount> = ProviderAccount.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "providerAccountID == %ld", argumentArray: [867])
            
            do {
                let fetchedProviderAccounts = try context.fetch(fetchRequest)
                
                XCTAssertEqual(fetchedProviderAccounts.count, 1)
                
                if let providerAccount = fetchedProviderAccounts.first {
                    XCTAssertNotNil(providerAccount.provider)
                    
                    XCTAssertEqual(providerAccount.providerID, providerAccount.provider?.providerID)
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 5.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testCreateProviderAccount() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let providerID: Int64 = 12345
        
        let loginForm = ProviderLoginForm.loginFormFilledData()
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.providerAccounts.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "provider_account_id_123", ofType: "json")!, status: 201, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, service: service)
            
            aggregation.createProviderAccount(providerID: providerID, loginForm: loginForm, completion: { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = database.viewContext
                        
                        let fetchRequest: NSFetchRequest<ProviderAccount> = ProviderAccount.fetchRequest()
                        
                        do {
                            let fetchedAccounts = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedAccounts.count, 1)
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                }
                
                expectation1.fulfill()
            })
        }
        
        wait(for: [expectation1], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testDeleteProviderAccount() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.providerAccount(providerAccountID: 12345).path)) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 204, headers: nil)
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        let aggregation = Aggregation(database: database, service: service)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let providerAccount = ProviderAccount(context: managedObjectContext)
                providerAccount.populateTestData()
                providerAccount.providerAccountID = 12345
                
                try? managedObjectContext.save()
            }
            
            aggregation.deleteProviderAccount(providerAccountID: 12345) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        XCTAssertNil(aggregation.providerAccount(context: database.viewContext, providerAccountID: 12345))
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testUpdateProviderAccount() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let providerAccountID: Int64 = 123
        
        let loginForm = ProviderLoginForm.loginFormFilledData()
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.providerAccount(providerAccountID: providerAccountID).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "provider_account_id_123", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, service: service)
            
            aggregation.updateProviderAccount(providerAccountID: providerAccountID, loginForm: loginForm) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = database.viewContext
                        
                        let fetchRequest: NSFetchRequest<ProviderAccount> = ProviderAccount.fetchRequest()
                        
                        do {
                            let fetchedAccounts = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedAccounts.count, 1)
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
    
    func testProviderAccountsFetchMissingProviders() {
        let expectation1 = expectation(description: "Database Setup")
        let expectation2 = expectation(description: "Network Request 1")
        let expectation3 = expectation(description: "Fetch Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.providerAccounts.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "provider_accounts_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.provider(providerID: 12345).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "provider_id_12345", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
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
        
        let aggregation = Aggregation(database: database, service: service)
        
        aggregation.refreshProviderAccounts { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 5.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            let context = database.viewContext
            
            let fetchRequest: NSFetchRequest<ProviderAccount> = ProviderAccount.fetchRequest()
            
            do {
                let fetchedProviderAccounts = try context.fetch(fetchRequest)
                
                XCTAssertEqual(fetchedProviderAccounts.count, 4)
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            let providerFetchRequest: NSFetchRequest<Provider> = Provider.fetchRequest()
            
            do {
                let fetchedProviders = try context.fetch(providerFetchRequest)
                
                XCTAssertEqual(fetchedProviders.count, 1)
                
                if let provider = fetchedProviders.first {
                    XCTAssertEqual(provider.providerID, 12345)
                    XCTAssertEqual(provider.providerAccounts?.count, 1)
                } else {
                    XCTFail("No provider")
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            expectation3.fulfill()
        }
        
        wait(for: [expectation3], timeout: 6.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    // MARK: - Account Tests
    
    func testFetchAccountByID() {
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
                let testAccount = Account(context: managedObjectContext)
                testAccount.populateTestData(withID: id)
                
                try! managedObjectContext.save()
            }
            
            let aggregation = Aggregation(database: database, service: service)
            
            let account = aggregation.account(context: database.viewContext, accountID: id)
            
            XCTAssertNotNil(account)
            XCTAssertEqual(account?.accountID, id)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchAccounts() {
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
                let testAccount1 = Account(context: managedObjectContext)
                testAccount1.populateTestData()
                testAccount1.providerAccountID = 69
                
                let testAccount2 = Account(context: managedObjectContext)
                testAccount2.populateTestData()
                testAccount2.providerAccountID = 12
                
                let testAccount3 = Account(context: managedObjectContext)
                testAccount3.populateTestData()
                testAccount3.providerAccountID = 69
                
                try! managedObjectContext.save()
            }
            
            let aggregation = Aggregation(database: database, service: service)
            
            let predicate = NSPredicate(format: "providerAccountID == 69", argumentArray: nil)
            let accounts = aggregation.accounts(context: database.viewContext, filteredBy: predicate)
            
            XCTAssertNotNil(accounts)
            XCTAssertEqual(accounts?.count, 2)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testAccountsFetchedResultsController() {
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
                let testAccount1 = Account(context: managedObjectContext)
                testAccount1.populateTestData()
                testAccount1.providerAccountID = 69
                
                let testAccount2 = Account(context: managedObjectContext)
                testAccount2.populateTestData()
                testAccount2.providerAccountID = 12
                
                let testAccount3 = Account(context: managedObjectContext)
                testAccount3.populateTestData()
                testAccount3.providerAccountID = 69
                
                try! managedObjectContext.save()
            }
            
            let aggregation = Aggregation(database: database, service: service)
            
            let predicate = NSPredicate(format: "providerAccountID == 69", argumentArray: nil)
            let fetchedResultsController = aggregation.accountsFetchedResultsController(context: database.viewContext, filteredBy: predicate)
            
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
    
    func testRefreshAccountsIsCached() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.accounts.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "accounts_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, service: service)
            
            aggregation.refreshAccounts { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = database.viewContext
                        
                        let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
                        
                        do {
                            let fetchedAccounts = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedAccounts.count, 8)
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
    
    func testRefreshAccountByIDIsCached() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.account(accountID: 542).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "account_id_542", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, service: service)
            
            aggregation.refreshAccount(accountID: 542) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = database.viewContext
                        
                        let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "accountID == %ld", argumentArray: [542])
                        
                        do {
                            let fetchedProviderAccounts = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedProviderAccounts.first?.accountID, 542)
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
    
    func testAccountsLinkToProviderAccounts() {
        let expectation1 = expectation(description: "Database Request")
        let expectation2 = expectation(description: "Network Request 1")
        let expectation3 = expectation(description: "Network Request 2")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.providerAccounts.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "provider_accounts_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.accounts.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "accounts_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
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
            
        let aggregation = Aggregation(database: database, service: service)
        
        aggregation.refreshProviderAccounts { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 3.0)
        
        aggregation.refreshAccounts() { (result) in
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
            
        let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "accountID == %ld", argumentArray: [542])
        
        do {
            let fetchedAccounts = try context.fetch(fetchRequest)
            
            XCTAssertEqual(fetchedAccounts.count, 1)
            
            if let account = fetchedAccounts.first {
                XCTAssertNotNil(account.providerAccount)
                
                XCTAssertEqual(account.providerAccountID, account.providerAccount?.providerAccountID)
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
        OHHTTPStubs.removeAllStubs()
    }
    
    func testUpdatingAccount() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.account(accountID: 542).path) && isMethodPUT()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "account_id_542", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let account = Account(context: managedObjectContext)
                account.populateTestData()
                account.accountID = 542
                
                try? managedObjectContext.save()
                
                let aggregation = Aggregation(database: database, service: service)
                
                aggregation.updateAccount(accountID: 542) { (result) in
                    switch result {
                        case .failure(let error):
                            XCTFail(error.localizedDescription)
                        case .success:
                            let context = database.viewContext
                            
                            let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
                            fetchRequest.predicate = NSPredicate(format: "accountID == %ld", argumentArray: [542])
                            
                            do {
                                let fetchedProviderAccounts = try context.fetch(fetchRequest)
                                
                                XCTAssertEqual(fetchedProviderAccounts.first?.accountID, 542)
                            } catch {
                                XCTFail(error.localizedDescription)
                            }
                    }
                    
                    expectation1.fulfill()
                }
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    // MARK: - Transaction Tests
    
    func testFetchTransactionByID() {
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
                let testTransaction = Transaction(context: managedObjectContext)
                testTransaction.populateTestData(withID: id)
                
                try! managedObjectContext.save()
            }
            
            let aggregation = Aggregation(database: database, service: service)
            
            let transaction = aggregation.transaction(context: database.viewContext, transactionID: id)
            
            XCTAssertNotNil(transaction)
            XCTAssertEqual(transaction?.transactionID, id)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchTransactions() {
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
                let testTransaction1 = Transaction(context: managedObjectContext)
                testTransaction1.populateTestData()
                testTransaction1.baseType = .debit
                
                let testTransaction2 = Transaction(context: managedObjectContext)
                testTransaction2.populateTestData()
                testTransaction2.baseType = .credit
                
                let testTransaction3 = Transaction(context: managedObjectContext)
                testTransaction3.populateTestData()
                testTransaction3.baseType = .debit
                
                try! managedObjectContext.save()
            }
            
            let aggregation = Aggregation(database: database, service: service)
            
            let predicate = NSPredicate(format: "baseTypeRawValue == %@", argumentArray: [Transaction.BaseType.credit.rawValue])
            let transactions = aggregation.transactions(context: database.viewContext, filteredBy: predicate)
            
            XCTAssertNotNil(transactions)
            XCTAssertEqual(transactions?.count, 1)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testTransactionsFetchedResultsController() {
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
                let testTransaction1 = Transaction(context: managedObjectContext)
                testTransaction1.populateTestData()
                testTransaction1.baseType = .debit
                
                let testTransaction2 = Transaction(context: managedObjectContext)
                testTransaction2.populateTestData()
                testTransaction2.baseType = .credit
                
                let testTransaction3 = Transaction(context: managedObjectContext)
                testTransaction3.populateTestData()
                testTransaction3.baseType = .debit
                
                try! managedObjectContext.save()
            }
            
            let aggregation = Aggregation(database: database, service: service)
            
            let predicate = NSPredicate(format: "baseTypeRawValue == %@", argumentArray: [Transaction.BaseType.credit.rawValue])
            let fetchedResultsController = aggregation.transactionsFetchedResultsController(context: database.viewContext, filteredBy: predicate)
            
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
    
    func testRefreshTransactionsIsCached() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.transactions.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transactions_2018-08-01_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, service: service)
            
            let fromDate = Transaction.transactionDateFormatter.date(from: "2018-08-01")!
            let toDate = Transaction.transactionDateFormatter.date(from: "2018-08-31")!
            
            aggregation.refreshTransactions(from: fromDate, to: toDate) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = database.viewContext
                        
                        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
                        
                        do {
                            let fetchedTransactions = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedTransactions.count, 111)
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
    
    func testRefreshTransactionsSkipsInvalid() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.transactions.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transactions_2018-08-01_invalid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, service: service)
            
            let fromDate = Transaction.transactionDateFormatter.date(from: "2018-08-01")!
            let toDate = Transaction.transactionDateFormatter.date(from: "2018-08-31")!
            
            aggregation.refreshTransactions(from: fromDate, to: toDate) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = database.viewContext
                        
                        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
                        
                        do {
                            let fetchedTransactions = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedTransactions.count, 108)
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
    
    func testRefreshPaginatedTransactions() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.transactions.path)) { (request) -> OHHTTPStubsResponse in
            if let requestURL = request.url, let queryItems = URLComponents(url: requestURL, resolvingAgainstBaseURL: true)?.queryItems {
                var skip: Int = 0
                
                for queryItem in queryItems {
                    if queryItem.name == "skip", let value = queryItem.value, let skipCount = Int(value) {
                        skip = skipCount
                    }
                }
                
                if skip == 200 {
                    return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transactions_2018-12-04_count_200_skip_200", ofType: "json")!, headers: [HTTPHeader.contentType.rawValue: "application/json"])
                }
            }
            
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transactions_2018-12-04_count_200_skip_0", ofType: "json")!, headers: [HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, service: service)
            
            let fromDate = Transaction.transactionDateFormatter.date(from: "2018-08-01")!
            let toDate = Transaction.transactionDateFormatter.date(from: "2018-08-31")!
            
            aggregation.refreshTransactions(from: fromDate, to: toDate) { (result) in
                switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    let context = database.viewContext
                    
                    let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
                    
                    do {
                        let fetchedTransactions = try context.fetch(fetchRequest)
                        
                        XCTAssertEqual(fetchedTransactions.count, 311)
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
    
    func testRefreshTransactionByIDIsCached() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.transaction(transactionID: 194630).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_id_194630", ofType: "json")!, headers: [HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, service: service)
            
            aggregation.refreshTransaction(transactionID: 194630) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = database.viewContext
                        
                        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "transactionID == %ld", argumentArray: [194630])
                        
                        do {
                            let fetchedTransactions = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedTransactions.first?.transactionID, 194630)
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
    
    func testRefreshTransactionByIDsIsCached() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let transactions: [Int64] = [1, 2, 3, 4, 5]
        
        stub(condition: isHost(config.serverEndpoint.host!) && pathStartsWith("/" + AggregationEndpoint.transactions.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transactions_2018-08-01_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, service: service)
            
            aggregation.refreshTransactions(transactionIDs: transactions) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = database.viewContext
                        
                        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
                        
                        do {
                            let fetchedTransactions = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedTransactions.count, 111)
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
    
    func testTransactionsLinkToAccounts() {
        let expectation1 = expectation(description: "Database Setup")
        let expectation2 = expectation(description: "Network Account Request")
        let expectation3 = expectation(description: "Network Transaction Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.accounts.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "accounts_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.transactions.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transactions_2018-08-01_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
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
            
        let aggregation = Aggregation(database: database, service: service)
        
        aggregation.refreshAccounts { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }

            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 3.0)
                
        let fromDate = Transaction.transactionDateFormatter.date(from: "2018-08-01")!
        let toDate = Transaction.transactionDateFormatter.date(from: "2018-08-31")!
        
        aggregation.refreshTransactions(from: fromDate, to: toDate) { (result) in
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
        
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "transactionID == %ld", argumentArray: [194630])
        
        do {
            let fetchedTransactions = try context.fetch(fetchRequest)
            
            XCTAssertEqual(fetchedTransactions.count, 1)
            
            if let transaction = fetchedTransactions.first {
                XCTAssertNotNil(transaction)
                
                XCTAssertEqual(transaction.accountID, transaction.account?.accountID)
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        OHHTTPStubs.removeAllStubs()
    }
    
    func testTransactionsLinkToMerchants() {
        let expectation1 = expectation(description: "Network Merchant Request")
        let expectation2 = expectation(description: "Network Transaction Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.merchants.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "merchants_by_id", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.transactions.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transactions_2018-08-01_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, service: service)
                
            let fromDate = Transaction.transactionDateFormatter.date(from: "2018-08-01")!
            let toDate = Transaction.transactionDateFormatter.date(from: "2018-08-31")!
            
            aggregation.refreshTransactions(from: fromDate, to: toDate) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        break
                }
            
                expectation1.fulfill()
            }
        }

        wait(for: [expectation1], timeout: 3.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            let context = database.viewContext
            
            let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "transactionID == %ld", argumentArray: [194630])
            
            do {
                let fetchedTransactions = try context.fetch(fetchRequest)
                
                XCTAssertEqual(fetchedTransactions.count, 1)
                
                if let transaction = fetchedTransactions.first {
                    XCTAssertNotNil(transaction)
                    
                    XCTAssertEqual(transaction.merchantID, transaction.merchant?.merchantID)
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 8.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testTransactionsLinkToTransactionCategories() {
        let expectation1 = expectation(description: "Database Setup")
        let expectation2 = expectation(description: "Network Transaction Category Request")
        let expectation3 = expectation(description: "Network Transaction Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.transactionCategories.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_categories_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.transactions.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transactions_2018-08-01_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
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
            
        let aggregation = Aggregation(database: database, service: service)
        
        aggregation.refreshTransactionCategories { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 3.0)
            
        let fromDate = Transaction.transactionDateFormatter.date(from: "2018-08-01")!
        let toDate = Transaction.transactionDateFormatter.date(from: "2018-08-31")!
        
        aggregation.refreshTransactions(from: fromDate, to: toDate) { (result) in
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
        
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "transactionID == %ld", argumentArray: [194630])
        
        do {
            let fetchedTransactions = try context.fetch(fetchRequest)
            
            XCTAssertEqual(fetchedTransactions.count, 1)
            
            if let transaction = fetchedTransactions.first {
                XCTAssertNotNil(transaction)
                
                XCTAssertEqual(transaction.transactionCategoryID, transaction.transactionCategory?.transactionCategoryID)
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        OHHTTPStubs.removeAllStubs()
    }
    
    func testExcludeTransaction() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.transaction(transactionID: 194630).path) && isMethodPUT()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_id_194630_excluded", ofType: "json")!, headers: [HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let transaction = Transaction(context: managedObjectContext)
                transaction.populateTestData()
                transaction.transactionID = 194630
                transaction.included = true
                
                try? managedObjectContext.save()
                
                let aggregation = Aggregation(database: database, service: service)
                
                aggregation.excludeTransaction(transactionID: 194630, excluded: true, excludeAll: true) { (result) in
                    switch result {
                        case .failure(let error):
                            XCTFail(error.localizedDescription)
                        case .success:
                            let context = database.viewContext
                            
                            let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
                            fetchRequest.predicate = NSPredicate(format: "transactionID == %ld", argumentArray: [194630])
                            
                            do {
                                let fetchedTransactions = try context.fetch(fetchRequest)
                                
                                XCTAssertEqual(fetchedTransactions.first?.transactionID, 194630)
                                XCTAssertEqual(fetchedTransactions.first?.included, false)
                            } catch {
                                XCTFail(error.localizedDescription)
                            }
                    }
                    
                    expectation1.fulfill()
                }
            }
        }
        
        wait(for: [expectation1], timeout: 5.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testRecategoriseTransaction() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.transaction(transactionID: 194630).path) && isMethodPUT()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_id_194630", ofType: "json")!, headers: [HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let transaction = Transaction(context: managedObjectContext)
                transaction.populateTestData()
                transaction.transactionID = 194630
                transaction.transactionCategoryID = 123
                
                let oldTransactionCategory = TransactionCategory(context: managedObjectContext)
                oldTransactionCategory.populateTestData()
                oldTransactionCategory.transactionCategoryID = 123
                
                transaction.transactionCategory = oldTransactionCategory
                
                let newTransactionCategory = TransactionCategory(context: managedObjectContext)
                newTransactionCategory.populateTestData()
                newTransactionCategory.transactionCategoryID = 77
                
                try? managedObjectContext.save()
                
                let aggregation = Aggregation(database: database, service: service)
                
                aggregation.recategoriseTransaction(transactionID: 194630, transactionCategoryID: 77, recategoriseAll: true) { (result) in
                    switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = database.viewContext
                        
                        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "transactionID == %ld", argumentArray: [194630])
                        
                        do {
                            let fetchedTransactions = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedTransactions.first?.transactionID, 194630)
                            XCTAssertEqual(fetchedTransactions.first?.transactionCategoryID, 77)
                            XCTAssertEqual(fetchedTransactions.first?.transactionCategory?.transactionCategoryID, 77)
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                    }
                    
                    expectation1.fulfill()
                }
            }
        }
        
        wait(for: [expectation1], timeout: 5.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testUpdatingTransaction() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.transaction(transactionID: 194630).path) && isMethodPUT()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_id_194630", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let transaction = Transaction(context: managedObjectContext)
                transaction.populateTestData()
                transaction.transactionID = 194630
                
                try? managedObjectContext.save()
                
                let aggregation = Aggregation(database: database, service: service)
                
                aggregation.updateTransaction(transactionID: 194630) { (result) in
                    switch result {
                        case .failure(let error):
                            XCTFail(error.localizedDescription)
                        case .success:
                            let context = database.viewContext
                            
                            let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
                            fetchRequest.predicate = NSPredicate(format: "transactionID == %ld", argumentArray: [194630])
                            
                            do {
                                let fetchedTransactions = try context.fetch(fetchRequest)
                                
                                XCTAssertEqual(fetchedTransactions.first?.transactionID, 194630)
                            } catch {
                                XCTFail(error.localizedDescription)
                            }
                    }
                    
                    expectation1.fulfill()
                }
            }
        }
        
        wait(for: [expectation1], timeout: 5.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testTransactionsFetchMissingMerchants() {
        let expectation1 = expectation(description: "Database Setup")
        let expectation2 = expectation(description: "Network Request 1")
        let expectation3 = expectation(description: "Fetch Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.transactions.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transactions_2018-08-01_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.merchants.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "merchants_by_id", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
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
        
        let aggregation = Aggregation(database: database, service: service)
        
        let fromDate = Transaction.transactionDateFormatter.date(from: "2018-08-01")!
        let toDate = Transaction.transactionDateFormatter.date(from: "2018-08-31")!
        
        aggregation.refreshTransactions(from: fromDate, to: toDate) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 5.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            let context = database.viewContext
            
            let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
            
            do {
                let fetchedTransactions = try context.fetch(fetchRequest)
                
                XCTAssertEqual(fetchedTransactions.count, 111)
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            let merchantFetchRequest: NSFetchRequest<Merchant> = Merchant.fetchRequest()
            merchantFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Merchant.merchantID), ascending: true)]
            
            do {
                let fetchedMerchants = try context.fetch(merchantFetchRequest)
                
                XCTAssertEqual(fetchedMerchants.count, 2)
                
                if let merchant = fetchedMerchants.first {
                    XCTAssertEqual(merchant.merchantID, 238)
                } else {
                    XCTFail("No merchant")
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            expectation3.fulfill()
        }
        
        wait(for: [expectation3], timeout: 8.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testTransactionSearch() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.transactionSearch.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transactions_search", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, service: service)
            
            let fromDate = Transaction.transactionDateFormatter.date(from: "2019-03-01")!
            let toDate = Transaction.transactionDateFormatter.date(from: "2019-04-30")!
            
            aggregation.transactionSearch(searchTerm: "Occidental", page: 0, from: fromDate, to: toDate, accountIDs: [544], onlyIncludedAccounts: true) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success(let transactionIDs):
                        XCTAssertEqual(transactionIDs, [194611, 194620, 194619, 194621])
                        
                        let context = database.viewContext
                        
                        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: #keyPath(Transaction.transactionID) + " IN %@", argumentArray: [transactionIDs])
                        
                        do {
                            let fetchedTransactions = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedTransactions.count, 4)
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
    
    func testTransactionSummary() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.transactionSummary.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_summary", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, service: service)
            
            let fromDate = Transaction.transactionDateFormatter.date(from: "2018-08-01")!
            let toDate = Transaction.transactionDateFormatter.date(from: "2018-08-31")!
            
            aggregation.transactionSummary(from: fromDate, to: toDate, accountIDs: [123], transactionIDs: [1, 4, 5, 99, 100], onlyIncludedAccounts: false, onlyIncludedTransactions: false) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success(let summary):
                        XCTAssertEqual(summary.count, 5)
                        XCTAssertEqual(summary.sum, 45.98)
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    // MARK: - Transaction Category Tests
    
    func testFetchTransactionCategoryByID() {
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
                let testTransactionCategory = TransactionCategory(context: managedObjectContext)
                testTransactionCategory.populateTestData(withID: id)
                
                try! managedObjectContext.save()
            }
            
            let aggregation = Aggregation(database: database, service: service)
            
            let transactionCategory = aggregation.transactionCategory(context: database.viewContext, transactionCategoryID: id)
            
            XCTAssertNotNil(transactionCategory)
            XCTAssertEqual(transactionCategory?.transactionCategoryID, id)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchTransactionCategories() {
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
                let testTransactionCategory1 = TransactionCategory(context: managedObjectContext)
                testTransactionCategory1.populateTestData()
                testTransactionCategory1.categoryType = .transfer
                
                let testTransactionCategory2 = TransactionCategory(context: managedObjectContext)
                testTransactionCategory2.populateTestData()
                testTransactionCategory2.categoryType = .expense
                
                let testTransactionCategory3 = TransactionCategory(context: managedObjectContext)
                testTransactionCategory3.populateTestData()
                testTransactionCategory3.categoryType = .expense
                
                try! managedObjectContext.save()
            }
            
            let aggregation = Aggregation(database: database, service: service)
            
            let predicate = NSPredicate(format: "categoryTypeRawValue == %@", argumentArray: [TransactionCategory.CategoryType.expense.rawValue])
            let transactionCategories = aggregation.transactionCategories(context: database.viewContext, filteredBy: predicate)
            
            XCTAssertNotNil(transactionCategories)
            XCTAssertEqual(transactionCategories?.count, 2)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testTransactionCategoriesFetchedResultsController() {
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
                let testTransactionCategory1 = TransactionCategory(context: managedObjectContext)
                testTransactionCategory1.populateTestData()
                testTransactionCategory1.categoryType = .transfer
                
                let testTransactionCategory2 = TransactionCategory(context: managedObjectContext)
                testTransactionCategory2.populateTestData()
                testTransactionCategory2.categoryType = .expense
                
                let testTransactionCategory3 = TransactionCategory(context: managedObjectContext)
                testTransactionCategory3.populateTestData()
                testTransactionCategory3.categoryType = .expense
                
                try! managedObjectContext.save()
            }
            
            let aggregation = Aggregation(database: database, service: service)
            
            let predicate = NSPredicate(format: "categoryTypeRawValue == %@", argumentArray: [TransactionCategory.CategoryType.expense.rawValue])
            let fetchedResultsController = aggregation.transactionCategoriesFetchedResultsController(context: database.viewContext, filteredBy: predicate)
            
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
    
    func testRefreshTransactionCategoriesIsCached() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.transactionCategories.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_categories_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, service: service)
            
            aggregation.refreshTransactionCategories { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = database.viewContext
                        
                        let fetchRequest: NSFetchRequest<TransactionCategory> = TransactionCategory.fetchRequest()
                        
                        do {
                            let fetchedTransactionCategories = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedTransactionCategories.count, 63)
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
    
    // MARK: - Merchant Tests
    
    func testFetchMerchantByID() {
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
                let testMerchant = Merchant(context: managedObjectContext)
                testMerchant.populateTestData(withID: id)
                
                try! managedObjectContext.save()
            }
            
            let aggregation = Aggregation(database: database, service: service)
            
            let merchant = aggregation.merchant(context: database.viewContext, merchantID: id)
            
            XCTAssertNotNil(merchant)
            XCTAssertEqual(merchant?.merchantID, id)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchMerchants() {
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
                let testMerchant1 = Merchant(context: managedObjectContext)
                testMerchant1.populateTestData()
                testMerchant1.merchantType = .retailer
                
                let testMerchant2 = Merchant(context: managedObjectContext)
                testMerchant2.populateTestData()
                testMerchant2.merchantType = .retailer
                
                let testMerchant3 = Merchant(context: managedObjectContext)
                testMerchant3.populateTestData()
                testMerchant3.merchantType = .transactional
                
                try! managedObjectContext.save()
            }
            
            let aggregation = Aggregation(database: database, service: service)
            
            let predicate = NSPredicate(format: "merchantTypeRawValue == %@", argumentArray: [Merchant.MerchantType.retailer.rawValue])
            let merchants = aggregation.merchants(context: database.viewContext, filteredBy: predicate)
            
            XCTAssertNotNil(merchants)
            XCTAssertEqual(merchants?.count, 2)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testMerchantsFetchedResultsController() {
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
                let testMerchant1 = Merchant(context: managedObjectContext)
                testMerchant1.populateTestData()
                testMerchant1.merchantType = .retailer
                
                let testMerchant2 = Merchant(context: managedObjectContext)
                testMerchant2.populateTestData()
                testMerchant2.merchantType = .retailer
                
                let testMerchant3 = Merchant(context: managedObjectContext)
                testMerchant3.populateTestData()
                testMerchant3.merchantType = .transactional
                
                try! managedObjectContext.save()
            }
            
            let aggregation = Aggregation(database: database, service: service)
            
            let predicate = NSPredicate(format: "merchantTypeRawValue == %@", argumentArray: [Merchant.MerchantType.retailer.rawValue])
            let fetchedResultsController = aggregation.merchantsFetchedResultsController(context: database.viewContext, filteredBy: predicate)
            
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
    
    func testRefreshMerchantsIsCached() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.merchants.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "merchants_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, service: service)
            
            aggregation.refreshMerchants { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = database.viewContext
                        
                        let fetchRequest: NSFetchRequest<Merchant> = Merchant.fetchRequest()
                        
                        do {
                            let fetchedMerchants = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedMerchants.count, 1200)
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
    
    func testRefreshMerchantByID() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.merchant(merchantID: 197).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "merchant_id_197", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, service: service)
            
            aggregation.refreshMerchant(merchantID: 197) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = database.viewContext
                        
                        let fetchRequest: NSFetchRequest<Merchant> = Merchant.fetchRequest()
                        
                        do {
                            let fetchedMerchants = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedMerchants.count, 1)
                            
                            if let merchant = fetchedMerchants.first {
                                XCTAssertEqual(merchant.merchantID, 197)
                            } else {
                                XCTFail("No merchant found")
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
    
    func testRefreshMerchantsByID() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.merchants.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "merchants_by_id", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, service: service)
            
            aggregation.refreshMerchants(merchantIDs: [22, 30, 31, 106, 691]) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = database.viewContext
                        
                        let fetchRequest: NSFetchRequest<Merchant> = Merchant.fetchRequest()
                        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Merchant.merchantID), ascending: true)]
                        
                        do {
                            let fetchedMerchants = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedMerchants.count, 2)
                            
                            if let merchant = fetchedMerchants.last {
                                XCTAssertEqual(merchant.merchantID, 686)
                            } else {
                                XCTFail("No merchants")
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
    
    func testTransactionsRefreshedOnNotification() {
        let expectation1 = expectation(forNotification: Aggregation.transactionsUpdatedNotification, object: nil) { (notification) -> Bool in
            return true
        }
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let ids: [Int64] = [4, 87, 9077777]
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.transactions.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transactions_2018-08-01_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            _ = Aggregation(database: database, service: service)
        
            NotificationCenter.default.post(name: Aggregation.refreshTransactionsNotification, object: self, userInfo: [Aggregation.refreshTransactionIDsKey: ids])
        }
        
        wait(for: [expectation1], timeout: 5.0)
    }
    
}
