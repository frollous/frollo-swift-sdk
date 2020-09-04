//
// Copyright © 2018 Frollo. All rights reserved.
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

class BillsTests: BaseTestCase {

    override func setUp() {
        testsKeychainService = "BillsTests"
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        Keychain(service: keychainService).removeAll()
    }

    func testFetchBillByID() {
        let expectation1 = expectation(description: "Completion")
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        let aggregation = Aggregation(database: database, service: service)
        let bills = Bills(database: database, service: service, aggregation: aggregation)
        
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
            
            
            let bill = bills.bill(context: database.viewContext, billID: id)
            
            XCTAssertNotNil(bill)
            XCTAssertEqual(bill?.billID, id)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchBills() {
        let expectation1 = expectation(description: "Completion")
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        let aggregation = Aggregation(database: database, service: service)
        let bills = Bills(database: database, service: service, aggregation: aggregation)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testBill1 = Bill(context: managedObjectContext)
                testBill1.populateTestData()
                testBill1.frequency = .weekly
                testBill1.paymentStatus = .due
                testBill1.status = .confirmed
                testBill1.billType = .bill
                
                let testBill2 = Bill(context: managedObjectContext)
                testBill2.populateTestData()
                testBill2.frequency = .weekly
                testBill2.paymentStatus = .due
                testBill2.status = .confirmed
                testBill2.billType = .bill
                
                let testBill3 = Bill(context: managedObjectContext)
                testBill3.populateTestData()
                testBill3.frequency = .monthly
                testBill3.paymentStatus = .due
                testBill3.status = .estimated
                testBill3.billType = .manual
                
                try! managedObjectContext.save()
            }
            
            
            let fetchedBills = bills.bills(context: database.viewContext, frequency: .weekly, paymentStatus: .due, status: .confirmed, type: .bill)
            
            XCTAssertNotNil(fetchedBills)
            XCTAssertEqual(fetchedBills?.count, 2)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testBillsFetchedResultsController() {
        let expectation1 = expectation(description: "Completion")
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        let aggregation = Aggregation(database: database, service: service)
        let bills = Bills(database: database, service: service, aggregation: aggregation)
        
        let managedObjectContext = database.newBackgroundContext()
        let fetchedResultsController = bills.billsFetchedResultsController(context: managedObjectContext, frequency: .weekly, paymentStatus: .due, status: .estimated, type: .bill)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            
            managedObjectContext.performAndWait {
                let testBill1 = Bill(context: managedObjectContext)
                testBill1.populateTestData()
                testBill1.frequency = .weekly
                testBill1.paymentStatus = .due
                testBill1.status = .estimated
                testBill1.billType = .bill
                
                let testBill2 = Bill(context: managedObjectContext)
                testBill2.populateTestData()
                testBill2.frequency = .weekly
                testBill2.paymentStatus = .due
                testBill2.status = .estimated
                testBill2.billType = .bill
                
                let testBill3 = Bill(context: managedObjectContext)
                testBill3.populateTestData()
                testBill3.frequency = .monthly
                testBill3.paymentStatus = .due
                testBill3.status = .confirmed
                testBill3.billType = .manual
                
                try! managedObjectContext.save()
            }
            
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
    
    func testCreateBillWithTransaction() {
        let expectation1 = expectation(description: "Network Request 1")
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + BillsEndpoint.bills.path) && isMethodPOST()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bill_id_12345", ofType: "json")!, status: 201, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        let aggregation = Aggregation(database: database, service: service)
        let bills = Bills(database: database, service: service, aggregation: aggregation)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            
            bills.createBill(transactionID: 987, dueAmount: 11.99, frequency: .monthly, nextPaymentDate: Date(timeIntervalSinceNow: 20000), name: nil, notes: nil) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
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
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 5.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testCreateBillManually() {
        let expectation1 = expectation(description: "Network Request 1")
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + BillsEndpoint.bills.path) && isMethodPOST()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bill_id_12345", ofType: "json")!, status: 201, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        let aggregation = Aggregation(database: database, service: service)
        let bills = Bills(database: database, service: service, aggregation: aggregation)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            
            let date = Bill.billDateFormatter.date(from: "2019-02-01")!
            
            bills.createBill(accountID: 654, dueAmount: 50.0, frequency: .weekly, nextPaymentDate: date, name: "Stan", notes: "Cancel this") { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
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
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 5.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testCreateBillFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + BillsEndpoint.bills.path) && isMethodPOST()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bill_id_12345", ofType: "json")!, status: 201, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication(valid: false)
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        let aggregation = Aggregation(database: database, service: service)
        let bills = Bills(database: database, service: service, aggregation: aggregation)
        
        let date = Bill.billDateFormatter.date(from: "2019-02-01")!
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            
            bills.createBill(accountID: 654, dueAmount: 50.0, frequency: .weekly, nextPaymentDate: date, name: "Stan", notes: "Cancel this") { (result) in
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
        
        wait(for: [expectation1], timeout: 5.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testDeleteBill() {
        let expectation1 = expectation(description: "Network Request")
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + BillsEndpoint.bill(billID: 12345).path)) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 204, headers: nil)
        }
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        let aggregation = Aggregation(database: database, service: service)
        let bills = Bills(database: database, service: service, aggregation: aggregation)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let bill = Bill(context: managedObjectContext)
                bill.populateTestData()
                bill.billID = 12345
                
                try? managedObjectContext.save()
            }
            
