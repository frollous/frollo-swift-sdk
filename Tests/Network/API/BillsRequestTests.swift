//
//  BillsRequestTests.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 19/12/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import XCTest
@testable import FrolloSDK

import OHHTTPStubs

class BillsRequestTests: XCTestCase {
    
    private let keychainService = "BillsRequestTests"

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        Keychain(service: keychainService).removeAll()
        OHHTTPStubs.removeAllStubs()
    }

    func testFetchBills() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + BillsEndpoint.bills.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bills_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchBills { (response, error) in
            XCTAssertNil(error)
            
            if let billsResponse = response {
                XCTAssertEqual(billsResponse.count, 7)
                
                if let firstBill = billsResponse.first {
                    XCTAssertEqual(firstBill.id, 1059)
                    XCTAssertEqual(firstBill.name, "McDonald's Really Really Long Transaction Name for Bill Test")
                    XCTAssertEqual(firstBill.description, "MCDONALDS AUS")
                    XCTAssertEqual(firstBill.billType, .bill)
                    XCTAssertEqual(firstBill.status, .confirmed)
                    XCTAssertEqual(firstBill.dueAmount, "8.0")
                    XCTAssertEqual(firstBill.averageAmount, "8.0")
                    XCTAssertEqual(firstBill.frequency, .weekly)
                    XCTAssertEqual(firstBill.paymentStatus, .overdue)
                    XCTAssertEqual(firstBill.nextPaymentDate, "2018-08-19")
                    XCTAssertEqual(firstBill.category?.id, 75)
                    XCTAssertEqual(firstBill.category?.name, "Personal/Family")
                    XCTAssertEqual(firstBill.merchant?.id, 81)
                    XCTAssertEqual(firstBill.merchant?.name, "McDonald's")
                    XCTAssertNil(firstBill.note)
                    XCTAssertNil(firstBill.accountID)
                    XCTAssertNil(firstBill.lastPaymentDate)
                }
            } else {
                XCTFail("No response object")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }

}
