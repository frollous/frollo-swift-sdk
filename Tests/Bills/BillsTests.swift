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
    
    func testCreateBill() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + BillsEndpoint.bills.path) && isMethodPOST()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bill_id_12345", ofType: "json")!, status: 201, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, network: network)
            let bills = Bills(database: database, network: network, aggregation: aggregation)
            
            bills.createBill(transactionID: 987, frequency: .monthly, nextPaymentDate: Date(timeIntervalSinceNow: 20000), name: nil, notes: nil) { (error) in
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
        
        wait(for: [expectation1], timeout: 5.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testDeleteBill() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + BillsEndpoint.bill(billID: 12345).path)) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 204, headers: nil)
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        let aggregation = Aggregation(database: database, network: network)
        let bills = Bills(database: database, network: network, aggregation: aggregation)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let bill = Bill(context: managedObjectContext)
                bill.populateTestData()
                bill.billID = 12345
                
                try? managedObjectContext.save()
            }
            
            bills.deleteBill(billID: 12345) { (error) in
                XCTAssertNil(error)
                
                XCTAssertNil(bills.bill(context: database.viewContext, billID: 12345))
                
                expectation1.fulfill()
            }
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
    
    // MARK: - Bill Payment Tests
    
    func testFetchBillPaymentByID() {
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
                let testBillPayment = BillPayment(context: managedObjectContext)
                testBillPayment.populateTestData()
                testBillPayment.billPaymentID = id
                
                try! managedObjectContext.save()
            }
            
            let aggregation = Aggregation(database: database, network: network)
            let bills = Bills(database: database, network: network, aggregation: aggregation)
            
            let billPayment = bills.billPayment(context: database.viewContext, billPaymentID: id)
            
            XCTAssertNotNil(billPayment)
            XCTAssertEqual(billPayment?.billPaymentID, id)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchBillPayments() {
        let expectation1 = expectation(description: "Completion")
        
        let url = URL(string: "https://api.example.com")!
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testBillPayment1 = BillPayment(context: managedObjectContext)
                testBillPayment1.populateTestData()
                testBillPayment1.frequency = .weekly
                
                let testBillPayment2 = BillPayment(context: managedObjectContext)
                testBillPayment2.populateTestData()
                testBillPayment2.frequency = .weekly
                
                let testBillPayment3 = BillPayment(context: managedObjectContext)
                testBillPayment3.populateTestData()
                testBillPayment3.frequency = .monthly
                
                try! managedObjectContext.save()
            }
            
            let aggregation = Aggregation(database: database, network: network)
            let bills = Bills(database: database, network: network, aggregation: aggregation)
            
            let predicate = NSPredicate(format: "frequencyRawValue == %@", argumentArray: [Bill.Frequency.weekly.rawValue])
            let fetchedBillPayments = bills.billPayments(context: database.viewContext, filteredBy: predicate)
            
            XCTAssertNotNil(fetchedBillPayments)
            XCTAssertEqual(fetchedBillPayments?.count, 2)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testBillPaymentsFetchedResultsController() {
        let expectation1 = expectation(description: "Completion")
        
        let url = URL(string: "https://api.example.com")!
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testBillPayment1 = BillPayment(context: managedObjectContext)
                testBillPayment1.populateTestData()
                testBillPayment1.frequency = .weekly
                
                let testBillPayment2 = BillPayment(context: managedObjectContext)
                testBillPayment2.populateTestData()
                testBillPayment2.frequency = .monthly
                
                let testBillPayment3 = BillPayment(context: managedObjectContext)
                testBillPayment3.populateTestData()
                testBillPayment3.frequency = .weekly
                
                try! managedObjectContext.save()
            }
            
            let aggregation = Aggregation(database: database, network: network)
            let bills = Bills(database: database, network: network, aggregation: aggregation)
            
            let predicate = NSPredicate(format: "frequencyRawValue == %@", argumentArray: [Bill.Frequency.weekly.rawValue])
            let fetchedResultsController = bills.billPaymentsFetchedResultsController(context: managedObjectContext, filteredBy: predicate)
            
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
    
    func testDeleteBillPayment() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + BillsEndpoint.billPayment(billPaymentID: 12345).path)) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 204, headers: nil)
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        let aggregation = Aggregation(database: database, network: network)
        let bills = Bills(database: database, network: network, aggregation: aggregation)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let billPayment = BillPayment(context: managedObjectContext)
                billPayment.populateTestData()
                billPayment.billID = 12345
                
                try? managedObjectContext.save()
            }
            
            bills.deleteBillPayment(billPaymentID: 12345) { (error) in
                XCTAssertNil(error)
                
                XCTAssertNil(bills.billPayment(context: database.viewContext, billPaymentID: 12345))
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testRefreshBillPayments() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + BillsEndpoint.billPayments.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bill_payments_2018-12-01_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let fromDate = BillPayment.billDateFormatter.date(from: "2018-12-01")!
            let toDate = BillPayment.billDateFormatter.date(from: "2021-01-01")!
            
            let aggregation = Aggregation(database: database, network: network)
            let bills = Bills(database: database, network: network, aggregation: aggregation)
            
            bills.refreshBillPayments(from: fromDate, to: toDate) { (error) in
                XCTAssertNil(error)
                
                let context = database.viewContext
                
                let fetchRequest: NSFetchRequest<BillPayment> = BillPayment.fetchRequest()
                
                do {
                    let fetchedBillPayments = try context.fetch(fetchRequest)
                    
                    XCTAssertEqual(fetchedBillPayments.count, 7)
                } catch {
                    XCTFail(error.localizedDescription)
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testRefreshBillPaymentByID() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + BillsEndpoint.billPayment(billPaymentID: 12345).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bill_payment_id_12345", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, network: network)
            let bills = Bills(database: database, network: network, aggregation: aggregation)
            
            bills.refreshBillPayment(billPaymentID: 12345) { (error) in
                XCTAssertNil(error)
                
                let context = database.viewContext
                
                let fetchRequest: NSFetchRequest<BillPayment> = BillPayment.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "billPaymentID == %ld", argumentArray: [12345])
                
                do {
                    let fetchedBillPayments = try context.fetch(fetchRequest)
                    
                    XCTAssertEqual(fetchedBillPayments.first?.billPaymentID, 12345)
                } catch {
                    XCTFail(error.localizedDescription)
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testUpdateBillPayment() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + BillsEndpoint.billPayment(billPaymentID: 12345).path) && isMethodPUT()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bill_payment_id_12345", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let billPayment = BillPayment(context: managedObjectContext)
                billPayment.populateTestData()
                billPayment.billPaymentID = 12345
                
                try? managedObjectContext.save()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                let aggregation = Aggregation(database: database, network: network)
                let bills = Bills(database: database, network: network, aggregation: aggregation)
                
                bills.updateBillPayment(billPaymentID: 12345) { (error) in
                    XCTAssertNil(error)
                    
                    let context = database.viewContext
                    
                    let fetchRequest: NSFetchRequest<BillPayment> = BillPayment.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "billPaymentID == %ld", argumentArray: [12345])
                    
                    do {
                        let fetchedBillPayments = try context.fetch(fetchRequest)
                        
                        XCTAssertEqual(fetchedBillPayments.first?.billPaymentID, 12345)
                        XCTAssertEqual(fetchedBillPayments.first?.name, "Optus Internet")
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
    
    func testUpdateBillPaymentNotFound() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + BillsEndpoint.billPayment(billPaymentID: 12345).path) && isMethodPUT()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bill_payment_id_12345", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let billPayment = BillPayment(context: managedObjectContext)
                billPayment.populateTestData()
                billPayment.billPaymentID = 666
                
                try? managedObjectContext.save()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                let aggregation = Aggregation(database: database, network: network)
                let bills = Bills(database: database, network: network, aggregation: aggregation)
                
                bills.updateBillPayment(billPaymentID: 12345) { (error) in
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
    
    func testBillPaymentsLinkToBills() {
        let expectation1 = expectation(description: "Network Bills Request")
        let expectation2 = expectation(description: "Network Bill Payments Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + BillsEndpoint.bills.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bills_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        stub(condition: isHost(url.host!) && isPath("/" + BillsEndpoint.billPayments.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bill_payments_2018-12-01_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
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
                
                let fromDate = BillPayment.billDateFormatter.date(from: "2018-12-01")!
                let toDate = BillPayment.billDateFormatter.date(from: "2021-01-01")!
                
                bills.refreshBillPayments(from: fromDate, to: toDate) { (error) in
                    XCTAssertNil(error)
                    
                    let context = database.viewContext
                    
                    let fetchRequest: NSFetchRequest<BillPayment> = BillPayment.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "billPaymentID == %ld", argumentArray: [7991])
                    
                    do {
                        let fetchedBillPayments = try context.fetch(fetchRequest)
                        
                        XCTAssertEqual(fetchedBillPayments.count, 1)
                        
                        if let billPayment = fetchedBillPayments.first {
                            XCTAssertNotNil(billPayment.billID)
                            
                            XCTAssertEqual(billPayment.billID, billPayment.bill?.billID)
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
