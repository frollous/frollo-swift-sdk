//
//  ReportsRequestTests.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 14/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import XCTest
@testable import FrolloSDK

import OHHTTPStubs

class ReportsRequestTests: XCTestCase {
    
    private let keychainService = "ReportsRequestTests"

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFetchTransactionCurrentReports() {
        
    }

    func testFetchTransactionHistoryReports() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + ReportsEndpoint.transactionsHistory.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        let fromDate = ReportTransactionHistory.dailyDateFormatter.date(from: "2018-01-01")!
        let toDate = ReportTransactionHistory.dailyDateFormatter.date(from: "2018-12-31")!
        
        network.fetchTransactionHistoryReports(grouping: .budgetCategory, period: .month, fromDate: fromDate, toDate: toDate, budgetCategory: nil) { (response, error) in
            XCTAssertNil(error)
            
            if let reportsResponse = response {
                XCTAssertEqual(reportsResponse.data.count, 12)
                
                if let firstReport = reportsResponse.data.first {
                    XCTAssertEqual(firstReport.value, "100.00")
                    
                    if let firstCategoryReport = firstReport.groups.first {
                        
                    } else {
                        XCTFail("No category report")
                    }
                } else {
                    XCTFail("No report")
                }
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 5.0)
    }

}
