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
    
    func testFetchAccountBalanceReports() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + ReportsEndpoint.accountBalance.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "account_balance_reports_by_day_2018-10-29_2019-01-29", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        
        let fromDate = ReportAccountBalance.dailyDateFormatter.date(from: "2018-10-29")!
        let toDate = ReportAccountBalance.dailyDateFormatter.date(from: "2019-01-29")!
        
        network.fetchAccountBalanceReports(period: .day, from: fromDate, to: toDate) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.data.count, 94)
                    
                    if let firstReport = response.data.first {
                        XCTAssertEqual(firstReport.value, "90602.10")
                        XCTAssertEqual(firstReport.date, "2018-10-28")
                        
                        XCTAssertEqual(firstReport.accounts.count, 7)
                        
                        if let firstBalanceReport = firstReport.accounts.first {
                            XCTAssertEqual(firstBalanceReport.id, 542)
                            XCTAssertEqual(firstBalanceReport.currency, "AUD")
                            XCTAssertEqual(firstBalanceReport.value, "-1191.45")
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
    
    func testFetchTransactionCurrentReports() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + ReportsEndpoint.transactionsCurrent.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_reports_current_txn_category_living", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        
        network.fetchTransactionCurrentReports(grouping: .transactionCategory, budgetCategory: .living) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.days.count, 31)
                    
                    if let firstReport = response.days.first {
                        XCTAssertEqual(firstReport.day, 1)
                        XCTAssertEqual(firstReport.spendValue, "-79.80")
                        XCTAssertEqual(firstReport.previousPeriodValue, "-79.80")
                        XCTAssertEqual(firstReport.averageValue, "-53.20")
                        XCTAssertNil(firstReport.budgetValue)
                    } else {
                        XCTFail("No report")
                    }
                    
                    XCTAssertEqual(response.groups.count, 6)
                    
                    if let firstGroupReport = response.groups.first {
                        XCTAssertEqual(firstGroupReport.id, 70)
                        XCTAssertEqual(firstGroupReport.name, "Cable/Satellite/Telecom")
                        XCTAssertEqual(firstGroupReport.spendValue, "-219.80")
                        XCTAssertEqual(firstGroupReport.previousPeriodValue, "-219.80")
                        XCTAssertEqual(firstGroupReport.averageValue, "-219.80")
                        
                        XCTAssertEqual(firstGroupReport.days.count, 31)
                        
                        if let firstGroupDayReport = firstGroupReport.days.first {
                            XCTAssertEqual(firstGroupDayReport.day, 1)
                            XCTAssertEqual(firstGroupDayReport.spendValue, "-79.80")
                            XCTAssertEqual(firstGroupDayReport.previousPeriodValue, "-79.80")
                            XCTAssertEqual(firstGroupDayReport.averageValue, "-53.20")
                            XCTAssertNil(firstGroupDayReport.budgetValue)
                        } else {
                            XCTFail("No group day reports")
                        }
                    } else {
                        XCTFail("No group reports")
                    }
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 5.0)
    }

    func testFetchTransactionHistoryReports() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + ReportsEndpoint.transactionsHistory.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_reports_history_txn_category_monthly_2018-01-01_2018-12-31", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        
        let fromDate = ReportTransactionHistory.dailyDateFormatter.date(from: "2018-01-01")!
        let toDate = ReportTransactionHistory.dailyDateFormatter.date(from: "2018-12-31")!
        
        network.fetchTransactionHistoryReports(grouping: .budgetCategory, period: .month, fromDate: fromDate, toDate: toDate, budgetCategory: nil) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.data.count, 12)
                    
                    if let firstReport = response.data.first {
                        XCTAssertEqual(firstReport.value, "744.37")
                        XCTAssertEqual(firstReport.date, "2018-01")
                        
                        XCTAssertEqual(firstReport.groups.count, 12)
                        
                        if let firstGroupReport = firstReport.groups.first {
                            XCTAssertEqual(firstGroupReport.id, 64)
                            XCTAssertEqual(firstGroupReport.name, "Entertainment/Recreation")
                            XCTAssertEqual(firstGroupReport.value, "-17.99")
                            XCTAssertNil(firstGroupReport.budget)
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
