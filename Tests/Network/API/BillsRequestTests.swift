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

import XCTest
@testable import FrolloSDK

import OHHTTPStubs
#if canImport(OHHTTPStubsSwift)
import OHHTTPStubsSwift
#endif

class BillsRequestTests: BaseTestCase {
    
    var keychain: Keychain!
    var service: APIService!

    override func setUp() {
        testsKeychainService = "BillsRequestTests"
        super.setUp()
        keychain = defaultKeychain(isNetwork: true)
        service = defaultService(keychain: keychain)
    }

    override func tearDown() {
        Keychain(service: keychainService).removeAll()
        HTTPStubs.removeAllStubs()
        super.tearDown()
    }
    
    // MARK: - Bills Tests
    
    func testCreateBillFromTransaction() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: BillsEndpoint.bills.path.prefixedWithSlash, toResourceWithName: "bill_id_12345", addingStatusCode: 201)
        
        let request = APIBillCreateRequest.testTransactionData()
        service.createBill(request: request) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.id, 12345)
                    XCTAssertEqual(response.name, "Netflix")
                    XCTAssertEqual(response.dueAmount, "11.99")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testCreateBillManual() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: BillsEndpoint.bills.path.prefixedWithSlash, toResourceWithName: "bill_id_12345", addingStatusCode: 201)
        
        let request = APIBillCreateRequest.testManualData()
        service.createBill(request: request) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.id, 12345)
                    XCTAssertEqual(response.name, "Netflix")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testCreateBillFail() {
        let expectation1 = expectation(description: "Network Request")
        // create invalid service
        service = invalidService(keychain: keychain)
        
        connect(endpoint: BillsEndpoint.bills.path.prefixedWithSlash, toResourceWithName: "bill_id_12345", addingStatusCode: 201)
        
        let request = APIBillCreateRequest.testTransactionData()
        service.createBill(request: request) { (result) in
            switch result {
            case .failure(let error):
                XCTAssertTrue(error is DataError)
                if let error = error as? DataError {
                    XCTAssertEqual(error.type, DataError.DataErrorType.api)
                    XCTAssertEqual(error.subType, DataError.DataErrorSubType.invalidData)
                }
            case .success:
                XCTFail("Invalid service throw Error when encoding APIBillCreateRequest")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }

    func testDeleteBill() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: BillsEndpoint.bill(billID: 12345).path.prefixedWithSlash, addingData: Data(), addingStatusCode: 204)
        
        service.deleteBill(billID: 12345) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        HTTPStubs.removeAllStubs()
    }
    
    func testFetchBills() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: BillsEndpoint.bills.path.prefixedWithSlash, toResourceWithName: "bills_valid")
        
        service.fetchBills { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.count, 7)
                    
                    if let firstBill = response.first {
                        XCTAssertEqual(firstBill.id, 1059)
                        XCTAssertEqual(firstBill.name, "McDonald's Really Really Long Transaction Name for Bill Test")
                        XCTAssertEqual(firstBill.description, nil)
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
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchBillsInvalidResponse() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: BillsEndpoint.bills.path.prefixedWithSlash, toResourceWithName: "bills_invalid")
        
        service.fetchBills { (result) in
            switch result {
                case .failure(let error):
                    XCTAssertTrue(error is DataError)
                    if let error = error as? DataError {
                        XCTAssertEqual(error.type, DataError.DataErrorType.unknown)
                        XCTAssertEqual(error.subType, DataError.DataErrorSubType.unknown)
                    }
                case .success(let response):
                    XCTFail("Data response is invalid")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchBillsInvalid() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: BillsEndpoint.bills.path.prefixedWithSlash, addingStatusCode: 404)
        
        service.fetchBills { (result) in
            switch result {
                case .failure(let error):
                    XCTAssertTrue(error is APIError)
                    if let error = error as? APIError {
                        XCTAssertEqual(error.statusCode, 404)
                    }
                case .success(let response):
                    XCTFail("Data response is invalid")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchBillByID() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: BillsEndpoint.bill(billID: 12345).path.prefixedWithSlash, toResourceWithName: "bill_id_12345")
        
        service.fetchBill(billID: 12345) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let billResponse):
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
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testUpdateBill() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: BillsEndpoint.bill(billID: 12345).path.prefixedWithSlash, toResourceWithName: "bill_id_12345")
        
        let request = APIBillUpdateRequest.testCompleteData()
        service.updateBill(billID: 12345, request: request) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.id, 12345)
                    XCTAssertEqual(response.name, "Netflix")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testUpdateBillFail() {
        let expectation1 = expectation(description: "Network Request")
        // create invalid service
        service = invalidService(keychain: keychain)
        
        connect(endpoint: BillsEndpoint.bills.path.prefixedWithSlash, toResourceWithName: "bill_id_12345", addingStatusCode: 201)
        
        let request = APIBillUpdateRequest.testCompleteData()
        service.updateBill(billID: 12345, request: request) { (result) in
            switch result {
            case .failure(let error):
                XCTAssertTrue(error is DataError)
                if let error = error as? DataError {
                    XCTAssertEqual(error.type, DataError.DataErrorType.api)
                    XCTAssertEqual(error.subType, DataError.DataErrorSubType.invalidData)
                }
            case .success:
                XCTFail("Invalid service throw Error when encoding APIBillUpdateRequest")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    // MARK: - Bill Payment Tests
    
    func testDeleteBillPayment() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: BillsEndpoint.billPayment(billPaymentID: 12345).path.prefixedWithSlash, addingData: Data(), addingStatusCode: 204)
        
        service.deleteBillPayment(billPaymentID: 12345) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        HTTPStubs.removeAllStubs()
    }
    
    func testFetchBillPayments() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: BillsEndpoint.billPayments.path.prefixedWithSlash, toResourceWithName: "bill_payments_2018-12-01_valid")
        
        let fromDate = BillPayment.billDateFormatter.date(from: "2018-12-01")!
        let toDate = BillPayment.billDateFormatter.date(from: "2021-01-01")!
        
        service.fetchBillPayments(from: fromDate, to: toDate) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.count, 7)
                    
                    if let firstBillPayment = response.first {
                        XCTAssertEqual(firstBillPayment.id, 7991)
                        XCTAssertEqual(firstBillPayment.billID, 1249)
                        XCTAssertEqual(firstBillPayment.name, "Optus Internet")
                        XCTAssertEqual(firstBillPayment.merchantID, 19)
                        XCTAssertEqual(firstBillPayment.date, "2019-01-07")
                        XCTAssertEqual(firstBillPayment.paymentStatus, .due)
                        XCTAssertEqual(firstBillPayment.frequency, .monthly)
                        XCTAssertEqual(firstBillPayment.amount, "70.0")
                    }
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchBillPaymentByID() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: BillsEndpoint.billPayment(billPaymentID: 12345).path.prefixedWithSlash, toResourceWithName: "bill_payment_id_12345")
        
        service.fetchBillPayment(billPaymentID: 12345) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let billPaymentResponse):
                    XCTAssertEqual(billPaymentResponse.id, 12345)
                    XCTAssertEqual(billPaymentResponse.billID, 1249)
                    XCTAssertEqual(billPaymentResponse.name, "Optus Internet")
                    XCTAssertEqual(billPaymentResponse.merchantID, 19)
                    XCTAssertEqual(billPaymentResponse.date, "2019-01-07")
                    XCTAssertEqual(billPaymentResponse.paymentStatus, .due)
                    XCTAssertEqual(billPaymentResponse.frequency, .monthly)
                    XCTAssertEqual(billPaymentResponse.amount, "70.0")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testUpdateBillPayment() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: BillsEndpoint.billPayment(billPaymentID: 12345).path.prefixedWithSlash, toResourceWithName: "bill_payment_id_12345")
        
        let request = APIBillPaymentUpdateRequest.testCompleteData()
        service.updateBillPayment(billPaymentID: 12345, request: request) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.id, 12345)
                    XCTAssertEqual(response.name, "Optus Internet")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }

    func testUpdateBillPaymentFail() {
        let expectation1 = expectation(description: "Network Request")
        // create invalid service
        service = invalidService(keychain: keychain)
        
        connect(endpoint: BillsEndpoint.billPayment(billPaymentID: 12345).path.prefixedWithSlash, toResourceWithName: "bill_payment_id_12345")
        
        let request = APIBillPaymentUpdateRequest.testCompleteData()
        service.updateBillPayment(billPaymentID: 12345, request: request) { (result) in
            switch result {
            case .failure(let error):
                XCTAssertTrue(error is DataError)
                if let error = error as? DataError {
                    XCTAssertEqual(error.type, DataError.DataErrorType.api)
                    XCTAssertEqual(error.subType, DataError.DataErrorSubType.invalidData)
                }
            case .success:
                XCTFail("Invalid service throw Error when encoding APIBillPaymentUpdateRequest")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }

}
