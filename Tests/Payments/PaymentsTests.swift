//
//  Copyright © 2019 Frollo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
// 
//      http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import XCTest
@testable import FrolloSDK

import OHHTTPStubs


class PaymentsTests: XCTestCase {
    
    let keychainService = "PaymentsTests"
    var service: APIService!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(configuration: config)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        service = APIService(serverEndpoint: config.serverEndpoint, network: network)
    }
    
    override func tearDown() {
        HTTPStubs.removeAllStubs()
        Keychain(service: keychainService).removeAll()
    }
    
    func testPayAnyone() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + PaymentsEndpoint.payAnyone.path)) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "pay_anyone_response", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        
        let payments = Payments(service: service)
        payments.payAnyone(accountHolder: "Joe Blow", accountNumber: "98765432", amount: 542.37, bsb: "123456", sourceAccountID: 42) { result in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.amount, "542.37")
                    XCTAssertEqual(response.destinationAccountHolder, "Joe Blow")
                    XCTAssertEqual(response.destinationBSB, "123456")
                    XCTAssertEqual(response.transactionID, "34")
                    XCTAssertEqual(response.transactionReference, "XXX")
                    XCTAssertEqual(response.status, "confirmed")
                    XCTAssertEqual(response.paymentDate, "2020-12-25")
                    expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        HTTPStubs.removeAllStubs()
    }
    
    func testPayAnyoneFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let mockAuthentication = MockAuthentication(valid: false)
        let authentication = Authentication(configuration: config)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + PaymentsEndpoint.payAnyone.path)) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "pay_anyone_response", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        
        let payments = Payments(service: service)
        payments.payAnyone(accountHolder: "Joe Blow", accountNumber: "98765432", amount: 542.37, bsb: "123456", sourceAccountID: 42) { result in
            switch result {
                case .failure(let error):
                    XCTAssertNotNil(error)
            
                    if let loggedOutError = error as? DataError {
                        XCTAssertEqual(loggedOutError.type, .authentication)
                        XCTAssertEqual(loggedOutError.subType, .missingAccessToken)
                        expectation1.fulfill()
                    } else {
                        XCTFail("Wrong error type returned")
                    }
                case .success:
                    XCTFail("User logged out, request should fail")
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        HTTPStubs.removeAllStubs()
    }
    
    func testPaymentTransfer() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + PaymentsEndpoint.transfers.path)) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "payment_transfer_response", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
                
        let payments = Payments(service: service)
        payments.transferPayment(amount: 542.37, description: "Visible to both sides", destinationAccountID: 43, paymentDate: Date() ,sourceAccountID: 42) { result in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.amount, "542.37")
                    XCTAssertEqual(response.destinationAccountID, 43)
                    XCTAssertEqual(response.destinationAccountHolder, "Everyday Txn")
                    XCTAssertEqual(response.transactionID, 34)
                    XCTAssertEqual(response.transactionReference, "XXX")
                    XCTAssertEqual(response.status, "scheduled")
                    XCTAssertEqual(response.paymentDate, "2020-12-25")
                    expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        HTTPStubs.removeAllStubs()
    }
    
    func testBPAYPayment() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + PaymentsEndpoint.bpay.path)) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bpay_payment_response", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        
        let payments = Payments(service: service)
        payments.bpayPayment(amount: 542.37, billerCode: "123456", crn: "98765432122232", paymentDate: Date(), reference: "Visible to customer", sourceAccountID: 42) { result in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.amount, "542.37")
                    XCTAssertEqual(response.crn, "98765432122232")
                    XCTAssertEqual(response.billerCode, "123456")
                    XCTAssertEqual(response.billerName, "ACME Inc.")
                    XCTAssertEqual(response.transactionID, 34)
                    XCTAssertEqual(response.transactionReference, "XXX")
                    XCTAssertEqual(response.status, "pending")
                    XCTAssertEqual(response.paymentDate, "2020-12-25")
                    XCTAssertEqual(response.reference, "Visible to customer")
                    XCTAssertEqual(response.sourceAccountName, "Everyday Txn")                    
                    expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        HTTPStubs.removeAllStubs()
    }

    func testPayIDPayment() {
        let expectation1 = expectation(description: "Network Request 1")

        let config = FrolloSDKConfiguration.testConfig()

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + PaymentsEndpoint.payID.path)) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "npp_payment_response", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }


        let payments = Payments(service: service)
        payments.payIDPayment(payID: "user@example.com", type: .email, payIDName: "Example Name", amount: 24.4, paymentDate: Date(), description: "Test", reference: "ABC123", sourceAccountID: 42) { result in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.transactionReference, "VLLTAU22XXXN20210202000000000770820")
                    expectation1.fulfill()
            }
        }

        wait(for: [expectation1], timeout: 3.0)
        HTTPStubs.removeAllStubs()
    }

    func testNppPayAnyone() {
        let expectation1 = expectation(description: "Network Request 1")

        let config = FrolloSDKConfiguration.testConfig()

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + PaymentsEndpoint.npp.path)) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "pay_anyone_response", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }


        let payments = Payments(service: service)
        payments.payAnyoneNPPPayment(accountHolder: "Joe Blow", accountNumber: "98765432", amount: 542.37, bsb: "123456", sourceAccountID: 42) { result in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.transactionReference, "XXX")
                    expectation1.fulfill()
            }
        }

        wait(for: [expectation1], timeout: 3.0)
        HTTPStubs.removeAllStubs()
    }
    
    func testVerifyValidPayAnyone() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + PaymentsEndpoint.verifyPayAnyone.path)) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "verify_payanyone_response_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let payments = Payments(service: service)
        payments.verifyPayAnyone(accountHolder: "Joe Blow", accountNumber: "98765432", bsb: "123456") { result in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.bsb, "123456")
                    XCTAssertEqual(response.accountNumber, "98765432")
                    XCTAssertEqual(response.bsbName, "Westpac Manly Corso")
                    XCTAssertEqual(response.valid, true)
                    XCTAssertEqual(response.accountHolder, "Joe Blow")
                    expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        HTTPStubs.removeAllStubs()
    }
    
    func testVerifyInValidPayAnyone() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + PaymentsEndpoint.verifyPayAnyone.path)) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "verify_payanyone_response_invalid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let payments = Payments(service: service)
        payments.verifyPayAnyone(accountHolder: "Joe Blow", accountNumber: "98765432", bsb: "123456") { result in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.bsb, nil)
                    XCTAssertEqual(response.accountNumber, nil)
                    XCTAssertEqual(response.bsbName, nil)
                    XCTAssertEqual(response.valid, false)
                    XCTAssertEqual(response.accountHolder, nil)
                    expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        HTTPStubs.removeAllStubs()
    }

    func testVerifyValidPayID() {
        let expectation1 = expectation(description: "Network Request 1")

        let config = FrolloSDKConfiguration.testConfig()

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + PaymentsEndpoint.verifyPayID.path)) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "verify_payID_response", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        let payments = Payments(service: service)
        payments.verifyPayID(payID: "+61411111111", type: .phoneNumber) { result in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.name, "John Doe")
                    XCTAssertEqual(response.payID, "+61411111111")
                    expectation1.fulfill()
            }
        }

        wait(for: [expectation1], timeout: 3.0)
        HTTPStubs.removeAllStubs()
    }

}