            bills.deleteBill(billID: 12345) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        XCTAssertNil(bills.bill(context: database.viewContext, billID: 12345))
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testDeleteBillFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + BillsEndpoint.bill(billID: 12345).path)) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 204, headers: nil)
        }
        
        let mockAuthentication = MockAuthentication(valid: false)
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        let aggregation = Aggregation(database: database, service: service)
        let bills = Bills(database: database, service: service, aggregation: aggregation)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            
            bills.deleteBill(billID: 12345) { (result) in
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
        
        wait(for: [expectation1], timeout: 5.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testRefreshBills() {
        let expectation1 = expectation(description: "Network Request 1")
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + BillsEndpoint.bills.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bills_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        let aggregation = Aggregation(database: database, service: service)
        let bills = Bills(database: database, service: service, aggregation: aggregation)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            
            bills.refreshBills() { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = database.viewContext
                        
                        let fetchRequest: NSFetchRequest<Bill> = Bill.fetchRequest()
                        
                        do {
                            let fetchedBills = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedBills.count, 7)
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testRefreshBillsFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + BillsEndpoint.bills.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bills_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication(valid: false)
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        let aggregation = Aggregation(database: database, service: service)
        let bills = Bills(database: database, service: service, aggregation: aggregation)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            
            bills.refreshBills() { (result) in
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
        
        wait(for: [expectation1], timeout: 5.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testRefreshBillByID() {
        let expectation1 = expectation(description: "Network Request 1")
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + BillsEndpoint.bill(billID: 12345).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bill_id_12345", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        let aggregation = Aggregation(database: database, service: service)
        let bills = Bills(database: database, service: service, aggregation: aggregation)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            
            bills.refreshBill(billID: 12345) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = database.viewContext
                        
                        let fetchRequest: NSFetchRequest<Bill> = Bill.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "billID == %ld", argumentArray: [12345])
                        
                        do {
                            let fetchedBills = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedBills.first?.billID, 12345)
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testRefreshBillByIDFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + BillsEndpoint.bills.path) && isMethodPOST()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bill_id_12345", ofType: "json")!, status: 201, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication(valid: false)
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        let aggregation = Aggregation(database: database, service: service)
        let bills = Bills(database: database, service: service, aggregation: aggregation)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            
            bills.refreshBill(billID: 12345) { (result) in
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
        
        wait(for: [expectation1], timeout: 5.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testUpdateBill() {
        let expectation1 = expectation(description: "Network Request 1")
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + BillsEndpoint.bill(billID: 12345).path) && isMethodPUT()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bill_id_12345", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        let aggregation = Aggregation(database: database, service: service)
        let bills = Bills(database: database, service: service, aggregation: aggregation)
        
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
                
                bills.updateBill(billID: 12345) { (result) in
                    switch result {
                        case .failure(let error):
                            XCTFail(error.localizedDescription)
                        case .success:
                            let context = database.viewContext
                            
                            context.performAndWait {
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
            }
        }
        
        wait(for: [expectation1], timeout: 5.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testUpdateBillFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + BillsEndpoint.bills.path) && isMethodPOST()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bill_id_12345", ofType: "json")!, status: 201, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication(valid: false)
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        let aggregation = Aggregation(database: database, service: service)
        let bills = Bills(database: database, service: service, aggregation: aggregation)
        
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
                bills.updateBill(billID: 12345) { (result) in
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
        }
        
        wait(for: [expectation1], timeout: 5.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testUpdateBillNotFound() {
        let expectation1 = expectation(description: "Network Request 1")
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + BillsEndpoint.bill(billID: 12345).path) && isMethodPUT()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bill_id_12345", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        let managedObjectContext = database.newBackgroundContext()
        
        let aggregation = Aggregation(database: database, service: service)
        let bills = Bills(database: database, service: service, aggregation: aggregation)
        database.setup { (error) in
            XCTAssertNil(error)
            
            
            managedObjectContext.performAndWait {
                let bill = Bill(context: managedObjectContext)
                bill.populateTestData()
                bill.billID = 666
                
                try? managedObjectContext.save()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                
                bills.updateBill(billID: 12345) { (result) in
                    switch result {
                        case .failure(let error):
                            if let dataError = error as? DataError {
                                XCTAssertEqual(dataError.type, .database)
                                XCTAssertEqual(dataError.subType, .notFound)
                            } else {
                                XCTFail("Wrong error type")
                            }
                        case .success:
                            XCTFail("Message should not be found")
                    }
                    
                    expectation1.fulfill()
                }
            }
        }
        
        wait(for: [expectation1], timeout: 5.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testBillsLinkToAccounts() {
        let expectation1 = expectation(description: "Database Setup")
        let expectation2 = expectation(description: "Network Account Request")
        let expectation3 = expectation(description: "Network Bill Request")
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + BillsEndpoint.bills.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bills_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.accounts.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "accounts_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
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
        let bills = Bills(database: database, service: service, aggregation: aggregation)
        
        aggregation.refreshAccounts() { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 3.0)
                
        bills.refreshBills() { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation3.fulfill()
        }
        
        wait(for: [expectation3], timeout: 3.0)
                    
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
        
        OHHTTPStubs.removeAllStubs()
    }
    
    func testBillsLinkToMerchants() {
        let expectation1 = expectation(description: "Database Setup")
        let expectation2 = expectation(description: "Network Merchants Request")
        let expectation3 = expectation(description: "Network Bill Request")
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + BillsEndpoint.bills.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bills_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.merchants.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "merchants_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
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
        let bills = Bills(database: database, service: service, aggregation: aggregation)
        
        aggregation.refreshMerchants() { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 3.0)
                
        bills.refreshBills() { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation3.fulfill()
        }
        
        wait(for: [expectation3], timeout: 3.0)
                    
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
        
        OHHTTPStubs.removeAllStubs()
    }
    
    func testBillsLinkToTransactionCategories() {
        let expectation1 = expectation(description: "Database Setup")
        let expectation2 = expectation(description: "Network Merchants Request")
        let expectation3 = expectation(description: "Network Bill Request")
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + BillsEndpoint.bills.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bills_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.transactionCategories.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_categories_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
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
        let bills = Bills(database: database, service: service, aggregation: aggregation)
        
        aggregation.refreshTransactionCategories() { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 3.0)
                
        bills.refreshBills() { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation3.fulfill()
        }
        
        wait(for: [expectation3], timeout: 3.0)
                    
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
        
        OHHTTPStubs.removeAllStubs()
    }
    
    // MARK: - Bill Payment Tests
    
    func testFetchBillPaymentByID() {
        let expectation1 = expectation(description: "Completion")
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        let managedObjectContext = database.newBackgroundContext()
        
        let aggregation = Aggregation(database: database, service: service)
        let bills = Bills(database: database, service: service, aggregation: aggregation)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            
            let id: Int64 = 12345
            
            managedObjectContext.performAndWait {
                let testBillPayment = BillPayment(context: managedObjectContext)
                testBillPayment.populateTestData()
                testBillPayment.billPaymentID = id
                
                try! managedObjectContext.save()
            }
            
            
            let billPayment = bills.billPayment(context: database.viewContext, billPaymentID: id)
            
            XCTAssertNotNil(billPayment)
            XCTAssertEqual(billPayment?.billPaymentID, id)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchBillPayments() {
        let expectation1 = expectation(description: "Completion")
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        let managedObjectContext = database.newBackgroundContext()

        let aggregation = Aggregation(database: database, service: service)
        let bills = Bills(database: database, service: service, aggregation: aggregation)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            
            managedObjectContext.performAndWait {
                let testBillPayment1 = BillPayment(context: managedObjectContext)
                testBillPayment1.populateTestData()
                testBillPayment1.frequency = .weekly
                testBillPayment1.paymentStatus = .due
                
                let testBillPayment2 = BillPayment(context: managedObjectContext)
                testBillPayment2.populateTestData()
                testBillPayment2.frequency = .weekly
                testBillPayment2.paymentStatus = .due
                
                let testBillPayment3 = BillPayment(context: managedObjectContext)
                testBillPayment3.populateTestData()
                testBillPayment3.frequency = .monthly
                testBillPayment3.paymentStatus = .future
                
                try! managedObjectContext.save()
            }
            
            
            let fetchedBillPayments = bills.billPayments(context: database.viewContext, frequency: .weekly, status: .due)
            
            XCTAssertNotNil(fetchedBillPayments)
            XCTAssertEqual(fetchedBillPayments?.count, 2)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testBillPaymentsFetchedResultsController() {
        let expectation1 = expectation(description: "Completion")
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        let managedObjectContext = database.newBackgroundContext()

        let aggregation = Aggregation(database: database, service: service)
        let bills = Bills(database: database, service: service, aggregation: aggregation)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            
            managedObjectContext.performAndWait {
                let testBillPayment1 = BillPayment(context: managedObjectContext)
                testBillPayment1.populateTestData()
                testBillPayment1.frequency = .weekly
                testBillPayment1.paymentStatus = .overdue
                
                let testBillPayment2 = BillPayment(context: managedObjectContext)
                testBillPayment2.populateTestData()
                testBillPayment2.frequency = .monthly
                testBillPayment2.paymentStatus = .due
                
                let testBillPayment3 = BillPayment(context: managedObjectContext)
                testBillPayment3.populateTestData()
                testBillPayment3.frequency = .weekly
                testBillPayment3.paymentStatus = .overdue
                
                try! managedObjectContext.save()
            }
            
            
            let fetchedResultsController = bills.billPaymentsFetchedResultsController(context: managedObjectContext, frequency: .weekly, status: .overdue)
            
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
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + BillsEndpoint.billPayment(billPaymentID: 12345).path)) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 204, headers: nil)
        }
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        let aggregation = Aggregation(database: database, service: service)
        let bills = Bills(database: database, service: service, aggregation: aggregation)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let billPayment = BillPayment(context: managedObjectContext)
                billPayment.populateTestData()
                billPayment.billID = 12345
                
                try? managedObjectContext.save()
            }
            
            bills.deleteBillPayment(billPaymentID: 12345) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        XCTAssertNil(bills.billPayment(context: database.viewContext, billPaymentID: 12345))
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testDeleteBillPaymentFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + BillsEndpoint.billPayment(billPaymentID: 12345).path)) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 204, headers: nil)
        }
        
        let mockAuthentication = MockAuthentication(valid: false)
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        let aggregation = Aggregation(database: database, service: service)
        let bills = Bills(database: database, service: service, aggregation: aggregation)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            
            bills.deleteBillPayment(billPaymentID: 12345) { (result) in
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
        
        wait(for: [expectation1], timeout: 5.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testRefreshBillPayments() {
        let expectation1 = expectation(description: "Network Request 1")
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + BillsEndpoint.billPayments.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bill_payments_2018-12-01_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        let aggregation = Aggregation(database: database, service: service)
        let bills = Bills(database: database, service: service, aggregation: aggregation)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let fromDate = BillPayment.billDateFormatter.date(from: "2018-12-01")!
            let toDate = BillPayment.billDateFormatter.date(from: "2021-01-01")!
            
            
            bills.refreshBillPayments(from: fromDate, to: toDate) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = database.viewContext
                        
                        let fetchRequest: NSFetchRequest<BillPayment> = BillPayment.fetchRequest()
                        
                        do {
                            let fetchedBillPayments = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedBillPayments.count, 7)
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testRefreshBillPaymentsFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + BillsEndpoint.billPayments.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bill_payments_2018-12-01_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication(valid: false)
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        let aggregation = Aggregation(database: database, service: service)
        let bills = Bills(database: database, service: service, aggregation: aggregation)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let fromDate = BillPayment.billDateFormatter.date(from: "2018-12-01")!
            let toDate = BillPayment.billDateFormatter.date(from: "2021-01-01")!
            
            
            bills.refreshBillPayments(from: fromDate, to: toDate) { (result) in
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
        
        wait(for: [expectation1], timeout: 5.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testRefreshBillPaymentByID() {
        let expectation1 = expectation(description: "Network Request 1")
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + BillsEndpoint.billPayment(billPaymentID: 12345).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bill_payment_id_12345", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        let aggregation = Aggregation(database: database, service: service)
        let bills = Bills(database: database, service: service, aggregation: aggregation)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            
            bills.refreshBillPayment(billPaymentID: 12345) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = database.viewContext
                        
                        let fetchRequest: NSFetchRequest<BillPayment> = BillPayment.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "billPaymentID == %ld", argumentArray: [12345])
                        
                        do {
                            let fetchedBillPayments = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedBillPayments.first?.billPaymentID, 12345)
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testRefreshBillPaymentByIDFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + BillsEndpoint.billPayment(billPaymentID: 12345).path) && isMethodPUT()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bill_payment_id_12345", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication(valid: false)
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        let aggregation = Aggregation(database: database, service: service)
        let bills = Bills(database: database, service: service, aggregation: aggregation)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            
            bills.refreshBillPayment(billPaymentID: 12345) { (result) in
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
        
        wait(for: [expectation1], timeout: 5.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testUpdateBillPayment() {
        let expectation1 = expectation(description: "Network Request 1")
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + BillsEndpoint.billPayment(billPaymentID: 12345).path) && isMethodPUT()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bill_payment_id_12345", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        let aggregation = Aggregation(database: database, service: service)
        let bills = Bills(database: database, service: service, aggregation: aggregation)
        
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
                
                bills.updateBillPayment(billPaymentID: 12345) { (result) in
                    switch result {
                        case .failure(let error):
                            XCTFail(error.localizedDescription)
                        case .success:
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
                    }
                    
                    expectation1.fulfill()
                }
            }
        }
        
        wait(for: [expectation1], timeout: 5.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testUpdateBillPaymentFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + BillsEndpoint.billPayment(billPaymentID: 12345).path) && isMethodPUT()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bill_payment_id_12345", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication(valid: false)
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        let aggregation = Aggregation(database: database, service: service)
        let bills = Bills(database: database, service: service, aggregation: aggregation)
        
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
            
                bills.updateBillPayment(billPaymentID: 12345) { (result) in
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
        }
        
        wait(for: [expectation1], timeout: 5.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testUpdateBillPaymentNotFound() {
        let expectation1 = expectation(description: "Network Request 1")
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + BillsEndpoint.billPayment(billPaymentID: 12345).path) && isMethodPUT()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bill_payment_id_12345", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        let managedObjectContext = database.newBackgroundContext()
        
        let aggregation = Aggregation(database: database, service: service)
        let bills = Bills(database: database, service: service, aggregation: aggregation)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            
            managedObjectContext.performAndWait {
                let billPayment = BillPayment(context: managedObjectContext)
                billPayment.populateTestData()
                billPayment.billPaymentID = 666
                
                try? managedObjectContext.save()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                
                bills.updateBillPayment(billPaymentID: 12345) { (result) in
                    switch result {
                        case .failure(let error):
                            if let dataError = error as? DataError {
                                XCTAssertEqual(dataError.type, .database)
                                XCTAssertEqual(dataError.subType, .notFound)
                            } else {
                                XCTFail("Wrong error type")
                            }
                        case .success:
                            XCTFail("Finding bill payment should fail")
                    }
                    
                    expectation1.fulfill()
                }
            }
        }
        
        wait(for: [expectation1], timeout: 5.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testBillPaymentsLinkToBills() {
        let expectation1 = expectation(description: "Database Setup")
        let expectation2 = expectation(description: "Network Bills Request")
        let expectation3 = expectation(description: "Network Bill Payments Request")
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + BillsEndpoint.bills.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bills_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + BillsEndpoint.billPayments.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bill_payments_2018-12-01_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
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
        let bills = Bills(database: database, service: service, aggregation: aggregation)
        
        bills.refreshBills() { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 3.0)
                
        let fromDate = BillPayment.billDateFormatter.date(from: "2018-12-01")!
        let toDate = BillPayment.billDateFormatter.date(from: "2021-01-01")!
        
        bills.refreshBillPayments(from: fromDate, to: toDate) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }

            expectation3.fulfill()
        }
        
        wait(for: [expectation3], timeout: 3.0)
                    
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
        
        OHHTTPStubs.removeAllStubs()
    }
    
}
