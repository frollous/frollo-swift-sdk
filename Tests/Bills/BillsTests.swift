//
//  BillsTests.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 21/12/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import CoreData
import XCTest
@testable import FrolloSDK

import OHHTTPStubs

class BillsTests: XCTestCase {
    
    let keychainService = "BillsTests"

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        Keychain(service: keychainService).removeAll()
    }

    func testFetchBillByID() {
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
                let testBill = Bill(context: managedObjectContext)
                testBill.populateTestData()
                testBill.billID = id
                
                try! managedObjectContext.save()
            }
            
            let aggregation = Aggregation(database: database, network: network)
            let bills = Bills(database: database, network: network, aggregation: aggregation)
            
            let bill = bills.bill(context: database.viewContext, billID: id)
            
            XCTAssertNotNil(bill)
            XCTAssertEqual(bill?.billID, id)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchBills() {
        let expectation1 = expectation(description: "Completion")
        
        let url = URL(string: "https://api.example.com")!
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testBill1 = Bill(context: managedObjectContext)
                testBill1.populateTestData()
                testBill1.status = .estimated
                
                let testBill2 = Bill(context: managedObjectContext)
                testBill2.populateTestData()
                testBill2.status = .confirmed
                
                let testBill3 = Bill(context: managedObjectContext)
                testBill3.populateTestData()
                testBill3.status = .estimated
                
                try! managedObjectContext.save()
            }
            
            let aggregation = Aggregation(database: database, network: network)
            let bills = Bills(database: database, network: network, aggregation: aggregation)
            
            let predicate = NSPredicate(format: "statusRawValue == %@", argumentArray: [Bill.Status.estimated.rawValue])
            let fetchedBills = bills.bills(context: database.viewContext, filteredBy: predicate)
            
            XCTAssertNotNil(fetchedBills)
            XCTAssertEqual(fetchedBills?.count, 2)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testBillsFetchedResultsController() {
        let expectation1 = expectation(description: "Completion")
        
        let url = URL(string: "https://api.example.com")!
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testBill1 = Bill(context: managedObjectContext)
                testBill1.populateTestData()
                testBill1.status = .estimated
                
                let testBill2 = Bill(context: managedObjectContext)
                testBill2.populateTestData()
                testBill2.status = .confirmed
                
                let testBill3 = Bill(context: managedObjectContext)
                testBill3.populateTestData()
                testBill3.status = .estimated
                
                try! managedObjectContext.save()
            }
            
            let aggregation = Aggregation(database: database, network: network)
            let bills = Bills(database: database, network: network, aggregation: aggregation)
            
            let predicate = NSPredicate(format: "statusRawValue == %@", argumentArray: [Bill.Status.estimated.rawValue])
            let fetchedResultsController = bills.billsFetchedResultsController(context: managedObjectContext, filteredBy: predicate)
            
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
    
    func testRefreshBills() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + BillsEndpoint.bills.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bills_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, network: network)
            let bills = Bills(database: database, network: network, aggregation: aggregation)
            
            bills.refreshBills() { (error) in
                XCTAssertNil(error)
                
                let context = database.viewContext
                
                let fetchRequest: NSFetchRequest<Bill> = Bill.fetchRequest()
                
                do {
                    let fetchedBills = try context.fetch(fetchRequest)
                    
                    XCTAssertEqual(fetchedBills.count, 7)
                } catch {
                    XCTFail(error.localizedDescription)
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testRefreshBillByID() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + BillsEndpoint.bill(billID: 12345).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bill_id_12345", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, network: network)
            let bills = Bills(database: database, network: network, aggregation: aggregation)
            
            bills.refreshBill(billID: 12345) { (error) in
                XCTAssertNil(error)
                
                let context = database.viewContext
                
                let fetchRequest: NSFetchRequest<Bill> = Bill.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "billID == %ld", argumentArray: [12345])
                
                do {
                    let fetchedBills = try context.fetch(fetchRequest)
                    
                    XCTAssertEqual(fetchedBills.first?.billID, 12345)
                } catch {
                    XCTFail(error.localizedDescription)
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testUpdateBill() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + BillsEndpoint.bill(billID: 12345).path) && isMethodPUT()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bill_id_12345", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let bill = Bill(context: managedObjectContext)
                bill.populateTestData()
                bill.billID = 12345
                
                try? managedObjectContext.save()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                let aggregation = Aggregation(database: database, network: network)
                let bills = Bills(database: database, network: network, aggregation: aggregation)
                
                bills.updateBill(billID: 12345) { (error) in
                    XCTAssertNil(error)
                    
                    let context = database.viewContext
                    
                    let fetchRequest: NSFetchRequest<Bill> = Bill.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "billID == %ld", argumentArray: [12345])
                    
                    do {
                        let fetchedBills = try context.fetch(fetchRequest)
                        
                        XCTAssertEqual(fetchedBills.first?.billID, 12345)
                        XCTAssertEqual(fetchedBills.first?.name, "Netflix")
                    } catch {
                        XCTFail(error.localizedDescription)
                    }
                    
                    expectation1.fulfill()
                }
            }
        }
        
        wait(for: [expectation1], timeout: 5.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testUpdateBillNotFound() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + BillsEndpoint.bill(billID: 12345).path) && isMethodPUT()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bill_id_12345", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let bill = Bill(context: managedObjectContext)
                bill.populateTestData()
                bill.billID = 666
                
                try? managedObjectContext.save()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                let aggregation = Aggregation(database: database, network: network)
                let bills = Bills(database: database, network: network, aggregation: aggregation)
                
                bills.updateBill(billID: 12345) { (error) in
                    XCTAssertNotNil(error)
                    
                    if let dataError = error as? DataError {
                        XCTAssertEqual(dataError.type, .database)
                        XCTAssertEqual(dataError.subType, .notFound)
                    } else {
                        XCTFail("Wrong error type")
                    }
                    
                    expectation1.fulfill()
                }
            }
        }
        
        wait(for: [expectation1], timeout: 5.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testBillsLinkToAccounts() {
        let expectation1 = expectation(description: "Network Account Request")
        let expectation2 = expectation(description: "Network Bill Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + BillsEndpoint.bills.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bills_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
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
            let bills = Bills(database: database, network: network, aggregation: aggregation)
            
            aggregation.refreshAccounts() { (error) in
                XCTAssertNil(error)
                
                bills.refreshBills() { (error) in
                    XCTAssertNil(error)
                    
                    let context = database.viewContext
                    
                    let fetchRequest: NSFetchRequest<Bill> = Bill.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "billID == %ld", argumentArray: [1249])
                    
                    do {
                        let fetchedBills = try context.fetch(fetchRequest)
                        
                        XCTAssertEqual(fetchedBills.count, 1)
                        
                        if let bill = fetchedBills.first {
                            XCTAssertNotNil(bill.account)
                            
                            XCTAssertEqual(bill.accountID, bill.account?.accountID)
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
    
    func testBillsLinkToMerchants() {
        let expectation1 = expectation(description: "Network Merchants Request")
        let expectation2 = expectation(description: "Network Bill Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + BillsEndpoint.bills.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bills_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.merchants.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "merchants_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, network: network)
            let bills = Bills(database: database, network: network, aggregation: aggregation)
            
            aggregation.refreshMerchants() { (error) in
                XCTAssertNil(error)
                
                bills.refreshBills() { (error) in
                    XCTAssertNil(error)
                    
                    let context = database.viewContext
                    
                    let fetchRequest: NSFetchRequest<Bill> = Bill.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "billID == %ld", argumentArray: [1249])
                    
                    do {
                        let fetchedBills = try context.fetch(fetchRequest)
                        
                        XCTAssertEqual(fetchedBills.count, 1)
                        
                        if let bill = fetchedBills.first {
                            XCTAssertNotNil(bill.merchant)
                            
                            XCTAssertEqual(bill.merchantID, bill.merchant?.merchantID)
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
    
    func testBillsLinkToTransactionCategories() {
        let expectation1 = expectation(description: "Network Merchants Request")
        let expectation2 = expectation(description: "Network Bill Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + BillsEndpoint.bills.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bills_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.transactionCategories.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_categories_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, network: network)
            let bills = Bills(database: database, network: network, aggregation: aggregation)
            
            aggregation.refreshTransactionCategories() { (error) in
                XCTAssertNil(error)
                
                bills.refreshBills() { (error) in
                    XCTAssertNil(error)
                    
                    let context = database.viewContext
                    
                    let fetchRequest: NSFetchRequest<Bill> = Bill.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "billID == %ld", argumentArray: [1249])
                    
                    do {
                        let fetchedBills = try context.fetch(fetchRequest)
                        
                        XCTAssertEqual(fetchedBills.count, 1)
                        
                        if let bill = fetchedBills.first {
                            XCTAssertNotNil(bill.transactionCategory)
                            
                            XCTAssertEqual(bill.transactionCategoryID, bill.transactionCategory?.transactionCategoryID)
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
    
}
