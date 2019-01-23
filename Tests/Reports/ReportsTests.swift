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
    
    // MARK: - Current Report Tests
    
    func testFetchingCurrentReportsByBudgetCategory() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + ReportsEndpoint.transactionsCurrent.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_reports_current_budget_category", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, network: network)
            let reports = Reports(database: database, network: network, aggregation: aggregation)
            
            reports.refreshTransactionCurrentReports(grouping: .budgetCategory) { (error) in
                XCTAssertNil(error)

                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    let context = database.viewContext
                    
                    // Check for overall reports
                    let overallFetchRequest: NSFetchRequest<ReportTransactionCurrent> = ReportTransactionCurrent.fetchRequest()
                    overallFetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionCurrent.budgetCategoryRawValue) + " == nil && " + #keyPath(ReportTransactionCurrent.linkedID) + " == -1 && " + #keyPath(ReportTransactionCurrent.groupingRawValue) + " == %@", argumentArray: [ReportGrouping.budgetCategory.rawValue])
                    overallFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionCurrent.day), ascending: true)]
                    
                    do {
                        let fetchedReports = try context.fetch(overallFetchRequest)
                        
                        XCTAssertEqual(fetchedReports.count, 31)
                        
                        if let firstReport = fetchedReports.first {
                            XCTAssertEqual(firstReport.day, 1)
                            XCTAssertEqual(firstReport.amount, NSDecimalNumber(string: "-187.8"))
                            XCTAssertEqual(firstReport.budget, NSDecimalNumber(string: "387.1"))
                            XCTAssertEqual(firstReport.average, NSDecimalNumber(string: "-120.53"))
                            XCTAssertEqual(firstReport.previous, NSDecimalNumber(string: "-215.8"))
                            XCTAssertNil(firstReport.budgetCategory)
                            XCTAssertEqual(firstReport.linkedID, -1)
                            XCTAssertNil(firstReport.name)
                        } else {
                            XCTFail("Reports not found")
                        }
                    } catch {
                        XCTFail(error.localizedDescription)
                    }
                    
                    // Check for group reports
                    let groupFetchRequest: NSFetchRequest<ReportTransactionCurrent> = ReportTransactionCurrent.fetchRequest()
                    groupFetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionCurrent.day) + " == %ld && " + #keyPath(ReportTransactionCurrent.linkedID) + " != -1 &&  " + #keyPath(ReportTransactionCurrent.budgetCategoryRawValue) + " == nil && " + #keyPath(ReportTransactionCurrent.groupingRawValue) + " == %@", argumentArray: [3, ReportGrouping.budgetCategory.rawValue])
                    groupFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionCurrent.linkedID), ascending: true)]
                    
                    do {
                        let fetchedGroupReports = try context.fetch(groupFetchRequest)
                        
                        XCTAssertEqual(fetchedGroupReports.count, 5)
                        
                        let thirdReport = fetchedGroupReports[2]
                        XCTAssertEqual(thirdReport.day, 3)
                        XCTAssertEqual(thirdReport.amount, NSDecimalNumber(string: "-89.95"))
                        XCTAssertEqual(thirdReport.budget, NSDecimalNumber(string: "64.52"))
                        XCTAssertEqual(thirdReport.average, NSDecimalNumber(string: "-55.33"))
                        XCTAssertEqual(thirdReport.previous, NSDecimalNumber(string: "-92"))
                        XCTAssertNil(thirdReport.budgetCategory)
                        XCTAssertEqual(thirdReport.linkedID, 2)
                        XCTAssertEqual(thirdReport.name, "lifestyle")
                    } catch {
                        XCTFail(error.localizedDescription)
                    }
                    
                    expectation1.fulfill()
                }
            }
        }
        
        wait(for: [expectation1], timeout: 10.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testFetchingCurrentReportsByMerchant() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + ReportsEndpoint.transactionsCurrent.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_reports_current_merchant", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, network: network)
            let reports = Reports(database: database, network: network, aggregation: aggregation)
            
            reports.refreshTransactionCurrentReports(grouping: .merchant) { (error) in
                XCTAssertNil(error)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    let context = database.viewContext
                    
                    // Check for overall reports
                    let overallFetchRequest: NSFetchRequest<ReportTransactionCurrent> = ReportTransactionCurrent.fetchRequest()
                    overallFetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionCurrent.budgetCategoryRawValue) + " == nil && " + #keyPath(ReportTransactionCurrent.linkedID) + " == -1 && " + #keyPath(ReportTransactionCurrent.groupingRawValue) + " == %@", argumentArray: [ReportGrouping.merchant.rawValue])
                    overallFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionCurrent.day), ascending: true)]
                    
                    do {
                        let fetchedReports = try context.fetch(overallFetchRequest)
                        
                        XCTAssertEqual(fetchedReports.count, 31)
                        
                        if let firstReport = fetchedReports.first {
                            XCTAssertEqual(firstReport.day, 1)
                            XCTAssertEqual(firstReport.amount, NSDecimalNumber(string: "-187.8"))
                            XCTAssertNil(firstReport.budget)
                            XCTAssertEqual(firstReport.average, NSDecimalNumber(string: "-120.53"))
                            XCTAssertEqual(firstReport.previous, NSDecimalNumber(string: "-215.8"))
                            XCTAssertNil(firstReport.budgetCategory)
                            XCTAssertEqual(firstReport.linkedID, -1)
                            XCTAssertNil(firstReport.name)
                        } else {
                            XCTFail("Reports not found")
                        }
                    } catch {
                        XCTFail(error.localizedDescription)
                    }
                    
                    // Check for group reports
                    let groupFetchRequest: NSFetchRequest<ReportTransactionCurrent> = ReportTransactionCurrent.fetchRequest()
                    groupFetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionCurrent.day) + " == %ld && " + #keyPath(ReportTransactionCurrent.linkedID) + " != -1 &&  " + #keyPath(ReportTransactionCurrent.budgetCategoryRawValue) + " == nil && " + #keyPath(ReportTransactionCurrent.groupingRawValue) + " == %@", argumentArray: [3, ReportGrouping.merchant.rawValue])
                    groupFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionCurrent.linkedID), ascending: true)]
                    
                    do {
                        let fetchedGroupReports = try context.fetch(groupFetchRequest)
                        
                        XCTAssertEqual(fetchedGroupReports.count, 24)
                        
                        let thirdReport = fetchedGroupReports[1]
                        XCTAssertEqual(thirdReport.day, 3)
                        XCTAssertEqual(thirdReport.amount, NSDecimalNumber(string: "-159.41"))
                        XCTAssertNil(thirdReport.budget)
                        XCTAssertEqual(thirdReport.average, NSDecimalNumber(string: "-106.27"))
                        XCTAssertEqual(thirdReport.previous, NSDecimalNumber(string: "-159.41"))
                        XCTAssertNil(thirdReport.budgetCategory)
                        XCTAssertEqual(thirdReport.linkedID, 2)
                        XCTAssertEqual(thirdReport.name, "Woolworths")
                    } catch {
                        XCTFail(error.localizedDescription)
                    }
                    
                    expectation1.fulfill()
                }
            }
        }
        
        wait(for: [expectation1], timeout: 10.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testFetchingCurrentReportsByTransactionCategory() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + ReportsEndpoint.transactionsCurrent.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_reports_current_txn_category", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, network: network)
            let reports = Reports(database: database, network: network, aggregation: aggregation)
            
            reports.refreshTransactionCurrentReports(grouping: .transactionCategory) { (error) in
                XCTAssertNil(error)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    let context = database.viewContext
                    
                    // Check for overall reports
                    let overallFetchRequest: NSFetchRequest<ReportTransactionCurrent> = ReportTransactionCurrent.fetchRequest()
                    overallFetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionCurrent.budgetCategoryRawValue) + " == nil && " + #keyPath(ReportTransactionCurrent.linkedID) + " == -1 && " + #keyPath(ReportTransactionCurrent.groupingRawValue) + " == %@", argumentArray: [ReportGrouping.transactionCategory.rawValue])
                    overallFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionCurrent.day), ascending: true)]
                    
                    do {
                        let fetchedReports = try context.fetch(overallFetchRequest)
                        
                        XCTAssertEqual(fetchedReports.count, 31)
                        
                        if let firstReport = fetchedReports.first {
                            XCTAssertEqual(firstReport.day, 1)
                            XCTAssertEqual(firstReport.amount, NSDecimalNumber(string: "-187.8"))
                            XCTAssertNil(firstReport.budget)
                            XCTAssertEqual(firstReport.average, NSDecimalNumber(string: "-120.53"))
                            XCTAssertEqual(firstReport.previous, NSDecimalNumber(string: "-215.8"))
                            XCTAssertNil(firstReport.budgetCategory)
                            XCTAssertEqual(firstReport.linkedID, -1)
                            XCTAssertNil(firstReport.name)
                        } else {
                            XCTFail("Reports not found")
                        }
                    } catch {
                        XCTFail(error.localizedDescription)
                    }
                    
                    // Check for group reports
                    let groupFetchRequest: NSFetchRequest<ReportTransactionCurrent> = ReportTransactionCurrent.fetchRequest()
                    groupFetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionCurrent.day) + " == %ld && " + #keyPath(ReportTransactionCurrent.linkedID) + " != -1 &&  " + #keyPath(ReportTransactionCurrent.budgetCategoryRawValue) + " == nil && " + #keyPath(ReportTransactionCurrent.groupingRawValue) + " == %@", argumentArray: [3, ReportGrouping.transactionCategory.rawValue])
                    groupFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionCurrent.linkedID), ascending: true)]
                    
                    do {
                        let fetchedGroupReports = try context.fetch(groupFetchRequest)
                        
                        XCTAssertEqual(fetchedGroupReports.count, 17)
                        
                        let thirdReport = fetchedGroupReports[2]
                        XCTAssertEqual(thirdReport.day, 3)
                        XCTAssertEqual(thirdReport.amount, NSDecimalNumber(string: "-159.41"))
                        XCTAssertNil(thirdReport.budget)
                        XCTAssertEqual(thirdReport.average, NSDecimalNumber(string: "-106.27"))
                        XCTAssertEqual(thirdReport.previous, NSDecimalNumber(string: "-159.41"))
                        XCTAssertNil(thirdReport.budgetCategory)
                        XCTAssertEqual(thirdReport.linkedID, 66)
                        XCTAssertEqual(thirdReport.name, "Groceries")
                    } catch {
                        XCTFail(error.localizedDescription)
                    }
                    
                    expectation1.fulfill()
                }
            }
        }
        
        wait(for: [expectation1], timeout: 10.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testFetchingCurrentReportsFilteredByBudgetCategory() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + ReportsEndpoint.transactionsCurrent.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_reports_current_txn_category_lifestyle", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, network: network)
            let reports = Reports(database: database, network: network, aggregation: aggregation)
            
            reports.refreshTransactionCurrentReports(grouping: .transactionCategory, budgetCategory: .lifestyle) { (error) in
                XCTAssertNil(error)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    let context = database.viewContext
                    
                    // Check for overall reports
                    let overallFetchRequest: NSFetchRequest<ReportTransactionCurrent> = ReportTransactionCurrent.fetchRequest()
                    overallFetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionCurrent.budgetCategoryRawValue) + " == %@ && " + #keyPath(ReportTransactionCurrent.linkedID) + " == -1 && " + #keyPath(ReportTransactionCurrent.groupingRawValue) + " == %@", argumentArray: [BudgetCategory.lifestyle.rawValue, ReportGrouping.transactionCategory.rawValue])
                    overallFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionCurrent.day), ascending: true)]
                    
                    do {
                        let fetchedReports = try context.fetch(overallFetchRequest)
                        
                        XCTAssertEqual(fetchedReports.count, 31)
                        
                        if let firstReport = fetchedReports.first {
                            XCTAssertEqual(firstReport.day, 1)
                            XCTAssertEqual(firstReport.amount, NSDecimalNumber(string: "-108"))
                            XCTAssertNil(firstReport.budget)
                            XCTAssertEqual(firstReport.average, NSDecimalNumber(string: "-27.33"))
                            XCTAssertEqual(firstReport.previous, NSDecimalNumber(string: "-66"))
                            XCTAssertEqual(firstReport.budgetCategory, .lifestyle)
                            XCTAssertEqual(firstReport.linkedID, -1)
                            XCTAssertNil(firstReport.name)
                        } else {
                            XCTFail("Reports not found")
                        }
                    } catch {
                        XCTFail(error.localizedDescription)
                    }
                    
                    // Check for group reports
                    let groupFetchRequest: NSFetchRequest<ReportTransactionCurrent> = ReportTransactionCurrent.fetchRequest()
                    groupFetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionCurrent.day) + " == %ld && " + #keyPath(ReportTransactionCurrent.linkedID) + " != -1 &&  " + #keyPath(ReportTransactionCurrent.budgetCategoryRawValue) + " == %@ && " + #keyPath(ReportTransactionCurrent.groupingRawValue) + " == %@", argumentArray: [6, BudgetCategory.lifestyle.rawValue, ReportGrouping.transactionCategory.rawValue])
                    groupFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionCurrent.linkedID), ascending: true)]
                    
                    do {
                        let fetchedGroupReports = try context.fetch(groupFetchRequest)
                        
                        XCTAssertEqual(fetchedGroupReports.count, 11)
                        
                        let thirdReport = fetchedGroupReports[0]
                        XCTAssertEqual(thirdReport.day, 6)
                        XCTAssertEqual(thirdReport.amount, NSDecimalNumber(string: "-11.99"))
                        XCTAssertNil(thirdReport.budget)
                        XCTAssertEqual(thirdReport.average, NSDecimalNumber(string: "-7.99"))
                        XCTAssertEqual(thirdReport.previous, NSDecimalNumber(string: "-11.99"))
                        XCTAssertEqual(thirdReport.budgetCategory, .lifestyle)
                        XCTAssertEqual(thirdReport.linkedID, 64)
                        XCTAssertEqual(thirdReport.name, "Entertainment/Recreation")
                    } catch {
                        XCTFail(error.localizedDescription)
                    }
                    
                    expectation1.fulfill()
                }
            }
        }
        
        wait(for: [expectation1], timeout: 10.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testFetchingCurrentReportsRemovesExisting() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        var count = 0
        
        stub(condition: isHost(url.host!) && isPath("/" + ReportsEndpoint.transactionsCurrent.path)) { (request) -> OHHTTPStubsResponse in
            if count > 0 {
                return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_reports_current_txn_category_3_days", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
            }
            count += 1
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_reports_current_txn_category", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, network: network)
            let reports = Reports(database: database, network: network, aggregation: aggregation)
            
            reports.refreshTransactionCurrentReports(grouping: .transactionCategory) { (error) in
                XCTAssertNil(error)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    let context = database.viewContext
                    
                    let overallFetchRequest: NSFetchRequest<ReportTransactionCurrent> = ReportTransactionCurrent.fetchRequest()
                    overallFetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionCurrent.budgetCategoryRawValue) + " == nil && " + #keyPath(ReportTransactionCurrent.day) + " == %ld && " + #keyPath(ReportTransactionCurrent.linkedID) + " == -1 && " + #keyPath(ReportTransactionCurrent.groupingRawValue) + " == %@", argumentArray: [11, ReportGrouping.transactionCategory.rawValue])
                    overallFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionCurrent.day), ascending: true)]
                    
                    let groupFetchRequest: NSFetchRequest<ReportTransactionCurrent> = ReportTransactionCurrent.fetchRequest()
                    groupFetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionCurrent.day) + " == %ld && " + #keyPath(ReportTransactionCurrent.linkedID) + " != -1 && " + #keyPath(ReportTransactionCurrent.budgetCategoryRawValue) + " == nil && " + #keyPath(ReportTransactionCurrent.groupingRawValue) + " == %@", argumentArray: [11, ReportGrouping.transactionCategory.rawValue])
                    groupFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionCurrent.linkedID), ascending: true)]
                    
                    // Check for late overall report
                    do {
                        let fetchedReports = try context.fetch(overallFetchRequest)
                        
                        XCTAssertEqual(fetchedReports.count, 1)
                        
                        if let firstReport = fetchedReports.first {
                            XCTAssertEqual(firstReport.day, 11)
                            XCTAssertEqual(firstReport.amount, NSDecimalNumber(string: "-64.5"))
                            XCTAssertNil(firstReport.budget)
                            XCTAssertEqual(firstReport.average, NSDecimalNumber(string: "-188.32"))
                            XCTAssertEqual(firstReport.previous, NSDecimalNumber(string: "-107.5"))
                            XCTAssertNil(firstReport.budgetCategory)
                            XCTAssertEqual(firstReport.linkedID, -1)
                            XCTAssertNil(firstReport.name)
                        } else {
                            XCTFail("Report not found")
                        }
                    } catch {
                        XCTFail(error.localizedDescription)
                    }
                    
                    // Check for late group report
                    do {
                        let fetchedGroupReports = try context.fetch(groupFetchRequest)
                        
                        XCTAssertEqual(fetchedGroupReports.count, 17)
                        
                        let thirdReport = fetchedGroupReports[2]
                        XCTAssertEqual(thirdReport.day, 11)
                        XCTAssertEqual(thirdReport.amount, NSDecimalNumber(string: "-24.5"))
                        XCTAssertNil(thirdReport.budget)
                        XCTAssertEqual(thirdReport.average, NSDecimalNumber(string: "-16.33"))
                        XCTAssertEqual(thirdReport.previous, NSDecimalNumber(string: "-24.5"))
                        XCTAssertNil(thirdReport.budgetCategory)
                        XCTAssertEqual(thirdReport.linkedID, 66)
                        XCTAssertEqual(thirdReport.name, "Groceries")
                    } catch {
                        XCTFail(error.localizedDescription)
                    }
                    
                    reports.refreshTransactionCurrentReports(grouping: .transactionCategory) { (error) in
                        XCTAssertNil(error)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            // Check for late overall report
                            do {
                                let fetchedReports = try context.fetch(overallFetchRequest)
                                
                                XCTAssertEqual(fetchedReports.count, 1)
                                
                                if let firstReport = fetchedReports.first {
                                    XCTAssertEqual(firstReport.day, 11)
                                    XCTAssertNil(firstReport.amount)
                                    XCTAssertNil(firstReport.budget)
                                    XCTAssertEqual(firstReport.average, NSDecimalNumber(string: "-188.32"))
                                    XCTAssertEqual(firstReport.previous, NSDecimalNumber(string: "-107.5"))
                                    XCTAssertNil(firstReport.budgetCategory)
                                    XCTAssertEqual(firstReport.linkedID, -1)
                                    XCTAssertNil(firstReport.name)
                                } else {
                                    XCTFail("Report not found")
                                }
                            } catch {
                                XCTFail(error.localizedDescription)
                            }
                            
                            // Check for late group report
                            do {
                                let fetchedGroupReports = try context.fetch(groupFetchRequest)
                                
                                XCTAssertEqual(fetchedGroupReports.count, 15)
                                
                                let thirdReport = fetchedGroupReports[2]
                                XCTAssertEqual(thirdReport.day, 11)
                                XCTAssertNil(thirdReport.amount)
                                XCTAssertNil(thirdReport.budget)
                                XCTAssertEqual(thirdReport.average, NSDecimalNumber(string: "0"))
                                XCTAssertEqual(thirdReport.previous, NSDecimalNumber(string: "0"))
                                XCTAssertNil(thirdReport.budgetCategory)
                                XCTAssertEqual(thirdReport.linkedID, 68)
                                XCTAssertEqual(thirdReport.name, "Home Improvement")
                            } catch {
                                XCTFail(error.localizedDescription)
                            }
                            
                            expectation1.fulfill()
                        }
                    }
                }
            }
        }
        
        wait(for: [expectation1], timeout: 10.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testFetchingCurrentReportsCommingling() {
        let expectation1 = expectation(description: "Database setup")
        let expectation2 = expectation(description: "Network Request 1")
        let expectation3 = expectation(description: "Network Request 2")
        let expectation4 = expectation(description: "Network Request 3")
        let expectation5 = expectation(description: "Fetch")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + ReportsEndpoint.transactionsCurrent.path)) { (request) -> OHHTTPStubsResponse in
            if let requestURL = request.url, let queryItems = URLComponents(url: requestURL, resolvingAgainstBaseURL: true)?.queryItems {
                var budgetCategory: String = ""
                
                for queryItem in queryItems {
                    if queryItem.name == "budget_category", let value = queryItem.value {
                        budgetCategory = value
                    }
                }
                
                if budgetCategory == "living" {
                    return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_reports_current_txn_category_living", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
                } else if budgetCategory == "lifestyle" {
                    return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_reports_current_txn_category_lifestyle", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
                }
            }
            
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_reports_current_txn_category", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
            
        let aggregation = Aggregation(database: database, network: network)
        let reports = Reports(database: database, network: network, aggregation: aggregation)
            
        reports.refreshTransactionCurrentReports(grouping: .transactionCategory, budgetCategory: .lifestyle) { (error) in
            XCTAssertNil(error)
            
            expectation2.fulfill()
        }
        
        reports.refreshTransactionCurrentReports(grouping: .transactionCategory, budgetCategory: .living) { (error) in
            XCTAssertNil(error)
            
            expectation3.fulfill()
        }
        
        reports.refreshTransactionCurrentReports(grouping: .transactionCategory, budgetCategory: nil) { (error) in
            XCTAssertNil(error)
            
            expectation4.fulfill()
        }
        
        wait(for: [expectation2, expectation3, expectation4], timeout: 3.0)
            
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let context = database.viewContext
            
            // Check for overall reports
            let overallLifestyleFetchRequest: NSFetchRequest<ReportTransactionCurrent> = ReportTransactionCurrent.fetchRequest()
            overallLifestyleFetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionCurrent.budgetCategoryRawValue) + " == %@ && " + #keyPath(ReportTransactionCurrent.linkedID) + " == -1 && " + #keyPath(ReportTransactionCurrent.groupingRawValue) + " == %@", argumentArray: [BudgetCategory.lifestyle.rawValue, ReportGrouping.transactionCategory.rawValue])
            overallLifestyleFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionCurrent.day), ascending: true)]
            
            do {
                let fetchedReports = try context.fetch(overallLifestyleFetchRequest)
                
                XCTAssertEqual(fetchedReports.count, 31)
                
                if let firstReport = fetchedReports.first {
                    XCTAssertEqual(firstReport.day, 1)
                    XCTAssertEqual(firstReport.amount, NSDecimalNumber(string: "-108"))
                    XCTAssertNil(firstReport.budget)
                    XCTAssertEqual(firstReport.average, NSDecimalNumber(string: "-27.33"))
                    XCTAssertEqual(firstReport.previous, NSDecimalNumber(string: "-66"))
                    XCTAssertEqual(firstReport.budgetCategory, .lifestyle)
                    XCTAssertEqual(firstReport.linkedID, -1)
                    XCTAssertNil(firstReport.name)
                } else {
                    XCTFail("Reports not found")
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            // Check for group reports
            let groupLifestyleFetchRequest: NSFetchRequest<ReportTransactionCurrent> = ReportTransactionCurrent.fetchRequest()
            groupLifestyleFetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionCurrent.day) + " == %ld && " + #keyPath(ReportTransactionCurrent.linkedID) + " != -1 &&  " + #keyPath(ReportTransactionCurrent.budgetCategoryRawValue) + " == %@ && " + #keyPath(ReportTransactionCurrent.groupingRawValue) + " == %@", argumentArray: [6, BudgetCategory.lifestyle.rawValue, ReportGrouping.transactionCategory.rawValue])
            groupLifestyleFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionCurrent.linkedID), ascending: true)]
            
            do {
                let fetchedGroupReports = try context.fetch(groupLifestyleFetchRequest)
                
                XCTAssertEqual(fetchedGroupReports.count, 11)
                
                let thirdReport = fetchedGroupReports[0]
                XCTAssertEqual(thirdReport.day, 6)
                XCTAssertEqual(thirdReport.amount, NSDecimalNumber(string: "-11.99"))
                XCTAssertNil(thirdReport.budget)
                XCTAssertEqual(thirdReport.average, NSDecimalNumber(string: "-7.99"))
                XCTAssertEqual(thirdReport.previous, NSDecimalNumber(string: "-11.99"))
                XCTAssertEqual(thirdReport.budgetCategory, .lifestyle)
                XCTAssertEqual(thirdReport.linkedID, 64)
                XCTAssertEqual(thirdReport.name, "Entertainment/Recreation")
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            // Check for overall reports
            let overallLivingFetchRequest: NSFetchRequest<ReportTransactionCurrent> = ReportTransactionCurrent.fetchRequest()
            overallLivingFetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionCurrent.budgetCategoryRawValue) + " == %@ && " + #keyPath(ReportTransactionCurrent.linkedID) + " == -1 && " + #keyPath(ReportTransactionCurrent.groupingRawValue) + " == %@", argumentArray: [BudgetCategory.living.rawValue, ReportGrouping.transactionCategory.rawValue])
            overallLivingFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionCurrent.day), ascending: true)]
            
            do {
                let fetchedReports = try context.fetch(overallLivingFetchRequest)
                
                XCTAssertEqual(fetchedReports.count, 31)
                
                if let firstReport = fetchedReports.first {
                    XCTAssertEqual(firstReport.day, 1)
                    XCTAssertEqual(firstReport.amount, NSDecimalNumber(string: "-79.8"))
                    XCTAssertNil(firstReport.budget)
                    XCTAssertEqual(firstReport.average, NSDecimalNumber(string: "-53.2"))
                    XCTAssertEqual(firstReport.previous, NSDecimalNumber(string: "-79.8"))
                    XCTAssertEqual(firstReport.budgetCategory, .living)
                    XCTAssertEqual(firstReport.linkedID, -1)
                    XCTAssertNil(firstReport.name)
                } else {
                    XCTFail("Reports not found")
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            // Check for group reports
            let groupLivingFetchRequest: NSFetchRequest<ReportTransactionCurrent> = ReportTransactionCurrent.fetchRequest()
            groupLivingFetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionCurrent.day) + " == %ld && " + #keyPath(ReportTransactionCurrent.linkedID) + " != -1 &&  " + #keyPath(ReportTransactionCurrent.budgetCategoryRawValue) + " == %@ && " + #keyPath(ReportTransactionCurrent.groupingRawValue) + " == %@", argumentArray: [6, BudgetCategory.living.rawValue, ReportGrouping.transactionCategory.rawValue])
            groupLivingFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionCurrent.linkedID), ascending: true)]
            
            do {
                let fetchedGroupReports = try context.fetch(groupLivingFetchRequest)
                
                XCTAssertEqual(fetchedGroupReports.count, 6)
                
                let thirdReport = fetchedGroupReports[0]
                XCTAssertEqual(thirdReport.day, 6)
                XCTAssertEqual(thirdReport.amount, NSDecimalNumber(string: "0"))
                XCTAssertNil(thirdReport.budget)
                XCTAssertNil(thirdReport.average)
                XCTAssertNil(thirdReport.previous)
                XCTAssertEqual(thirdReport.budgetCategory, .living)
                XCTAssertEqual(thirdReport.linkedID, 61)
                XCTAssertEqual(thirdReport.name, "Automotive/Fuel")
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            // Check for overall reports
            let overallFetchRequest: NSFetchRequest<ReportTransactionCurrent> = ReportTransactionCurrent.fetchRequest()
            overallFetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionCurrent.budgetCategoryRawValue) + " == nil && " + #keyPath(ReportTransactionCurrent.linkedID) + " == -1 && " + #keyPath(ReportTransactionCurrent.groupingRawValue) + " == %@", argumentArray: [ReportGrouping.transactionCategory.rawValue])
            overallFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionCurrent.day), ascending: true)]
            
            do {
                let fetchedReports = try context.fetch(overallFetchRequest)
                
                XCTAssertEqual(fetchedReports.count, 31)
                
                if let firstReport = fetchedReports.first {
                    XCTAssertEqual(firstReport.day, 1)
                    XCTAssertEqual(firstReport.amount, NSDecimalNumber(string: "-187.8"))
                    XCTAssertNil(firstReport.budget)
                    XCTAssertEqual(firstReport.average, NSDecimalNumber(string: "-120.53"))
                    XCTAssertEqual(firstReport.previous, NSDecimalNumber(string: "-215.8"))
                    XCTAssertNil(firstReport.budgetCategory)
                    XCTAssertEqual(firstReport.linkedID, -1)
                    XCTAssertNil(firstReport.name)
                } else {
                    XCTFail("Reports not found")
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            // Check for group reports
            let groupFetchRequest: NSFetchRequest<ReportTransactionCurrent> = ReportTransactionCurrent.fetchRequest()
            groupFetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionCurrent.day) + " == %ld && " + #keyPath(ReportTransactionCurrent.linkedID) + " != -1 &&  " + #keyPath(ReportTransactionCurrent.budgetCategoryRawValue) + " == nil && " + #keyPath(ReportTransactionCurrent.groupingRawValue) + " == %@", argumentArray: [6, ReportGrouping.transactionCategory.rawValue])
            groupFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionCurrent.linkedID), ascending: true)]
            
            do {
                let fetchedGroupReports = try context.fetch(groupFetchRequest)
                
                XCTAssertEqual(fetchedGroupReports.count, 17)
                
                let thirdReport = fetchedGroupReports[0]
                XCTAssertEqual(thirdReport.day, 6)
                XCTAssertEqual(thirdReport.amount, NSDecimalNumber(string: "0"))
                XCTAssertNil(thirdReport.budget)
                XCTAssertNil(thirdReport.average)
                XCTAssertNil(thirdReport.previous)
                XCTAssertNil(thirdReport.budgetCategory)
                XCTAssertEqual(thirdReport.linkedID, 61)
                XCTAssertEqual(thirdReport.name, "Automotive/Fuel")
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            expectation5.fulfill()
        }
        
        wait(for: [expectation5], timeout: 10.0)
        OHHTTPStubs.removeAllStubs()
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
                    overallFetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionHistory.overall) + " == nil && " + #keyPath(ReportTransactionHistory.budgetCategoryRawValue) + " == nil && " + #keyPath(ReportTransactionHistory.periodRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.groupingRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.periodRawValue) + " == %@", argumentArray: [ReportTransactionHistory.Period.month.rawValue,  ReportGrouping.budgetCategory.rawValue, ReportTransactionHistory.Period.month.rawValue])
                    overallFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionHistory.dateString), ascending: true)]
                    
                    do {
                        let fetchedReports = try context.fetch(overallFetchRequest)
                        
                        XCTAssertEqual(fetchedReports.count, 12)
                        
                        if let firstReport = fetchedReports.first {
                            XCTAssertEqual(firstReport.dateString, "2018-01")
                            XCTAssertEqual(firstReport.value, NSDecimalNumber(string: "744.37"))
                            XCTAssertEqual(firstReport.budget, NSDecimalNumber(string: "11000"))
                            XCTAssertNil(firstReport.budgetCategory)
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
                    fetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionHistory.overall.dateString) + " == %@ && " + #keyPath(ReportTransactionHistory.budgetCategoryRawValue) + " == nil && " + #keyPath(ReportTransactionHistory.periodRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.groupingRawValue) + " == %@", argumentArray: ["2018-03", ReportTransactionHistory.Period.month.rawValue, ReportGrouping.budgetCategory.rawValue])
                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionHistory.linkedID), ascending: true)]
                    
                    do {
                        let fetchedReports = try context.fetch(fetchRequest)
                        
                        XCTAssertEqual(fetchedReports.count, 4)
                        
                        if let firstReport = fetchedReports.first {
                            XCTAssertEqual(firstReport.dateString, "2018-03")
                            XCTAssertEqual(firstReport.value, NSDecimalNumber(string: "3250"))
                            XCTAssertEqual(firstReport.budget, NSDecimalNumber(string: "4050"))
                            XCTAssertNil(firstReport.budgetCategory)
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
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + ReportsEndpoint.transactionsHistory.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_reports_history_merchant_monthly_2018-01-01_2018-12-31", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
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
            
            reports.refreshTransactionHistoryReports(grouping: .merchant, period: .month, from: fromDate, to: toDate) { (error) in
                XCTAssertNil(error)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    let context = database.viewContext
                    
                    // Check for overall reports
                    let overallFetchRequest: NSFetchRequest<ReportTransactionHistory> = ReportTransactionHistory.fetchRequest()
                    overallFetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionHistory.overall) + " == nil && " + #keyPath(ReportTransactionHistory.budgetCategoryRawValue) + " == nil && " + #keyPath(ReportTransactionHistory.periodRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.groupingRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.periodRawValue) + " == %@", argumentArray: [ReportTransactionHistory.Period.month.rawValue, ReportGrouping.merchant.rawValue, ReportTransactionHistory.Period.month.rawValue])
                    overallFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionHistory.dateString), ascending: true)]
                    
                    do {
                        let fetchedReports = try context.fetch(overallFetchRequest)
                        
                        XCTAssertEqual(fetchedReports.count, 12)
                        
                        if let firstReport = fetchedReports.first {
                            XCTAssertEqual(firstReport.dateString, "2018-01")
                            XCTAssertEqual(firstReport.value, NSDecimalNumber(string: "744.37"))
                            XCTAssertNil(firstReport.budget)
                            XCTAssertNil(firstReport.budgetCategory)
                            XCTAssertNil(firstReport.overall)
                            XCTAssertNotNil(firstReport.reports)
                            XCTAssertEqual(firstReport.reports?.count, 15)
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
                    fetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionHistory.overall.dateString) + " == %@ && " + #keyPath(ReportTransactionHistory.budgetCategoryRawValue) + " == nil && " + #keyPath(ReportTransactionHistory.periodRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.groupingRawValue) + " == %@", argumentArray: ["2018-03", ReportTransactionHistory.Period.month.rawValue, ReportGrouping.merchant.rawValue])
                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionHistory.linkedID), ascending: true)]
                    
                    do {
                        let fetchedReports = try context.fetch(fetchRequest)
                        
                        XCTAssertEqual(fetchedReports.count, 22)
                        
                        if let firstReport = fetchedReports.last {
                            XCTAssertEqual(firstReport.dateString, "2018-03")
                            XCTAssertEqual(firstReport.value, NSDecimalNumber(string: "-127"))
                            XCTAssertNil(firstReport.budget)
                            XCTAssertNil(firstReport.budgetCategory)
                            XCTAssertNotNil(firstReport.overall)
                            XCTAssertEqual(firstReport.overall?.dateString, "2018-03")
                            XCTAssertNotNil(firstReport.reports)
                            XCTAssertEqual(firstReport.reports?.count, 0)
                            XCTAssertEqual(firstReport.linkedID, 292)
                            XCTAssertEqual(firstReport.name, "SUSHI PTY. LTD.")
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
    
    func testFetchingHistoryReportsByTransactionCategoryDaily() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + ReportsEndpoint.transactionsHistory.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_reports_history_txn_category_daily_2018-01-01_2018-12-31", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
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
            
            reports.refreshTransactionHistoryReports(grouping: .transactionCategory, period: .day, from: fromDate, to: toDate) { (error) in
                XCTAssertNil(error)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    let context = database.viewContext
                    
                    // Check for overall reports
                    let overallFetchRequest: NSFetchRequest<ReportTransactionHistory> = ReportTransactionHistory.fetchRequest()
                    overallFetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionHistory.overall) + " == nil && " + #keyPath(ReportTransactionHistory.budgetCategoryRawValue) + " == nil && " + #keyPath(ReportTransactionHistory.periodRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.groupingRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.periodRawValue) + " == %@", argumentArray: [ReportTransactionHistory.Period.day.rawValue, ReportGrouping.transactionCategory.rawValue, ReportTransactionHistory.Period.day.rawValue])
                    overallFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionHistory.dateString), ascending: true)]
                    
                    do {
                        let fetchedReports = try context.fetch(overallFetchRequest)
                        
                        XCTAssertEqual(fetchedReports.count, 365)
                        
                        if let firstReport = fetchedReports.last {
                            XCTAssertEqual(firstReport.dateString, "2018-12-31")
                            XCTAssertEqual(firstReport.value, NSDecimalNumber(string: "-84.6"))
                            XCTAssertNil(firstReport.budget)
                            XCTAssertNil(firstReport.budgetCategory)
                            XCTAssertNil(firstReport.overall)
                            XCTAssertNotNil(firstReport.reports)
                            XCTAssertEqual(firstReport.reports?.count, 3)
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
                    fetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionHistory.overall.dateString) + " == %@ && " + #keyPath(ReportTransactionHistory.budgetCategoryRawValue) + " == nil && " + #keyPath(ReportTransactionHistory.periodRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.groupingRawValue) + " == %@", argumentArray: ["2018-06-02", ReportTransactionHistory.Period.day.rawValue, ReportGrouping.transactionCategory.rawValue])
                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionHistory.linkedID), ascending: true)]
                    
                    do {
                        let fetchedReports = try context.fetch(fetchRequest)
                        
                        XCTAssertEqual(fetchedReports.count, 2)
                        
                        if let firstReport = fetchedReports.first {
                            XCTAssertEqual(firstReport.dateString, "2018-06-02")
                            XCTAssertEqual(firstReport.value, NSDecimalNumber(string: "-12.6"))
                            XCTAssertNil(firstReport.budget)
                            XCTAssertNil(firstReport.budgetCategory)
                            XCTAssertNotNil(firstReport.overall)
                            XCTAssertEqual(firstReport.overall?.dateString, "2018-06-02")
                            XCTAssertNotNil(firstReport.reports)
                            XCTAssertEqual(firstReport.reports?.count, 0)
                            XCTAssertEqual(firstReport.linkedID, 66)
                            XCTAssertEqual(firstReport.name, "Groceries")
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
    
    func testFetchingHistoryReportsByTransactionCategoryMonthly() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + ReportsEndpoint.transactionsHistory.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_reports_history_txn_category_monthly_2018-01-01_2018-12-31", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
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
            
            reports.refreshTransactionHistoryReports(grouping: .transactionCategory, period: .month, from: fromDate, to: toDate) { (error) in
                XCTAssertNil(error)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    let context = database.viewContext
                    
                    // Check for overall reports
                    let overallFetchRequest: NSFetchRequest<ReportTransactionHistory> = ReportTransactionHistory.fetchRequest()
                    overallFetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionHistory.overall) + " == nil && " + #keyPath(ReportTransactionHistory.budgetCategoryRawValue) + " == nil && " + #keyPath(ReportTransactionHistory.periodRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.groupingRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.periodRawValue) + " == %@", argumentArray: [ReportTransactionHistory.Period.month.rawValue, ReportGrouping.transactionCategory.rawValue, ReportTransactionHistory.Period.month.rawValue])
                    overallFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionHistory.dateString), ascending: true)]
                    
                    do {
                        let fetchedReports = try context.fetch(overallFetchRequest)
                        
                        XCTAssertEqual(fetchedReports.count, 12)
                        
                        let thirdReport = fetchedReports[2]

                        XCTAssertEqual(thirdReport.dateString, "2018-03")
                        XCTAssertEqual(thirdReport.value, NSDecimalNumber(string: "563.17"))
                        XCTAssertNil(thirdReport.budget)
                        XCTAssertNil(thirdReport.budgetCategory)
                        XCTAssertNil(thirdReport.overall)
                        XCTAssertNotNil(thirdReport.reports)
                        XCTAssertEqual(thirdReport.reports?.count, 15)
                        XCTAssertEqual(thirdReport.linkedID, -1)
                        XCTAssertNil(thirdReport.name)
                    } catch {
                        XCTFail(error.localizedDescription)
                    }
                    
                    // Check for group reports
                    let fetchRequest: NSFetchRequest<ReportTransactionHistory> = ReportTransactionHistory.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionHistory.overall.dateString) + " == %@ && " + #keyPath(ReportTransactionHistory.budgetCategoryRawValue) + " == nil && " + #keyPath(ReportTransactionHistory.periodRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.groupingRawValue) + " == %@", argumentArray: ["2018-05", ReportTransactionHistory.Period.month.rawValue, ReportGrouping.transactionCategory.rawValue])
                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionHistory.linkedID), ascending: true)]
                    
                    do {
                        let fetchedReports = try context.fetch(fetchRequest)
                        
                        XCTAssertEqual(fetchedReports.count, 15)
                        
                        if let firstReport = fetchedReports.first {
                            XCTAssertEqual(firstReport.dateString, "2018-05")
                            XCTAssertEqual(firstReport.value, NSDecimalNumber(string: "-29.98"))
                            XCTAssertNil(firstReport.budget)
                            XCTAssertNil(firstReport.budgetCategory)
                            XCTAssertNotNil(firstReport.overall)
                            XCTAssertEqual(firstReport.overall?.dateString, "2018-05")
                            XCTAssertNotNil(firstReport.reports)
                            XCTAssertEqual(firstReport.reports?.count, 0)
                            XCTAssertEqual(firstReport.linkedID, 64)
                            XCTAssertEqual(firstReport.name, "Entertainment/Recreation")
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
    
    func testFetchingHistoryReportsByTransactionCategoryWeekly() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + ReportsEndpoint.transactionsHistory.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_reports_history_txn_category_weekly_2018-01-01_2018-12-31", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
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
            
            reports.refreshTransactionHistoryReports(grouping: .transactionCategory, period: .week, from: fromDate, to: toDate) { (error) in
                XCTAssertNil(error)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    let context = database.viewContext
                    
                    // Check for overall reports
                    let overallFetchRequest: NSFetchRequest<ReportTransactionHistory> = ReportTransactionHistory.fetchRequest()
                    overallFetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionHistory.overall) + " == nil && " + #keyPath(ReportTransactionHistory.budgetCategoryRawValue) + " == nil && " + #keyPath(ReportTransactionHistory.periodRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.groupingRawValue) + " == %@", argumentArray: [ReportTransactionHistory.Period.week.rawValue, ReportGrouping.transactionCategory.rawValue])
                    overallFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionHistory.dateString), ascending: true)]
                    
                    do {
                        let fetchedReports = try context.fetch(overallFetchRequest)
                        
                        XCTAssertEqual(fetchedReports.count, 59)
                        
                        if let firstReport = fetchedReports.last {
                            XCTAssertEqual(firstReport.dateString, "2018-12-5")
                            XCTAssertEqual(firstReport.value, NSDecimalNumber(string: "-577.6"))
                            XCTAssertNil(firstReport.budget)
                            XCTAssertNil(firstReport.budgetCategory)
                            XCTAssertNil(firstReport.overall)
                            XCTAssertNotNil(firstReport.reports)
                            XCTAssertEqual(firstReport.reports?.count, 6)
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
                    fetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionHistory.overall.dateString) + " == %@ && " + #keyPath(ReportTransactionHistory.budgetCategoryRawValue) + " == nil && " + #keyPath(ReportTransactionHistory.periodRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.groupingRawValue) + " == %@", argumentArray: ["2018-12-5", ReportTransactionHistory.Period.week.rawValue, ReportGrouping.transactionCategory.rawValue])
                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionHistory.linkedID), ascending: true)]
                    
                    do {
                        let fetchedReports = try context.fetch(fetchRequest)
                        
                        XCTAssertEqual(fetchedReports.count, 6)
                        
                        if let firstReport = fetchedReports.first {
                            XCTAssertEqual(firstReport.dateString, "2018-12-5")
                            XCTAssertEqual(firstReport.value, NSDecimalNumber(string: "-12.6"))
                            XCTAssertNil(firstReport.budget)
                            XCTAssertNil(firstReport.budgetCategory)
                            XCTAssertNotNil(firstReport.overall)
                            XCTAssertEqual(firstReport.overall?.dateString, "2018-12-5")
                            XCTAssertNotNil(firstReport.reports)
                            XCTAssertEqual(firstReport.reports?.count, 0)
                            XCTAssertEqual(firstReport.linkedID, 66)
                            XCTAssertEqual(firstReport.name, "Groceries")
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
    
    func testFetchingHistoryReportsFilteredByBudgetCategory() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + ReportsEndpoint.transactionsHistory.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_reports_history_txn_category_monthly_lifestyle_2018-01-01_2018-12-31", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
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
            
            reports.refreshTransactionHistoryReports(grouping: .transactionCategory, period: .month, from: fromDate, to: toDate, budgetCategory: .lifestyle) { (error) in
                XCTAssertNil(error)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    let context = database.viewContext
                    
                    // Check for overall reports
                    let overallFetchRequest: NSFetchRequest<ReportTransactionHistory> = ReportTransactionHistory.fetchRequest()
                    overallFetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionHistory.overall) + " == nil && " + #keyPath(ReportTransactionHistory.budgetCategoryRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.periodRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.groupingRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.periodRawValue) + " == %@", argumentArray: [BudgetCategory.lifestyle.rawValue, ReportTransactionHistory.Period.month.rawValue, ReportGrouping.transactionCategory.rawValue, ReportTransactionHistory.Period.month.rawValue])
                    overallFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionHistory.dateString), ascending: true)]
                    
                    do {
                        let fetchedReports = try context.fetch(overallFetchRequest)
                        
                        XCTAssertEqual(fetchedReports.count, 12)
                        
                        let thirdReport = fetchedReports[4]
                        
                        XCTAssertEqual(thirdReport.dateString, "2018-05")
                        XCTAssertEqual(thirdReport.value, NSDecimalNumber(string: "-778.93"))
                        XCTAssertNil(thirdReport.budget)
                        XCTAssertNil(thirdReport.overall)
                        XCTAssertNotNil(thirdReport.reports)
                        XCTAssertEqual(thirdReport.reports?.count, 7)
                        XCTAssertEqual(thirdReport.linkedID, -1)
                        XCTAssertEqual(thirdReport.budgetCategory, .lifestyle)
                        XCTAssertNil(thirdReport.name)
                    } catch {
                        XCTFail(error.localizedDescription)
                    }
                    
                    // Check for group reports
                    let fetchRequest: NSFetchRequest<ReportTransactionHistory> = ReportTransactionHistory.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionHistory.overall.dateString) + " == %@ && " + #keyPath(ReportTransactionHistory.budgetCategoryRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.periodRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.groupingRawValue) + " == %@", argumentArray: ["2018-05", BudgetCategory.lifestyle.rawValue, ReportTransactionHistory.Period.month.rawValue, ReportGrouping.transactionCategory.rawValue])
                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionHistory.linkedID), ascending: true)]
                    
                    do {
                        let fetchedReports = try context.fetch(fetchRequest)
                        
                        XCTAssertEqual(fetchedReports.count, 7)
                        
                        if let firstReport = fetchedReports.last {
                            XCTAssertEqual(firstReport.dateString, "2018-05")
                            XCTAssertEqual(firstReport.value, NSDecimalNumber(string: "-40"))
                            XCTAssertNil(firstReport.budget)
                            XCTAssertEqual(firstReport.budgetCategory, .lifestyle)
                            XCTAssertNotNil(firstReport.overall)
                            XCTAssertEqual(firstReport.overall?.dateString, "2018-05")
                            XCTAssertNotNil(firstReport.reports)
                            XCTAssertEqual(firstReport.reports?.count, 0)
                            XCTAssertEqual(firstReport.linkedID, 94)
                            XCTAssertEqual(firstReport.name, "Electronics/General Merchandise")
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
    
    func testFetchingHistoryReportsUpdatesExisting() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + ReportsEndpoint.transactionsHistory.path)) { (request) -> OHHTTPStubsResponse in
            if let requestURL = request.url, let queryItems = URLComponents(url: requestURL, resolvingAgainstBaseURL: true)?.queryItems {
                var fromDate: String = ""
                
                for queryItem in queryItems {
                    if queryItem.name == "from_date", let value = queryItem.value {
                        fromDate = value
                    }
                }
                
                if fromDate == "2018-01-01" {
                    return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_reports_history_txn_category_monthly_2018-01-01_2018-12-31", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
                } else if fromDate == "2018-03-01" {
                    return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_reports_history_txn_category_monthly_2018-03_01_2019-03-31", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
                }
            }
            
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_reports_history_txn_category_monthly_2018-01-01_2018-12-31", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, network: network)
            let reports = Reports(database: database, network: network, aggregation: aggregation)
            
            let oldFromDate = ReportTransactionHistory.dailyDateFormatter.date(from: "2018-01-01")!
            let oldToDate = ReportTransactionHistory.dailyDateFormatter.date(from: "2018-12-31")!
            
            reports.refreshTransactionHistoryReports(grouping: .transactionCategory, period: .month, from: oldFromDate, to: oldToDate) { (error) in
                XCTAssertNil(error)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    let context = database.viewContext
                    
                    let overallOldFetchRequest: NSFetchRequest<ReportTransactionHistory> = ReportTransactionHistory.fetchRequest()
                    overallOldFetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionHistory.overall) + " == nil && " + #keyPath(ReportTransactionHistory.dateString) + " == %@ && " + #keyPath(ReportTransactionHistory.budgetCategoryRawValue) + " == nil && " + #keyPath(ReportTransactionHistory.periodRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.groupingRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.periodRawValue) + " == %@", argumentArray: ["2018-01", ReportTransactionHistory.Period.month.rawValue, ReportGrouping.transactionCategory.rawValue, ReportTransactionHistory.Period.month.rawValue])
                    overallOldFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionHistory.dateString), ascending: true)]
                    
                    let overallNewFetchRequest: NSFetchRequest<ReportTransactionHistory> = ReportTransactionHistory.fetchRequest()
                    overallNewFetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionHistory.overall) + " == nil && " + #keyPath(ReportTransactionHistory.dateString) + " == %@ && " + #keyPath(ReportTransactionHistory.budgetCategoryRawValue) + " == nil && " + #keyPath(ReportTransactionHistory.periodRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.groupingRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.periodRawValue) + " == %@", argumentArray: ["2019-01", ReportTransactionHistory.Period.month.rawValue, ReportGrouping.transactionCategory.rawValue, ReportTransactionHistory.Period.month.rawValue])
                    
                    let groupNewFetchRequest: NSFetchRequest<ReportTransactionHistory> = ReportTransactionHistory.fetchRequest()
                    groupNewFetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionHistory.overall.dateString) + " == %@ && " + #keyPath(ReportTransactionHistory.budgetCategoryRawValue) + " == nil && " + #keyPath(ReportTransactionHistory.periodRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.groupingRawValue) + " == %@", argumentArray: ["2019-01", ReportTransactionHistory.Period.month.rawValue, ReportGrouping.transactionCategory.rawValue])
                    groupNewFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionHistory.linkedID), ascending: true)]
                    
                    let groupOldFetchRequest: NSFetchRequest<ReportTransactionHistory> = ReportTransactionHistory.fetchRequest()
                    groupOldFetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionHistory.overall.dateString) + " == %@ && " + #keyPath(ReportTransactionHistory.budgetCategoryRawValue) + " == nil && " + #keyPath(ReportTransactionHistory.periodRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.groupingRawValue) + " == %@", argumentArray: ["2018-01", ReportTransactionHistory.Period.month.rawValue, ReportGrouping.transactionCategory.rawValue])
                    groupOldFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionHistory.linkedID), ascending: true)]
                    
                    // Check for old overall report
                    do {
                        let fetchedOldOverallReports = try context.fetch(overallOldFetchRequest)
                        
                        XCTAssertEqual(fetchedOldOverallReports.count, 1)
                        
                        if let firstReport = fetchedOldOverallReports.first {
                            XCTAssertEqual(firstReport.dateString, "2018-01")
                            XCTAssertNil(firstReport.overall)
                            XCTAssertNotNil(firstReport.reports)
                            XCTAssertEqual(firstReport.reports?.count, 12)
                        } else {
                            XCTFail("Report not found")
                        }
                    } catch {
                        XCTFail(error.localizedDescription)
                    }
                    
                    // Check for old group report
                    do {
                        let fetchedOldGroupReports = try context.fetch(groupOldFetchRequest)
                        
                        XCTAssertEqual(fetchedOldGroupReports.count, 12)
                        
                        if let firstReport = fetchedOldGroupReports.first {
                            XCTAssertEqual(firstReport.dateString, "2018-01")
                            XCTAssertNotNil(firstReport.overall)
                            XCTAssertEqual(firstReport.overall?.dateString, "2018-01")
                            XCTAssertNotNil(firstReport.reports)
                            XCTAssertEqual(firstReport.reports?.count, 0)
                        } else {
                            XCTFail("Reports not found")
                        }
                    } catch {
                        XCTFail(error.localizedDescription)
                    }
                    
                    // Check no new overall report is found
                    do {
                        let fetchedOverallNewReports = try context.fetch(overallNewFetchRequest)
                        
                        XCTAssertEqual(fetchedOverallNewReports.count, 0)
                        XCTAssertNil(fetchedOverallNewReports.first)
                    } catch {
                        XCTFail(error.localizedDescription)
                    }
                    
                    // Check no new group report is found
                    do {
                        let fetchedGroupNewReports = try context.fetch(groupNewFetchRequest)
                        
                        XCTAssertEqual(fetchedGroupNewReports.count, 0)
                        XCTAssertNil(fetchedGroupNewReports.first)
                    } catch {
                        XCTFail(error.localizedDescription)
                    }
                    
                    // Fetch more recent reports
                    let newFromDate = ReportTransactionHistory.dailyDateFormatter.date(from: "2018-03-01")!
                    let newToDate = ReportTransactionHistory.dailyDateFormatter.date(from: "2019-03-31")!
                    
                    reports.refreshTransactionHistoryReports(grouping: .transactionCategory, period: .month, from: newFromDate, to: newToDate) { (error) in
                        XCTAssertNil(error)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            let context = database.viewContext
                            
                            // Check for old overall report
                            do {
                                let fetchedOldOverallReports = try context.fetch(overallOldFetchRequest)
                                
                                XCTAssertEqual(fetchedOldOverallReports.count, 1)
                                
                                if let firstReport = fetchedOldOverallReports.first {
                                    XCTAssertEqual(firstReport.dateString, "2018-01")
                                    XCTAssertNil(firstReport.overall)
                                    XCTAssertNotNil(firstReport.reports)
                                    XCTAssertEqual(firstReport.reports?.count, 12)
                                } else {
                                    XCTFail("Report not found")
                                }
                            } catch {
                                XCTFail(error.localizedDescription)
                            }
                            
                            // Check for old group report
                            do {
                                let fetchedOldGroupReports = try context.fetch(groupOldFetchRequest)
                                
                                XCTAssertEqual(fetchedOldGroupReports.count, 12)
                                
                                if let firstReport = fetchedOldGroupReports.first {
                                    XCTAssertEqual(firstReport.dateString, "2018-01")
                                    XCTAssertNotNil(firstReport.overall)
                                    XCTAssertEqual(firstReport.overall?.dateString, "2018-01")
                                    XCTAssertNotNil(firstReport.reports)
                                    XCTAssertEqual(firstReport.reports?.count, 0)
                                } else {
                                    XCTFail("Reports not found")
                                }
                            } catch {
                                XCTFail(error.localizedDescription)
                            }
                            
                            // Check no new overall report is found
                            do {
                                let fetchedOldOverallReports = try context.fetch(overallNewFetchRequest)
                                
                                XCTAssertEqual(fetchedOldOverallReports.count, 1)
                                
                                if let firstReport = fetchedOldOverallReports.first {
                                    XCTAssertEqual(firstReport.dateString, "2019-01")
                                    XCTAssertNil(firstReport.overall)
                                    XCTAssertNotNil(firstReport.reports)
                                    XCTAssertEqual(firstReport.reports?.count, 12)
                                } else {
                                    XCTFail("Report not found")
                                }
                            } catch {
                                XCTFail(error.localizedDescription)
                            }
                            
                            // Check no new group report is found
                            do {
                                let fetchedOldGroupReports = try context.fetch(groupNewFetchRequest)
                                
                                XCTAssertEqual(fetchedOldGroupReports.count, 12)
                                
                                if let firstReport = fetchedOldGroupReports.first {
                                    XCTAssertEqual(firstReport.dateString, "2019-01")
                                    XCTAssertNotNil(firstReport.overall)
                                    XCTAssertEqual(firstReport.overall?.dateString, "2019-01")
                                    XCTAssertNotNil(firstReport.reports)
                                    XCTAssertEqual(firstReport.reports?.count, 0)
                                } else {
                                    XCTFail("Reports not found")
                                }
                            } catch {
                                XCTFail(error.localizedDescription)
                            }
                        }
                    }
                    
                    expectation1.fulfill()
                }
            }
        }
        
        wait(for: [expectation1], timeout: 10.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testFetchingHistoryReportsCommingling() {
        let expectation1 = expectation(description: "Database setup")
        let expectation2 = expectation(description: "Network Request 1")
        let expectation3 = expectation(description: "Network Request 2")
        let expectation4 = expectation(description: "Network Request 3")
        let expectation5 = expectation(description: "Fetch")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + ReportsEndpoint.transactionsHistory.path)) { (request) -> OHHTTPStubsResponse in
            if let requestURL = request.url, let queryItems = URLComponents(url: requestURL, resolvingAgainstBaseURL: true)?.queryItems {
                var budgetCategory: String = ""
                
                for queryItem in queryItems {
                    if queryItem.name == "budget_category", let value = queryItem.value {
                        budgetCategory = value
                    }
                }
                
                if budgetCategory == "living" {
                    return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_reports_history_txn_category_monthly_living_2018-01-01_2018-12-31", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
                } else if budgetCategory == "lifestyle" {
                    return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_reports_history_txn_category_monthly_lifestyle_2018-01-01_2018-12-31", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
                }
            }
            
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_reports_history_txn_category_monthly_2018-01-01_2018-12-31", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
            
        let aggregation = Aggregation(database: database, network: network)
        let reports = Reports(database: database, network: network, aggregation: aggregation)
        
        let fromDate = ReportTransactionHistory.dailyDateFormatter.date(from: "2018-01-01")!
        let toDate = ReportTransactionHistory.dailyDateFormatter.date(from: "2018-12-31")!
        
        reports.refreshTransactionHistoryReports(grouping: .transactionCategory, period: .month, from: fromDate, to: toDate, budgetCategory: .living) { (error) in
            XCTAssertNil(error)
            
            expectation2.fulfill()
        }
        
        reports.refreshTransactionHistoryReports(grouping: .transactionCategory, period: .month, from: fromDate, to: toDate, budgetCategory: .lifestyle) { (error) in
            XCTAssertNil(error)
            
            expectation3.fulfill()
        }
        
        reports.refreshTransactionHistoryReports(grouping: .transactionCategory, period: .month, from: fromDate, to: toDate, budgetCategory: nil) { (error) in
            XCTAssertNil(error)
            
            expectation4.fulfill()
        }
        
        wait(for: [expectation2, expectation3, expectation4], timeout: 5.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let context = database.viewContext
            
            // Check for overall lifestyle reports
            let overallLifestyleFetchRequest: NSFetchRequest<ReportTransactionHistory> = ReportTransactionHistory.fetchRequest()
            overallLifestyleFetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionHistory.overall) + " == nil && " + #keyPath(ReportTransactionHistory.budgetCategoryRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.periodRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.groupingRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.periodRawValue) + " == %@", argumentArray: [BudgetCategory.lifestyle.rawValue, ReportTransactionHistory.Period.month.rawValue, ReportGrouping.transactionCategory.rawValue, ReportTransactionHistory.Period.month.rawValue])
            overallLifestyleFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionHistory.dateString), ascending: true)]
            
            do {
                let fetchedReports = try context.fetch(overallLifestyleFetchRequest)
                
                XCTAssertEqual(fetchedReports.count, 12)
                
                let thirdReport = fetchedReports[4]
                
                XCTAssertEqual(thirdReport.dateString, "2018-05")
                XCTAssertEqual(thirdReport.value, NSDecimalNumber(string: "-778.93"))
                XCTAssertNil(thirdReport.budget)
                XCTAssertNil(thirdReport.overall)
                XCTAssertNotNil(thirdReport.reports)
                XCTAssertEqual(thirdReport.reports?.count, 7)
                XCTAssertEqual(thirdReport.linkedID, -1)
                XCTAssertEqual(thirdReport.budgetCategory, .lifestyle)
                XCTAssertNil(thirdReport.name)
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            // Check for group lifestyle reports
            let groupLifestyleFetchRequest: NSFetchRequest<ReportTransactionHistory> = ReportTransactionHistory.fetchRequest()
            groupLifestyleFetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionHistory.overall.dateString) + " == %@ && " + #keyPath(ReportTransactionHistory.budgetCategoryRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.periodRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.groupingRawValue) + " == %@", argumentArray: ["2018-05", BudgetCategory.lifestyle.rawValue, ReportTransactionHistory.Period.month.rawValue, ReportGrouping.transactionCategory.rawValue])
            groupLifestyleFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionHistory.linkedID), ascending: true)]
            
            do {
                let fetchedReports = try context.fetch(groupLifestyleFetchRequest)
                
                XCTAssertEqual(fetchedReports.count, 7)
                
                if let firstReport = fetchedReports.last {
                    XCTAssertEqual(firstReport.dateString, "2018-05")
                    XCTAssertEqual(firstReport.value, NSDecimalNumber(string: "-40"))
                    XCTAssertNil(firstReport.budget)
                    XCTAssertEqual(firstReport.budgetCategory, .lifestyle)
                    XCTAssertNotNil(firstReport.overall)
                    XCTAssertEqual(firstReport.overall?.dateString, "2018-05")
                    XCTAssertNotNil(firstReport.reports)
                    XCTAssertEqual(firstReport.reports?.count, 0)
                    XCTAssertEqual(firstReport.linkedID, 94)
                    XCTAssertEqual(firstReport.name, "Electronics/General Merchandise")
                } else {
                    XCTFail("Reports not found")
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            // Check for overall living reports
            let overallLivingFetchRequest: NSFetchRequest<ReportTransactionHistory> = ReportTransactionHistory.fetchRequest()
            overallLivingFetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionHistory.overall) + " == nil && " + #keyPath(ReportTransactionHistory.budgetCategoryRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.periodRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.groupingRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.periodRawValue) + " == %@", argumentArray: [BudgetCategory.living.rawValue, ReportTransactionHistory.Period.month.rawValue, ReportGrouping.transactionCategory.rawValue, ReportTransactionHistory.Period.month.rawValue])
            overallLivingFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionHistory.dateString), ascending: true), NSSortDescriptor(key: #keyPath(ReportTransactionHistory.linkedID), ascending: true)]
            
            do {
                let fetchedReports = try context.fetch(overallLivingFetchRequest)
                
                XCTAssertEqual(fetchedReports.count, 12)
                
                let thirdReport = fetchedReports[4]
                
                XCTAssertEqual(thirdReport.dateString, "2018-05")
                XCTAssertEqual(thirdReport.value, NSDecimalNumber(string: "-1569.45"))
                XCTAssertNil(thirdReport.budget)
                XCTAssertNil(thirdReport.overall)
                XCTAssertNotNil(thirdReport.reports)
                XCTAssertEqual(thirdReport.reports?.count, 5)
                XCTAssertEqual(thirdReport.linkedID, -1)
                XCTAssertEqual(thirdReport.budgetCategory, .living)
                XCTAssertNil(thirdReport.name)
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            // Check for group living reports
            let groupLivingFetchRequest: NSFetchRequest<ReportTransactionHistory> = ReportTransactionHistory.fetchRequest()
            groupLivingFetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionHistory.overall.dateString) + " == %@ && " + #keyPath(ReportTransactionHistory.budgetCategoryRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.periodRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.groupingRawValue) + " == %@", argumentArray: ["2018-05", BudgetCategory.living.rawValue, ReportTransactionHistory.Period.month.rawValue, ReportGrouping.transactionCategory.rawValue])
            groupLivingFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionHistory.linkedID), ascending: true)]
            
            do {
                let fetchedReports = try context.fetch(groupLivingFetchRequest)
                
                XCTAssertEqual(fetchedReports.count, 5)
                
                if let firstReport = fetchedReports.first {
                    XCTAssertEqual(firstReport.dateString, "2018-05")
                    XCTAssertEqual(firstReport.value, NSDecimalNumber(string: "-569.55"))
                    XCTAssertNil(firstReport.budget)
                    XCTAssertEqual(firstReport.budgetCategory, .living)
                    XCTAssertNotNil(firstReport.overall)
                    XCTAssertEqual(firstReport.overall?.dateString, "2018-05")
                    XCTAssertNotNil(firstReport.reports)
                    XCTAssertEqual(firstReport.reports?.count, 0)
                    XCTAssertEqual(firstReport.linkedID, 66)
                    XCTAssertEqual(firstReport.name, "Groceries")
                } else {
                    XCTFail("Reports not found")
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            // Check for overall general reports
            let overallFetchRequest: NSFetchRequest<ReportTransactionHistory> = ReportTransactionHistory.fetchRequest()
            overallFetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionHistory.overall) + " == nil && " + #keyPath(ReportTransactionHistory.budgetCategoryRawValue) + " == nil && " + #keyPath(ReportTransactionHistory.periodRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.groupingRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.periodRawValue) + " == %@", argumentArray: [ReportTransactionHistory.Period.month.rawValue, ReportGrouping.transactionCategory.rawValue, ReportTransactionHistory.Period.month.rawValue])
            overallFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionHistory.dateString), ascending: true), NSSortDescriptor(key: #keyPath(ReportTransactionHistory.linkedID), ascending: true)]
            
            do {
                let fetchedReports = try context.fetch(overallFetchRequest)
                
                XCTAssertEqual(fetchedReports.count, 12)
                
                let thirdReport = fetchedReports[4]
                
                XCTAssertEqual(thirdReport.dateString, "2018-05")
                XCTAssertEqual(thirdReport.value, NSDecimalNumber(string: "671.62"))
                XCTAssertNil(thirdReport.budget)
                XCTAssertNil(thirdReport.overall)
                XCTAssertNotNil(thirdReport.reports)
                XCTAssertEqual(thirdReport.reports?.count, 15)
                XCTAssertEqual(thirdReport.linkedID, -1)
                XCTAssertNil(thirdReport.budgetCategory)
                XCTAssertNil(thirdReport.name)
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            // Check for group general reports
            let groupFetchRequest: NSFetchRequest<ReportTransactionHistory> = ReportTransactionHistory.fetchRequest()
            groupFetchRequest.predicate = NSPredicate(format: #keyPath(ReportTransactionHistory.overall.dateString) + " == %@ && " + #keyPath(ReportTransactionHistory.budgetCategoryRawValue) + " == nil && " + #keyPath(ReportTransactionHistory.periodRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.groupingRawValue) + " == %@", argumentArray: ["2018-05", ReportTransactionHistory.Period.month.rawValue, ReportGrouping.transactionCategory.rawValue])
            groupFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportTransactionHistory.linkedID), ascending: true)]
            
            do {
                let fetchedReports = try context.fetch(groupFetchRequest)
                
                XCTAssertEqual(fetchedReports.count, 15)
                
                if let firstReport = fetchedReports.first {
                    XCTAssertEqual(firstReport.dateString, "2018-05")
                    XCTAssertEqual(firstReport.value, NSDecimalNumber(string: "-29.98"))
                    XCTAssertNil(firstReport.budget)
                    XCTAssertNil(firstReport.budgetCategory)
                    XCTAssertNotNil(firstReport.overall)
                    XCTAssertEqual(firstReport.overall?.dateString, "2018-05")
                    XCTAssertNotNil(firstReport.reports)
                    XCTAssertEqual(firstReport.reports?.count, 0)
                    XCTAssertEqual(firstReport.linkedID, 64)
                    XCTAssertEqual(firstReport.name, "Entertainment/Recreation")
                } else {
                    XCTFail("Reports not found")
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            expectation5.fulfill()
        }
        
        wait(for: [expectation5], timeout: 15.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testHistoryReportsLinkToMerchants() {
        let expectation1 = expectation(description: "Network Merchants Request")
        let expectation2 = expectation(description: "Network Reports Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + ReportsEndpoint.transactionsHistory.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_reports_history_merchant_monthly_2018-01-01_2018-12-31", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
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
            let reports = Reports(database: database, network: network, aggregation: aggregation)
            
            aggregation.refreshMerchants() { (error) in
                XCTAssertNil(error)
                
                let fromDate = ReportTransactionHistory.dailyDateFormatter.date(from: "2018-01-01")!
                let toDate = ReportTransactionHistory.dailyDateFormatter.date(from: "2018-12-31")!
                
                reports.refreshTransactionHistoryReports(grouping: .merchant, period: .month, from: fromDate, to: toDate) { (error) in
                    XCTAssertNil(error)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                        let context = database.viewContext
                        
                        let fetchRequest: NSFetchRequest<ReportTransactionHistory> = ReportTransactionHistory.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "linkedID == %ld", argumentArray: [97])
                        
                        do {
                            let fetchedReports = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedReports.count, 11)
                            
                            if let report = fetchedReports.first {
                                XCTAssertNotNil(report.merchant)
                                XCTAssertNil(report.transactionCategory)
                                
                                XCTAssertEqual(report.linkedID, report.merchant?.merchantID)
                            }
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                        
                        expectation2.fulfill()
                    })
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1, expectation2], timeout: 10.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testHistoryReportsLinkToTransactionCategories() {
        let expectation1 = expectation(description: "Network Merchants Request")
        let expectation2 = expectation(description: "Network Reports Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + ReportsEndpoint.transactionsHistory.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_reports_history_txn_category_monthly_2018-01-01_2018-12-31", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
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
            let reports = Reports(database: database, network: network, aggregation: aggregation)
            
            aggregation.refreshTransactionCategories() { (error) in
                XCTAssertNil(error)
                
                let fromDate = ReportTransactionHistory.dailyDateFormatter.date(from: "2018-01-01")!
                let toDate = ReportTransactionHistory.dailyDateFormatter.date(from: "2018-12-31")!
                
                reports.refreshTransactionHistoryReports(grouping: .transactionCategory, period: .month, from: fromDate, to: toDate) { (error) in
                    XCTAssertNil(error)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                        let context = database.viewContext
                        
                        let fetchRequest: NSFetchRequest<ReportTransactionHistory> = ReportTransactionHistory.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "linkedID == %ld", argumentArray: [79])
                        
                        do {
                            let fetchedReports = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedReports.count, 11)
                            
                            if let report = fetchedReports.first {
                                XCTAssertNotNil(report.transactionCategory)
                                XCTAssertNil(report.merchant)
                                
                                XCTAssertEqual(report.linkedID, report.transactionCategory?.transactionCategoryID)
                            }
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                        
                        expectation2.fulfill()
                    })
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1, expectation2], timeout: 5.0)
        OHHTTPStubs.removeAllStubs()
    }
    
}
