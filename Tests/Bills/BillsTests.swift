//
//  BillsTests.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 21/12/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

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
    
}
