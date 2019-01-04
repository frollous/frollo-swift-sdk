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
    
    // MARK: - Bills Tests
    
    func testCreateBill() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + BillsEndpoint.bills.path) && isMethodPOST()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bill_id_12345", ofType: "json")!, status: 201, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        let request = APIBillCreateRequest.testCompleteData()
        network.createBill(request: request) { (response, error) in
            XCTAssertNil(error)
            
            if let billResponse = response {
                XCTAssertEqual(billResponse.id, 12345)
                XCTAssertEqual(billResponse.name, "Netflix")
            } else {
                XCTFail("No response object")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }

    func testDeleteBill() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + BillsEndpoint.bill(billID: 12345).path)) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 204, headers: nil)
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.deleteBill(billID: 12345) { (response, error) in
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
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
    
    func testFetchBillByID() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + BillsEndpoint.bill(billID: 12345).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bill_id_12345", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchBill(billID: 12345) { (response, error) in
            XCTAssertNil(error)
            
            if let billResponse = response {
                XCTAssertEqual(billResponse.id, 12345)
                XCTAssertEqual(billResponse.name, "Netflix")
                XCTAssertEqual(billResponse.description, "NETFLIX.COM LOS GATOS CA   Cable and Other Pay Television Services")
                XCTAssertEqual(billResponse.billType, .subscription)
                XCTAssertEqual(billResponse.status, .confirmed)
                XCTAssertEqual(billResponse.dueAmount, "11.99")
                XCTAssertEqual(billResponse.averageAmount, "11.99")
                XCTAssertEqual(billResponse.frequency, .monthly)
                XCTAssertEqual(billResponse.paymentStatus, .overdue)
                XCTAssertEqual(billResponse.nextPaymentDate, "2018-05-20")
                XCTAssertEqual(billResponse.category?.id, 64)
                XCTAssertEqual(billResponse.category?.name, "Entertainment/Recreation")
                XCTAssertEqual(billResponse.merchant?.id, 40)
                XCTAssertEqual(billResponse.merchant?.name, "Netflix")
                XCTAssertNil(billResponse.note)
                XCTAssertNil(billResponse.accountID)
                XCTAssertNil(billResponse.lastPaymentDate)
                XCTAssertNil(billResponse.lastAmount)
            } else {
                XCTFail("No response object")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testUpdateBill() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + BillsEndpoint.bill(billID: 12345).path) && isMethodPUT()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bill_id_12345", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        let request = APIBillUpdateRequest.testCompleteData()
        network.updateBill(billID: 12345, request: request) { (response, error) in
            XCTAssertNil(error)
            
            if let billResponse = response {
                XCTAssertEqual(billResponse.id, 12345)
                XCTAssertEqual(billResponse.name, "Netflix")
            } else {
                XCTFail("No response object")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    // MARK: - Bill Payment Tests
    
    func testFetchBillPayments() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + BillsEndpoint.billPayments.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bill_payments_2018-12-01_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        let fromDate = BillPayment.billDateFormatter.date(from: "2018-12-01")!
        let toDate = BillPayment.billDateFormatter.date(from: "2021-01-01")!
        
        network.fetchBillPayments(from: fromDate, to: toDate) { (response, error) in
            XCTAssertNil(error)
            
            if let billPaymentsResponse = response {
                XCTAssertEqual(billPaymentsResponse.count, 7)
                
                if let firstBillPayment = billPaymentsResponse.first {
                    XCTAssertEqual(firstBillPayment.id, 7991)
                    XCTAssertEqual(firstBillPayment.billID, 1249)
                    XCTAssertEqual(firstBillPayment.name, "Optus Internet")
                    XCTAssertEqual(firstBillPayment.merchantID, 19)
                    XCTAssertEqual(firstBillPayment.date, "2019-01-07")
                    XCTAssertEqual(firstBillPayment.paymentStatus, .due)
                    XCTAssertEqual(firstBillPayment.frequency, .monthly)
                    XCTAssertEqual(firstBillPayment.amount, "70.0")
                }
            } else {
                XCTFail("No response object")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchBillPaymentByID() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + BillsEndpoint.billPayment(billPaymentID: 12345).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bill_payment_id_12345", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchBillPayment(billPaymentID: 12345) { (response, error) in
            XCTAssertNil(error)
            
            if let billPaymentResponse = response {
                XCTAssertEqual(billPaymentResponse.id, 12345)
                XCTAssertEqual(billPaymentResponse.billID, 1249)
                XCTAssertEqual(billPaymentResponse.name, "Optus Internet")
                XCTAssertEqual(billPaymentResponse.merchantID, 19)
                XCTAssertEqual(billPaymentResponse.date, "2019-01-07")
                XCTAssertEqual(billPaymentResponse.paymentStatus, .due)
                XCTAssertEqual(billPaymentResponse.frequency, .monthly)
                XCTAssertEqual(billPaymentResponse.amount, "70.0")
            } else {
                XCTFail("No response object")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }

}
