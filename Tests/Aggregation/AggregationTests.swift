//
//  AggregationTests.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 1/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
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
        
        let url = URL(string: "https://api.example.com")!
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
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
            
            let aggregation = Aggregation(database: database, network: network)
            
            let provider = aggregation.provider(context: database.viewContext, providerID: id)
            
            XCTAssertNotNil(provider)
            XCTAssertEqual(provider?.providerID, id)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchProviders() {
        let expectation1 = expectation(description: "Completion")
        
        let url = URL(string: "https://api.example.com")!
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
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
            
            let aggregation = Aggregation(database: database, network: network)
            
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
        
        let url = URL(string: "https://api.example.com")!
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
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
            
            let aggregation = Aggregation(database: database, network: network)
            
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
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.providers.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "providers_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, network: network)
            
            aggregation.refreshProviders { (error) in
                XCTAssertNil(error)
                
                let context = database.viewContext
                
                let fetchRequest: NSFetchRequest<Provider> = Provider.fetchRequest()
                
                do {
                    let fetchedProviders = try context.fetch(fetchRequest)
                    
                    XCTAssertEqual(fetchedProviders.count, 311)
                } catch {
                    XCTFail(error.localizedDescription)
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testRefreshProviderByIDIsCached() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.provider(providerID: 12345).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "provider_id_12345", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, network: network)
            
            aggregation.refreshProvider(providerID: 12345) { (error) in
                XCTAssertNil(error)
                
                let context = database.viewContext
                
                let fetchRequest: NSFetchRequest<Provider> = Provider.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "providerID == %ld", argumentArray: [12345])
                
                do {
                    let fetchedProviders = try context.fetch(fetchRequest)
                    
                    XCTAssertEqual(fetchedProviders.first?.providerID, 12345)
                } catch {
                    XCTFail(error.localizedDescription)
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testRefreshProvidersUpdate() {
        // TODO: Implement
    }
    
    func testFetchProviderAccountByID() {
        let expectation1 = expectation(description: "Completion")
        
        let url = URL(string: "https://api.example.com")!
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
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
            
            let aggregation = Aggregation(database: database, network: network)
            
            let providerAccount = aggregation.providerAccount(context: database.viewContext, providerAccountID: id)
            
            XCTAssertNotNil(providerAccount)
            XCTAssertEqual(providerAccount?.providerAccountID, id)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchProviderAccounts() {
        let expectation1 = expectation(description: "Completion")
        
        let url = URL(string: "https://api.example.com")!
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
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
            
            let aggregation = Aggregation(database: database, network: network)
            
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
        
        let url = URL(string: "https://api.example.com")!
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
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
            
            let aggregation = Aggregation(database: database, network: network)
            
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
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.providerAccounts.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "provider_accounts_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, network: network)
            
            aggregation.refreshProviderAccounts { (error) in
                XCTAssertNil(error)
                
                let context = database.viewContext
                
                let fetchRequest: NSFetchRequest<ProviderAccount> = ProviderAccount.fetchRequest()
                
                do {
                    let fetchedProviderAccounts = try context.fetch(fetchRequest)
                    
                    XCTAssertEqual(fetchedProviderAccounts.count, 4)
                } catch {
                    XCTFail(error.localizedDescription)
                }
                
                aggregation.refreshProviderAccounts { (error) in
                    XCTAssertNil(error)
                    
                    let context = database.viewContext
                    
                    let fetchRequest: NSFetchRequest<ProviderAccount> = ProviderAccount.fetchRequest()
                    
                    do {
                        let fetchedProviderAccounts = try context.fetch(fetchRequest)
                        
                        XCTAssertEqual(fetchedProviderAccounts.count, 4, "Provider Accounts Duplicated")
                    } catch {
                        XCTFail(error.localizedDescription)
                    }
                    
                    expectation1.fulfill()
                }
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testRefreshProviderAccountByIDIsCached() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.providerAccount(providerAccountID: 123).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "provider_account_id_123", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, network: network)
            
            aggregation.refreshProviderAccount(providerAccountID: 123) { (error) in
                XCTAssertNil(error)
                
                let context = database.viewContext
                
                let fetchRequest: NSFetchRequest<ProviderAccount> = ProviderAccount.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "providerAccountID == %ld", argumentArray: [123])
                
                do {
                    let fetchedProviderAccounts = try context.fetch(fetchRequest)
                    
                    XCTAssertEqual(fetchedProviderAccounts.first?.providerAccountID, 123)
                } catch {
                    XCTFail(error.localizedDescription)
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
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.providers.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "providers_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.providerAccounts.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "provider_accounts_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, network: network)
            
            aggregation.refreshProviders { (error) in
                XCTAssertNil(error)
                
                aggregation.refreshProviderAccounts(completion: { (error) in
                    XCTAssertNil(error)
                    
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
                })
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1, expectation2], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testCreateProviderAccount() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let providerID: Int64 = 12345
        
        let loginForm = ProviderLoginForm.loginFormFilledData()
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.providerAccounts.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "provider_account_id_123", ofType: "json")!, status: 201, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, network: network)
            
            aggregation.createProviderAccount(providerID: providerID, loginForm: loginForm, completion: { (error) in
                XCTAssertNil(error)
                
                let context = database.viewContext
                
                let fetchRequest: NSFetchRequest<ProviderAccount> = ProviderAccount.fetchRequest()
                
                do {
                    let fetchedAccounts = try context.fetch(fetchRequest)
                    
                    XCTAssertEqual(fetchedAccounts.count, 1)
                } catch {
                    XCTFail(error.localizedDescription)
                }
                
                expectation1.fulfill()
            })
        }
        
        wait(for: [expectation1], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testUpdateProviderAccount() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let providerAccountID: Int64 = 123
        
        let loginForm = ProviderLoginForm.loginFormFilledData()
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.providerAccount(providerAccountID: providerAccountID).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "provider_account_id_123", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, network: network)
            
            aggregation.updateProviderAccount(providerAccountID: providerAccountID, loginForm: loginForm) { (error) in
                XCTAssertNil(error)
                
                let context = database.viewContext
                
                let fetchRequest: NSFetchRequest<ProviderAccount> = ProviderAccount.fetchRequest()
                
                do {
                    let fetchedAccounts = try context.fetch(fetchRequest)
                    
                    XCTAssertEqual(fetchedAccounts.count, 1)
                } catch {
                    XCTFail(error.localizedDescription)
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    // MARK: - Account Tests
    
    func testFetchAccountByID() {
        let expectation1 = expectation(description: "Completion")
        
        let url = URL(string: "https://api.example.com")!
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
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
            
            let aggregation = Aggregation(database: database, network: network)
            
            let account = aggregation.account(context: database.viewContext, accountID: id)
            
            XCTAssertNotNil(account)
            XCTAssertEqual(account?.accountID, id)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchAccounts() {
        let expectation1 = expectation(description: "Completion")
        
        let url = URL(string: "https://api.example.com")!
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
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
            
            let aggregation = Aggregation(database: database, network: network)
            
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
        
        let url = URL(string: "https://api.example.com")!
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
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
            
            let aggregation = Aggregation(database: database, network: network)
            
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
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.accounts.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "accounts_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, network: network)
            
            aggregation.refreshAccounts { (error) in
                XCTAssertNil(error)
                
                let context = database.viewContext
                
                let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
                
                do {
                    let fetchedAccounts = try context.fetch(fetchRequest)
                    
                    XCTAssertEqual(fetchedAccounts.count, 4)
                } catch {
                    XCTFail(error.localizedDescription)
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testRefreshAccountByIDIsCached() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.account(accountID: 542).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "account_id_542", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, network: network)
            
            aggregation.refreshAccount(accountID: 542) { (error) in
                XCTAssertNil(error)
                
                let context = database.viewContext
                
                let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "accountID == %ld", argumentArray: [542])
                
                do {
                    let fetchedProviderAccounts = try context.fetch(fetchRequest)
                    
                    XCTAssertEqual(fetchedProviderAccounts.first?.accountID, 542)
                } catch {
                    XCTFail(error.localizedDescription)
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testAccountsLinkToProviderAccounts() {
        let expectation1 = expectation(description: "Network Provider Account Request")
        let expectation2 = expectation(description: "Network Account Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.providerAccounts.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "provider_accounts_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.accounts.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "accounts_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, network: network)
            
            aggregation.refreshProviderAccounts { (error) in
                XCTAssertNil(error)
                
                aggregation.refreshAccounts(completion: { (error) in
                    XCTAssertNil(error)
                    
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
                    
                    expectation2.fulfill()
                })
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1, expectation2], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testUpdatingAccount() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.account(accountID: 542).path) && isMethodPUT()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "account_id_542", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            let account = Account(context: managedObjectContext)
            account.populateTestData()
            account.accountID = 542
            
            try? managedObjectContext.save()
            
            let aggregation = Aggregation(database: database, network: network)
            
            aggregation.updateAccount(accountID: 542) { (error) in
                XCTAssertNil(error)
                
                let context = database.viewContext
                
                let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "accountID == %ld", argumentArray: [542])
                
                do {
                    let fetchedProviderAccounts = try context.fetch(fetchRequest)
                    
                    XCTAssertEqual(fetchedProviderAccounts.first?.accountID, 542)
                } catch {
                    XCTFail(error.localizedDescription)
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    // MARK: - Transaction Tests
    
    func testFetchTransactionByID() {
        let expectation1 = expectation(description: "Completion")
        
        let url = URL(string: "https://api.example.com")!
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
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
            
            let aggregation = Aggregation(database: database, network: network)
            
            let transaction = aggregation.transaction(context: database.viewContext, transactionID: id)
            
            XCTAssertNotNil(transaction)
            XCTAssertEqual(transaction?.transactionID, id)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchTransactions() {
        let expectation1 = expectation(description: "Completion")
        
        let url = URL(string: "https://api.example.com")!
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
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
            
            let aggregation = Aggregation(database: database, network: network)
            
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
        
        let url = URL(string: "https://api.example.com")!
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
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
            
            let aggregation = Aggregation(database: database, network: network)
            
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
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.transactions.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transactions_2018-08-01_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, network: network)
            
            let fromDate = Transaction.transactionDateFormatter.date(from: "2018-08-01")!
            let toDate = Transaction.transactionDateFormatter.date(from: "2018-08-31")!
            
            aggregation.refreshTransactions(from: fromDate, to: toDate) { (error) in
                XCTAssertNil(error)
                
                let context = database.viewContext
                
                let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
                
                do {
                    let fetchedTransactions = try context.fetch(fetchRequest)
                    
                    XCTAssertEqual(fetchedTransactions.count, 179)
                } catch {
                    XCTFail(error.localizedDescription)
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testRefreshTransactionsSkipsInvalid() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.transactions.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transactions_2018-08-01_invalid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, network: network)
            
            let fromDate = Transaction.transactionDateFormatter.date(from: "2018-08-01")!
            let toDate = Transaction.transactionDateFormatter.date(from: "2018-08-31")!
            
            aggregation.refreshTransactions(from: fromDate, to: toDate) { (error) in
                XCTAssertNil(error)
                
                let context = database.viewContext
                
                let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
                
                do {
                    let fetchedTransactions = try context.fetch(fetchRequest)
                    
                    XCTAssertEqual(fetchedTransactions.count, 176)
                } catch {
                    XCTFail(error.localizedDescription)
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testRefreshTransactionByIDIsCached() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.transaction(transactionID: 99703).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_id_99703", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, network: network)
            
            aggregation.refreshTransaction(transactionID: 99703) { (error) in
                XCTAssertNil(error)
                
                let context = database.viewContext
                
                let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "transactionID == %ld", argumentArray: [99703])
                
                do {
                    let fetchedTransactions = try context.fetch(fetchRequest)
                    
                    XCTAssertEqual(fetchedTransactions.first?.transactionID, 99703)
                } catch {
                    XCTFail(error.localizedDescription)
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testRefreshTransactionByIDsIsCached() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        let transactions: [Int64] = [1, 2, 3, 4, 5]
        
        stub(condition: isHost(url.host!) && pathStartsWith("/" + AggregationEndpoint.transactions.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transactions_2018-08-01_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, network: network)
            
            aggregation.refreshTransactions(transactionIDs: transactions) { (error) in
                XCTAssertNil(error)
                
                let context = database.viewContext
                
                let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
                
                do {
                    let fetchedTransactions = try context.fetch(fetchRequest)
                    
                    XCTAssertEqual(fetchedTransactions.count, 179)
                } catch {
                    XCTFail(error.localizedDescription)
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testTransactionsLinkToAccounts() {
        let expectation1 = expectation(description: "Network Account Request")
        let expectation2 = expectation(description: "Network Transaction Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.accounts.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "accounts_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.transactions.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transactions_2018-08-01_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, network: network)
            
            aggregation.refreshAccounts { (error) in
                XCTAssertNil(error)
                
                let fromDate = Transaction.transactionDateFormatter.date(from: "2018-08-01")!
                let toDate = Transaction.transactionDateFormatter.date(from: "2018-08-31")!
                
                aggregation.refreshTransactions(from: fromDate, to: toDate) { (error) in
                    XCTAssertNil(error)
                    
                    let context = database.viewContext
                    
                    let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "transactionID == %ld", argumentArray: [99704])
                    
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
                    
                    expectation2.fulfill()
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1, expectation2], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testTransactionsLinkToMerchants() {
        let expectation1 = expectation(description: "Network Merchant Request")
        let expectation2 = expectation(description: "Network Transaction Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.merchants.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "merchants_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.transactions.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transactions_2018-08-01_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, network: network)
            
            aggregation.refreshMerchants { (error) in
                XCTAssertNil(error)
                
                let fromDate = Transaction.transactionDateFormatter.date(from: "2018-08-01")!
                let toDate = Transaction.transactionDateFormatter.date(from: "2018-08-31")!
                
                aggregation.refreshTransactions(from: fromDate, to: toDate) { (error) in
                    XCTAssertNil(error)
                    
                    let context = database.viewContext
                    
                    let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "transactionID == %ld", argumentArray: [99704])
                    
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
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1, expectation2], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testTransactionsLinkToTransactionCategories() {
        let expectation1 = expectation(description: "Network Transaction Category Request")
        let expectation2 = expectation(description: "Network Transaction Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.transactionCategories.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_categories_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.transactions.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transactions_2018-08-01_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, network: network)
            
            aggregation.refreshTransactionCategories { (error) in
                XCTAssertNil(error)
                
                let fromDate = Transaction.transactionDateFormatter.date(from: "2018-08-01")!
                let toDate = Transaction.transactionDateFormatter.date(from: "2018-08-31")!
                
                aggregation.refreshTransactions(from: fromDate, to: toDate) { (error) in
                    XCTAssertNil(error)
                    
                    let context = database.viewContext
                    
                    let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "transactionID == %ld", argumentArray: [99704])
                    
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
                    
                    expectation2.fulfill()
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1, expectation2], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testUpdatingTransaction() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.transaction(transactionID: 99703).path) && isMethodPUT()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_id_99703", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            let transaction = Transaction(context: managedObjectContext)
            transaction.populateTestData()
            transaction.transactionID = 99703
            
            try? managedObjectContext.save()
            
            let aggregation = Aggregation(database: database, network: network)
            
            aggregation.updateTransaction(transactionID: 99703) { (error) in
                XCTAssertNil(error)
                
                let context = database.viewContext
                
                let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "transactionID == %ld", argumentArray: [99703])
                
                do {
                    let fetchedTransactions = try context.fetch(fetchRequest)
                    
                    XCTAssertEqual(fetchedTransactions.first?.transactionID, 99703)
                } catch {
                    XCTFail(error.localizedDescription)
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
        
        let url = URL(string: "https://api.example.com")!
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
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
            
            let aggregation = Aggregation(database: database, network: network)
            
            let transactionCategory = aggregation.transactionCategory(context: database.viewContext, transactionCategoryID: id)
            
            XCTAssertNotNil(transactionCategory)
            XCTAssertEqual(transactionCategory?.transactionCategoryID, id)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchTransactionCategories() {
        let expectation1 = expectation(description: "Completion")
        
        let url = URL(string: "https://api.example.com")!
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
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
            
            let aggregation = Aggregation(database: database, network: network)
            
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
        
        let url = URL(string: "https://api.example.com")!
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
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
            
            let aggregation = Aggregation(database: database, network: network)
            
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
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.transactionCategories.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_categories_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, network: network)
            
            aggregation.refreshTransactionCategories { (error) in
                XCTAssertNil(error)
                
                let context = database.viewContext
                
                let fetchRequest: NSFetchRequest<TransactionCategory> = TransactionCategory.fetchRequest()
                
                do {
                    let fetchedTransactionCategories = try context.fetch(fetchRequest)
                    
                    XCTAssertEqual(fetchedTransactionCategories.count, 43)
                } catch {
                    XCTFail(error.localizedDescription)
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
        
        let url = URL(string: "https://api.example.com")!
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
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
            
            let aggregation = Aggregation(database: database, network: network)
            
            let merchant = aggregation.merchant(context: database.viewContext, merchantID: id)
            
            XCTAssertNotNil(merchant)
            XCTAssertEqual(merchant?.merchantID, id)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchMerchants() {
        let expectation1 = expectation(description: "Completion")
        
        let url = URL(string: "https://api.example.com")!
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
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
            
            let aggregation = Aggregation(database: database, network: network)
            
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
        
        let url = URL(string: "https://api.example.com")!
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
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
            
            let aggregation = Aggregation(database: database, network: network)
            
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
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.merchants.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "merchants_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, network: network)
            
            aggregation.refreshMerchants { (error) in
                XCTAssertNil(error)
                
                let context = database.viewContext
                
                let fetchRequest: NSFetchRequest<Merchant> = Merchant.fetchRequest()
                
                do {
                    let fetchedMerchants = try context.fetch(fetchRequest)
                    
                    XCTAssertEqual(fetchedMerchants.count, 1200)
                } catch {
                    XCTFail(error.localizedDescription)
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }
    
}
