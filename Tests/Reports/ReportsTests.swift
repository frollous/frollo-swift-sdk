//
// Copyright © 2019 Frollo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
    
    // MARK: - Account Balance Report Tests
    
    func testFetchAccountBalanceReports() {
        let expectation1 = expectation(description: "Completion")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testReport1 = ReportAccountBalance(context: managedObjectContext)
                testReport1.populateTestData()
                testReport1.dateString = "2018-02-01"
                testReport1.period = .day
                
                let testReport2 = ReportAccountBalance(context: managedObjectContext)
                testReport2.populateTestData()
                testReport2.dateString = "2018-01"
                testReport2.period = .month
                
                let testReport3 = ReportAccountBalance(context: managedObjectContext)
                testReport3.populateTestData()
                testReport3.dateString = "2018-01-01"
                testReport3.period = .day
                
                let testReport4 = ReportAccountBalance(context: managedObjectContext)
                testReport4.populateTestData()
                testReport4.dateString = "2018-01-01"
                testReport4.period = .day
                
                try! managedObjectContext.save()
            }
            
            let aggregation = Aggregation(database: database, service: service)
            let reports = Reports(database: database, service: service, aggregation: aggregation)
            
            let fromDate = ReportAccountBalance.dailyDateFormatter.date(from: "2017-06-01")!
            let toDate = ReportAccountBalance.dailyDateFormatter.date(from: "2018-01-31")!
            
            let fetchedReports = reports.accountBalanceReports(context: database.viewContext, from: fromDate, to: toDate, period: .day)
            XCTAssertNotNil(fetchedReports)
            XCTAssertEqual(fetchedReports?.count, 2)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 5)
    }
    
    func testRefreshingAccountBalanceReportsFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + ReportsEndpoint.accountBalance.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "account_balance_reports_by_day_2018-10-29_2019-01-29", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication(valid: false)
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, service: service)
            let reports = Reports(database: database, service: service, aggregation: aggregation)
            
            let fromDate = ReportAccountBalance.dailyDateFormatter.date(from: "2018-10-29")!
            let toDate = ReportAccountBalance.dailyDateFormatter.date(from: "2019-01-29")!
            
            reports.refreshAccountBalanceReports(period: .day, from: fromDate, to: toDate) { (result) in
                switch result {
                    case .failure(let error):
                        XCTAssertNotNil(error)
                        
                        if let loggedOutError = error as? DataError {
                            XCTAssertEqual(loggedOutError.type, .authentication)
                            XCTAssertEqual(loggedOutError.subType, .missingAccessToken)
                        } else {
                            XCTFail("Wrong error type returned")
                        }
                    case .success:
                        XCTFail("User logged out, request should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 10.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testFetchingAccountBalanceReportsByDay() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + ReportsEndpoint.accountBalance.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "account_balance_reports_by_day_2018-10-29_2019-01-29", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, service: service)
            let reports = Reports(database: database, service: service, aggregation: aggregation)
            
            let fromDate = ReportAccountBalance.dailyDateFormatter.date(from: "2018-10-29")!
            let toDate = ReportAccountBalance.dailyDateFormatter.date(from: "2019-01-29")!
            
            reports.refreshAccountBalanceReports(period: .day, from: fromDate, to: toDate) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            let context = database.viewContext
                            
                            // Check for overall reports
                            let fetchRequest: NSFetchRequest<ReportAccountBalance> = ReportAccountBalance.fetchRequest()
                            fetchRequest.predicate = NSPredicate(format: #keyPath(ReportAccountBalance.periodRawValue) + " == %@", argumentArray: [ReportAccountBalance.Period.day.rawValue])
                            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportAccountBalance.dateString), ascending: true), NSSortDescriptor(key: #keyPath(ReportAccountBalance.accountID), ascending: true)]
                            
                            do {
                                let fetchedReports = try context.fetch(fetchRequest)
                                
                                XCTAssertEqual(fetchedReports.count, 661)
                                
                                if let firstReport = fetchedReports.first {
                                    XCTAssertEqual(firstReport.dateString, "2018-10-28")
                                    XCTAssertEqual(firstReport.accountID, 542)
                                    XCTAssertEqual(firstReport.currency, "AUD")
                                    XCTAssertEqual(firstReport.period, .day)
                                    XCTAssertEqual(firstReport.value, NSDecimalNumber(string: "-1191.45"))
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
        }
        
        wait(for: [expectation1], timeout: 10.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testFetchingAccountBalanceReportsByMonth() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + ReportsEndpoint.accountBalance.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "account_balance_reports_by_month_2018-10-29_2019-01-29", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, service: service)
            let reports = Reports(database: database, service: service, aggregation: aggregation)
            
            let fromDate = ReportAccountBalance.dailyDateFormatter.date(from: "2018-10-29")!
            let toDate = ReportAccountBalance.dailyDateFormatter.date(from: "2019-01-29")!
            
            reports.refreshAccountBalanceReports(period: .month, from: fromDate, to: toDate) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            let context = database.viewContext
                            
                            // Check for overall reports
                            let fetchRequest: NSFetchRequest<ReportAccountBalance> = ReportAccountBalance.fetchRequest()
                            fetchRequest.predicate = NSPredicate(format: #keyPath(ReportAccountBalance.periodRawValue) + " == %@", argumentArray: [ReportAccountBalance.Period.month.rawValue])
                            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportAccountBalance.dateString), ascending: true), NSSortDescriptor(key: #keyPath(ReportAccountBalance.accountID), ascending: true)]
                            
                            do {
                                let fetchedReports = try context.fetch(fetchRequest)
                                
                                XCTAssertEqual(fetchedReports.count, 31)
                                
                                if let firstReport = fetchedReports.first {
                                    XCTAssertEqual(firstReport.dateString, "2018-10")
                                    XCTAssertEqual(firstReport.accountID, 542)
                                    XCTAssertEqual(firstReport.currency, "AUD")
                                    XCTAssertEqual(firstReport.period, .month)
                                    XCTAssertEqual(firstReport.value, NSDecimalNumber(string: "208.55"))
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
        }
        
        wait(for: [expectation1], timeout: 10.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testFetchingAccountBalanceReportsByWeek() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + ReportsEndpoint.accountBalance.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "account_balance_reports_by_week_2018-10-29_2019-01-29", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, service: service)
            let reports = Reports(database: database, service: service, aggregation: aggregation)
            
            let fromDate = ReportAccountBalance.dailyDateFormatter.date(from: "2018-10-29")!
            let toDate = ReportAccountBalance.dailyDateFormatter.date(from: "2019-01-29")!
            
            reports.refreshAccountBalanceReports(period: .week, from: fromDate, to: toDate) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            let context = database.viewContext
                            
                            // Check for overall reports
                            let fetchRequest: NSFetchRequest<ReportAccountBalance> = ReportAccountBalance.fetchRequest()
                            fetchRequest.predicate = NSPredicate(format: #keyPath(ReportAccountBalance.periodRawValue) + " == %@", argumentArray: [ReportAccountBalance.Period.week.rawValue])
                            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportAccountBalance.dateString), ascending: true), NSSortDescriptor(key: #keyPath(ReportAccountBalance.accountID), ascending: true)]
                            
                            do {
                                let fetchedReports = try context.fetch(fetchRequest)
                                
                                XCTAssertEqual(fetchedReports.count, 122)
                                
                                if let firstReport = fetchedReports.first {
                                    XCTAssertEqual(firstReport.dateString, "2018-10-4")
                                    XCTAssertEqual(firstReport.accountID, 542)
                                    XCTAssertEqual(firstReport.currency, "AUD")
                                    XCTAssertEqual(firstReport.period, .week)
                                    XCTAssertEqual(firstReport.value, NSDecimalNumber(string: "-1191.45"))
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
        }
        
        wait(for: [expectation1], timeout: 10.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testFetchingAccountBalanceReportsByAccountID() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + ReportsEndpoint.accountBalance.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "account_balance_reports_by_day_account_id_937_2018-10-29_2019-01-29", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, service: service)
            let reports = Reports(database: database, service: service, aggregation: aggregation)
            
            let fromDate = ReportAccountBalance.dailyDateFormatter.date(from: "2018-10-29")!
            let toDate = ReportAccountBalance.dailyDateFormatter.date(from: "2019-01-29")!
            
            reports.refreshAccountBalanceReports(period: .day, from: fromDate, to: toDate) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            let context = database.viewContext
                            
                            // Check for overall reports
                            let fetchRequest: NSFetchRequest<ReportAccountBalance> = ReportAccountBalance.fetchRequest()
                            fetchRequest.predicate = NSPredicate(format: #keyPath(ReportAccountBalance.periodRawValue) + " == %@ && " + #keyPath(ReportAccountBalance.accountID) + " == %ld", argumentArray: [ReportAccountBalance.Period.day.rawValue, 937])
                            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportAccountBalance.dateString), ascending: true), NSSortDescriptor(key: #keyPath(ReportAccountBalance.accountID), ascending: true)]
                            
                            do {
                                let fetchedReports = try context.fetch(fetchRequest)
                                
                                XCTAssertEqual(fetchedReports.count, 94)
                                
                                if let firstReport = fetchedReports.first {
                                    XCTAssertEqual(firstReport.dateString, "2018-10-28")
                                    XCTAssertEqual(firstReport.accountID, 937)
                                    XCTAssertEqual(firstReport.currency, "AUD")
                                    XCTAssertEqual(firstReport.period, .day)
                                    XCTAssertEqual(firstReport.value, NSDecimalNumber(string: "-2641.45"))
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
        }
        
        wait(for: [expectation1], timeout: 10.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testFetchingAccountBalanceReportsByAccountType() {
        let expectation1 = expectation(description: "Database Setup")
        let expectation2 = expectation(description: "Network Request 1")
        let expectation3 = expectation(description: "Network Request 2")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.accounts.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "accounts_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + ReportsEndpoint.accountBalance.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "account_balance_reports_by_day_container_bank_2018-10-29_2019-01-29", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        let aggregation = Aggregation(database: database, service: service)
        
        aggregation.refreshAccounts() { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                expectation2.fulfill()
            }
        }
        
        wait(for: [expectation2], timeout: 3.0)
                
        let reports = Reports(database: database, service: service, aggregation: aggregation)
        
        let fromDate = ReportAccountBalance.dailyDateFormatter.date(from: "2018-10-29")!
        let toDate = ReportAccountBalance.dailyDateFormatter.date(from: "2019-01-29")!
        
        reports.refreshAccountBalanceReports(period: .day, from: fromDate, to: toDate) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                expectation3.fulfill()
            }
        }
        
        wait(for: [expectation3], timeout: 5.0)
        
        let context = database.viewContext
        
        // Check for overall reports
        let fetchRequest: NSFetchRequest<ReportAccountBalance> = ReportAccountBalance.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: #keyPath(ReportAccountBalance.periodRawValue) + " == %@ && " + #keyPath(ReportAccountBalance.account.accountTypeRawValue) + " == %@", argumentArray: [ReportAccountBalance.Period.day.rawValue, Account.AccountType.bank.rawValue])
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportAccountBalance.dateString), ascending: true), NSSortDescriptor(key: #keyPath(ReportAccountBalance.accountID), ascending: true)]
        
        do {
            let fetchedReports = try context.fetch(fetchRequest)
            
            XCTAssertEqual(fetchedReports.count, 376)
            
            if let lastReport = fetchedReports.last {
                XCTAssertEqual(lastReport.dateString, "2019-01-29")
                XCTAssertEqual(lastReport.accountID, 938)
                XCTAssertEqual(lastReport.currency, "AUD")
                XCTAssertEqual(lastReport.period, .day)
                XCTAssertEqual(lastReport.value, NSDecimalNumber(string: "42000"))
            } else {
                XCTFail("Reports not found")
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        OHHTTPStubs.removeAllStubs()
    }
    
    func testFetchingAccountBalanceReportsUpdatesExisting() {
        let expectation1 = expectation(description: "Database Setup")
        let expectation2 = expectation(description: "Network Request 1")
        let expectation3 = expectation(description: "Network Request 2")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + ReportsEndpoint.accountBalance.path)) { (request) -> OHHTTPStubsResponse in
            if let requestURL = request.url, let queryItems = URLComponents(url: requestURL, resolvingAgainstBaseURL: true)?.queryItems {
                var fromDate: String = ""
                
                for queryItem in queryItems {
                    if queryItem.name == "from_date", let value = queryItem.value {
                        fromDate = value
                    }
                }
                
                if fromDate == "2018-10-29" {
                    return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "account_balance_reports_by_month_2018-10-29_2019-01-29", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
                } else if fromDate == "2018-11-01" {
                    return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "account_balance_reports_by_month_2018-11-01_2019-02-01", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
                }
            }
            
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "account_balance_reports_by_month_2018-11-01_2019-02-01", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        let aggregation = Aggregation(database: database, service: service)
        let reports = Reports(database: database, service: service, aggregation: aggregation)
        
        let oldFromDate = ReportAccountBalance.dailyDateFormatter.date(from: "2018-10-29")!
        let oldToDate = ReportAccountBalance.dailyDateFormatter.date(from: "2019-01-29")!
        
        reports.refreshAccountBalanceReports(period: .month, from: oldFromDate, to: oldToDate) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                // Allow Core Data to sync
                expectation2.fulfill()
            }
        }
        
        wait(for: [expectation2], timeout: 5.0)
                    
        let context = database.viewContext
        
        let oldFetchRequest: NSFetchRequest<ReportAccountBalance> = ReportAccountBalance.fetchRequest()
        oldFetchRequest.predicate = NSPredicate(format: #keyPath(ReportAccountBalance.periodRawValue) + " == %@ && " + #keyPath(ReportAccountBalance.dateString) + " == %@", argumentArray: [ReportAccountBalance.Period.month.rawValue, "2018-10"])
        oldFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportAccountBalance.dateString), ascending: true), NSSortDescriptor(key: #keyPath(ReportAccountBalance.accountID), ascending: true)]
        
        let newFetchRequest: NSFetchRequest<ReportAccountBalance> = ReportAccountBalance.fetchRequest()
        newFetchRequest.predicate = NSPredicate(format: #keyPath(ReportAccountBalance.periodRawValue) + " == %@ && " + #keyPath(ReportAccountBalance.dateString) + " == %@", argumentArray: [ReportAccountBalance.Period.month.rawValue, "2019-02"])
        newFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportAccountBalance.dateString), ascending: true), NSSortDescriptor(key: #keyPath(ReportAccountBalance.accountID), ascending: true)]
        
        // Check old reports exist
        do {
            let fetchedOldReports = try context.fetch(oldFetchRequest)
            
            XCTAssertEqual(fetchedOldReports.count, 8)
            
            if let firstReport = fetchedOldReports.first {
                XCTAssertEqual(firstReport.dateString, "2018-10")
                XCTAssertEqual(firstReport.accountID, 542)
                XCTAssertEqual(firstReport.currency, "AUD")
                XCTAssertEqual(firstReport.period, .month)
                XCTAssertEqual(firstReport.value, NSDecimalNumber(string: "208.55"))
            } else {
                XCTFail("Reports not found")
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        // Check new reports don't exist
        do {
            let fetchedNewReports = try context.fetch(newFetchRequest)
            
            XCTAssertEqual(fetchedNewReports.count, 0)
            XCTAssertNil(fetchedNewReports.first)
        } catch {
            XCTFail(error.localizedDescription)
        }
                    
        let newFromDate = ReportAccountBalance.dailyDateFormatter.date(from: "2018-11-01")!
        let newToDate = ReportAccountBalance.dailyDateFormatter.date(from: "2019-02-01")!
        
        reports.refreshAccountBalanceReports(period: .month, from: newFromDate, to: newToDate) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                // Wait for Core Data to sync
                expectation3.fulfill()
            }
        }
        
        wait(for: [expectation3], timeout: 5.0)
        
        // Check old reports still exist
        do {
            let fetchedOldReports = try context.fetch(oldFetchRequest)
            
            XCTAssertEqual(fetchedOldReports.count, 8)
            
            if let firstReport = fetchedOldReports.first {
                XCTAssertEqual(firstReport.dateString, "2018-10")
                XCTAssertEqual(firstReport.accountID, 542)
                XCTAssertEqual(firstReport.currency, "AUD")
                XCTAssertEqual(firstReport.period, .month)
                XCTAssertEqual(firstReport.value, NSDecimalNumber(string: "-1191.45"))
            } else {
                XCTFail("Reports not found")
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        // Check new reports exist
        do {
            let fetchedNewReports = try context.fetch(newFetchRequest)
            
            XCTAssertEqual(fetchedNewReports.count, 7)
            
            if let firstReport = fetchedNewReports.first {
                XCTAssertEqual(firstReport.dateString, "2019-02")
                XCTAssertEqual(firstReport.accountID, 542)
                XCTAssertEqual(firstReport.currency, "AUD")
                XCTAssertEqual(firstReport.period, .month)
                XCTAssertEqual(firstReport.value, NSDecimalNumber(string: "1823.85"))
            } else {
                XCTFail("Reports not found")
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testFetchingAccountBalanceReportsCommingling() {
        let expectation1 = expectation(description: "Database setup")
        let expectation2 = expectation(description: "Network Request 1")
        let expectation3 = expectation(description: "Network Request 2")
        let expectation4 = expectation(description: "Network Request 3")
        let expectation5 = expectation(description: "Fetch")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + ReportsEndpoint.accountBalance.path)) { (request) -> OHHTTPStubsResponse in
            if let requestURL = request.url, let queryItems = URLComponents(url: requestURL, resolvingAgainstBaseURL: true)?.queryItems {
                var period: String = ""
                
                for queryItem in queryItems {
                    if queryItem.name == "period", let value = queryItem.value {
                        period = value
                    }
                }
                
                if period == "by_day" {
                    return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "account_balance_reports_by_day_2018-10-29_2019-01-29", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
                } else if period == "by_week" {
                    return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "account_balance_reports_by_week_2018-10-29_2019-01-29", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
                }
            }
            
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "account_balance_reports_by_month_2018-10-29_2019-01-29", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        let aggregation = Aggregation(database: database, service: service)
        let reports = Reports(database: database, service: service, aggregation: aggregation)
        
        let fromDate = ReportAccountBalance.dailyDateFormatter.date(from: "2018-10-29")!
        let toDate = Reports.dailyDateFormatter.date(from: "2019-01-29")!
        
        reports.refreshAccountBalanceReports(period: .day, from: fromDate, to: toDate) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation2.fulfill()
        }
        
        reports.refreshAccountBalanceReports(period: .month, from: fromDate, to: toDate) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation3.fulfill()
        }
        
        reports.refreshAccountBalanceReports(period: .week, from: fromDate, to: toDate) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation4.fulfill()
        }
        
        wait(for: [expectation2, expectation3, expectation4], timeout: 5.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let context = database.viewContext
            
            // Check for day reports
            let dayFetchRequest: NSFetchRequest<ReportAccountBalance> = ReportAccountBalance.fetchRequest()
            dayFetchRequest.predicate = NSPredicate(format: #keyPath(ReportAccountBalance.periodRawValue) + " == %@", argumentArray: [ReportAccountBalance.Period.day.rawValue])
            dayFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportAccountBalance.dateString), ascending: true), NSSortDescriptor(key: #keyPath(ReportAccountBalance.accountID), ascending: true)]
            
            do {
                let fetchedDayReports = try context.fetch(dayFetchRequest)
                
                XCTAssertEqual(fetchedDayReports.count, 661)
                
                if let firstReport = fetchedDayReports.first {
                    XCTAssertEqual(firstReport.dateString, "2018-10-28")
                    XCTAssertEqual(firstReport.accountID, 542)
                    XCTAssertEqual(firstReport.currency, "AUD")
                    XCTAssertEqual(firstReport.period, .day)
                    XCTAssertEqual(firstReport.value, NSDecimalNumber(string: "-1191.45"))
                } else {
                    XCTFail("Reports not found")
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            // Check for month reports
            let monthFetchRequest: NSFetchRequest<ReportAccountBalance> = ReportAccountBalance.fetchRequest()
            monthFetchRequest.predicate = NSPredicate(format: #keyPath(ReportAccountBalance.periodRawValue) + " == %@", argumentArray: [ReportAccountBalance.Period.month.rawValue])
            monthFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportAccountBalance.dateString), ascending: true), NSSortDescriptor(key: #keyPath(ReportAccountBalance.accountID), ascending: true)]
            
            do {
                let fetchedMonthReports = try context.fetch(monthFetchRequest)
                
                XCTAssertEqual(fetchedMonthReports.count, 31)
                
                if let firstReport = fetchedMonthReports.first {
                    XCTAssertEqual(firstReport.dateString, "2018-10")
                    XCTAssertEqual(firstReport.accountID, 542)
                    XCTAssertEqual(firstReport.currency, "AUD")
                    XCTAssertEqual(firstReport.period, .month)
                    XCTAssertEqual(firstReport.value, NSDecimalNumber(string: "208.55"))
                } else {
                    XCTFail("Reports not found")
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            // Check for week reports
            let weekFetchRequest: NSFetchRequest<ReportAccountBalance> = ReportAccountBalance.fetchRequest()
            weekFetchRequest.predicate = NSPredicate(format: #keyPath(ReportAccountBalance.periodRawValue) + " == %@", argumentArray: [ReportAccountBalance.Period.week.rawValue])
            weekFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ReportAccountBalance.dateString), ascending: true), NSSortDescriptor(key: #keyPath(ReportAccountBalance.accountID), ascending: true)]
            
            do {
                let fetchedWeekReports = try context.fetch(weekFetchRequest)
                
                XCTAssertEqual(fetchedWeekReports.count, 122)
                
                if let firstReport = fetchedWeekReports.first {
                    XCTAssertEqual(firstReport.dateString, "2018-10-4")
                    XCTAssertEqual(firstReport.accountID, 542)
                    XCTAssertEqual(firstReport.currency, "AUD")
                    XCTAssertEqual(firstReport.period, .week)
                    XCTAssertEqual(firstReport.value, NSDecimalNumber(string: "-1191.45"))
                } else {
                    XCTFail("Reports not found")
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            expectation5.fulfill()
        }
        
        wait(for: [expectation5], timeout: 5.0)
    }

    // MARK: - Transaction Report Tests

    func testFetchTransactionReport_GroupedByBudgetCategory() {

        let expectation1 = expectation(description: "Database setup")
        let budgetCategory = BudgetCategory.income
        let filter = TransactionReportFilter.budgetCategory(id: budgetCategory.id)
        let transactionHistoryPath = ReportsEndpoint.transactionsHistory(entity: filter.entity, id: filter.id)

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + transactionHistoryPath.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_reports_txn_budget_category_monthly_2019_01_01_2019_12_31", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())

        database.setup { (error) in
            XCTAssertNil(error)

            expectation1.fulfill()
        }

        wait(for: [expectation1], timeout: 3.0)

        let aggregation = Aggregation(database: database, service: service)
        let reports = Reports(database: database, service: service, aggregation: aggregation)

        let fromDate = ReportAccountBalance.dailyDateFormatter.date(from: "2018-10-29")!
        let toDate = Reports.dailyDateFormatter.date(from: "2019-01-29")!

        let expectation2 = expectation(description: "Network Call")

        var fetchResult: Result<[ReportResponse<BudgetCategoryGroupReport>], Error>?

        reports.fetchTransactionBudgetCategoryReports(budgetCategory, period: .weekly, from: fromDate, to: toDate) { (result) in
            fetchResult = result
            expectation2.fulfill()
        }

        wait(for: [expectation2], timeout: 3.0)

        switch fetchResult {
        case .success(let response):
            guard response.count > 5 else { XCTFail(); return }
            let secondItem = response[5]
            guard secondItem.groupReports.count > 2 else { XCTFail(); return }
            let secondReport = secondItem.groupReports[1]
            XCTAssertEqual(secondReport.budgetCategory, BudgetCategory.lifestyle)
        default:
            XCTFail()
        }
    }

    func testFetchTransactionReport_GroupedByCategory() {

        let expectation1 = expectation(description: "Database setup")
        
        let filter = TransactionReportFilter.category(id: 1)

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + ReportsEndpoint.transactionsHistory(entity: filter.entity, id: filter.id).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_reports_txn_category_monthly_2019_01_01_2019_12_31", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())

        database.setup { (error) in
            XCTAssertNil(error)

            expectation1.fulfill()
        }

        wait(for: [expectation1], timeout: 3.0)

        let aggregation = Aggregation(database: database, service: service)
        
        let reports = Reports(database: database, service: service, aggregation: aggregation)

        let fromDate = ReportAccountBalance.dailyDateFormatter.date(from: "2018-10-29")!
        let toDate = Reports.dailyDateFormatter.date(from: "2019-01-29")!

        let expectation2 = expectation(description: "Network Call")

        var fetchResult: Result<[ReportResponse<TransactionCategoryGroupReport>], Error>?
        

        reports.fetchTransactionReports(filtering: filter, grouping: TransactionCategoryGroupReport.self, period: .weekly, from: fromDate, to: toDate) { (result) in
            fetchResult = result
            expectation2.fulfill()
        }

        wait(for: [expectation2], timeout: 3.0)

        switch fetchResult {
        case .success(let response):
            guard response.count > 5 else { XCTFail(); return }
            let secondItem = response[6]
            guard secondItem.groupReports.count > 2 else { XCTFail(); return }
            let secondReport = secondItem.groupReports[1]
            XCTAssertEqual(secondReport.id, 67)
        default:
            XCTFail()
        }
    }

    func testFetchTransactionReport_GroupedByMerchant() {

        let expectation1 = expectation(description: "Database setup")
        
        let filter = TransactionReportFilter.category(id: 1)

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + ReportsEndpoint.transactionsHistory(entity: filter.entity, id: filter.id).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_reports_merchant_monthly_2019_01_01_2019_12_31", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())

        database.setup { (error) in
            XCTAssertNil(error)

            expectation1.fulfill()
        }

        wait(for: [expectation1], timeout: 3.0)

        let aggregation = Aggregation(database: database, service: service)
        let reports = Reports(database: database, service: service, aggregation: aggregation)

        let fromDate = ReportAccountBalance.dailyDateFormatter.date(from: "2018-10-29")!
        let toDate = Reports.dailyDateFormatter.date(from: "2019-01-29")!

        let expectation2 = expectation(description: "Network Call")

        var fetchResult: Result<[ReportResponse<MerchantGroupReport>], Error>?

        reports.fetchTransactionReports(filtering: filter, grouping: MerchantGroupReport.self, period: .weekly, from: fromDate, to: toDate) { (result) in
            fetchResult = result
            expectation2.fulfill()
        }

        wait(for: [expectation2], timeout: 3.0)

        switch fetchResult {
        case .success(let response):
            guard response.count > 5 else { XCTFail(); return }
            let secondItem = response[5]
            guard secondItem.groupReports.count > 2 else { XCTFail(); return }
            let secondReport = secondItem.groupReports[1]
            XCTAssertEqual(secondReport.id, 44)
        default:
            XCTFail()
        }
    }
    
}
