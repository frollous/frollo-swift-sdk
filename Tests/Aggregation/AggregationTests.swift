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
    
    func testRefreshProvidersIsCached() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.providers.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "providers_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
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
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "provider_id_12345", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
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
    
    func testRefreshProviderAccountsIsCached() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.providerAccounts.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "provider_accounts_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
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
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testRefreshProviderAccountByIDIsCached() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.providerAccount(providerAccountID: 123).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "provider_account_id_123", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
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
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "providers_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
        }
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.providerAccounts.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "provider_accounts_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
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
    
    func testRefreshAccountsIsCached() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.accounts.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "accounts_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
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
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "account_id_542", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
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
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "provider_accounts_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
        }
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.accounts.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "accounts_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
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
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "account_id_542", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
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
    
    func testRefreshTransactionsIsCached() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.transactions.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transactions_2018-08-01_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
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
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transactions_2018-08-01_invalid", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
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
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_id_99703", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
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
    
    func testRefreshTransactionCategoriesIsCached() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.transactionCategories.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_categories_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
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
    
    func testRefreshMerchantsIsCached() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.merchants.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "merchants_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
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
