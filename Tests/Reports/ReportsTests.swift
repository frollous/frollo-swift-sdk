//
//  ReportsTests.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 16/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import CoreData
import XCTest
@testable import FrolloSDK

import OHHTTPStubs

class ReportsTests: XCTestCase {
    
    let keychainService = "ReportsTests"

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        Keychain(service: keychainService).removeAll()
    }

    // MARK: - History Report Tests
    
    func testFetchingHistoryReportsByBudgetCategory() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + ReportsEndpoint.transactionsHistory.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_reports_history_budget_category_monthly_2018-01-01_2018-12-31", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, network: network)
            let reports = Reports(database: database, network: network, aggregation: aggregation)
            
            let fromDate = ReportTransactionHistory.dailyDateFormatter.date(from: "2018-01-01")!
            let toDate = ReportTransactionHistory.dailyDateFormatter.date(from: "2018-12-31")!
            
            reports.refreshTransactionHistoryReports(grouping: .budgetCategory, period: .month, from: fromDate, to: toDate) { (error) in
                XCTAssertNil(error)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    let context = database.viewContext
                    
                    // Check for overall reports
                    let overallFetchRequest: NSFetchRequest<ReportTransactionHistory> = ReportTransactionHistory.fetchRequest()
                    overallFetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionHistory.overall) + " == nil && " + #keyPath(ReportTransactionHistory.groupingRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.periodRawValue) + " == %@", argumentArray: [ReportGrouping.budgetCategory.rawValue, ReportTransactionHistory.Period.month.rawValue])
                    overallFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionHistory.dateString), ascending: true)]
                    
                    do {
                        let fetchedReports = try context.fetch(overallFetchRequest)
                        
                        XCTAssertEqual(fetchedReports.count, 12)
                        
                        if let firstReport = fetchedReports.first {
                            XCTAssertEqual(firstReport.dateString, "2018-01")
                            XCTAssertEqual(firstReport.value, NSDecimalNumber(string: "744.37"))
                            XCTAssertEqual(firstReport.budget, NSDecimalNumber(string: "11000"))
                            XCTAssertNil(firstReport.overall)
                            XCTAssertNotNil(firstReport.reports)
                            XCTAssertEqual(firstReport.reports?.count, 4)
                            XCTAssertEqual(firstReport.linkedID, -1)
                            XCTAssertNil(firstReport.name)
                        } else {
                            XCTFail("Reports not found")
                        }
                    } catch {
                        XCTFail(error.localizedDescription)
                    }
                    
                    // Check for group reports
                    let fetchRequest: NSFetchRequest<ReportTransactionHistory> = ReportTransactionHistory.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionHistory.overall.dateString) + " == %@ && " + #keyPath(ReportTransactionHistory.groupingRawValue) + " == %@", argumentArray: ["2018-03", ReportGrouping.budgetCategory.rawValue])
                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionHistory.linkedID), ascending: true)]
                    
                    do {
                        let fetchedReports = try context.fetch(fetchRequest)
                        
                        XCTAssertEqual(fetchedReports.count, 4)
                        
                        if let firstReport = fetchedReports.first {
                            XCTAssertEqual(firstReport.dateString, "2018-03")
                            XCTAssertEqual(firstReport.value, NSDecimalNumber(string: "3250"))
                            XCTAssertEqual(firstReport.budget, NSDecimalNumber(string: "4050"))
                            XCTAssertNotNil(firstReport.overall)
                            XCTAssertEqual(firstReport.overall?.dateString, "2018-03")
                            XCTAssertNotNil(firstReport.reports)
                            XCTAssertEqual(firstReport.reports?.count, 0)
                            XCTAssertEqual(firstReport.linkedID, 0)
                            XCTAssertEqual(firstReport.name, "income")
                        } else {
                            XCTFail("Reports not found")
                        }
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
    
    func testFetchingHistoryReportsByMerchant() {
        XCTFail()
    }
    
    func testFetchingHistoryReportsByTransactionCategory() {
        XCTFail()
    }
    
    func testFetchingHistoryReportsFilteredByBudgetCategory() {
        XCTFail()
    }
    
    func testFetchingHistoryReportsFilteredByDay() {
        XCTFail()
    }
    
    func testFetchingHistoryReportsFilteredByMonth() {
        XCTFail()
    }
    
    func testFetchingHistoryReportsFilteredByWeek() {
        XCTFail()
    }
    
    func testFetchingHistoryReportsUpdatesExisting() {
        XCTFail()
    }
    
    func testFetchingHistoryReportsCommingling() {
        XCTFail()
    }
    
    func testHistoryReportsLinkToMerchants() {
        XCTFail()
    }
    
    func testHistoryReportsLinkToTransactionCategories() {
        XCTFail()
    }
    
}
