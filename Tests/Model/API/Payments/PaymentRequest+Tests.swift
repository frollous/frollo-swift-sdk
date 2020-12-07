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


class PaymentRequestTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        
    }
    
    func testBPAYPaymentRequest() throws {

        guard let url = Bundle(for: type(of: self)).path(forResource: "bpay_payment_request", ofType: "json") else {
            XCTFail("Missing file: bpay_payment_request")
            return
        }
        
        do {
            let bpayPaymentRequest = try JSONDecoder().decode(APIBPAYPaymentRequest.self, from: Data(contentsOf: URL(fileURLWithPath: url)))
            XCTAssertEqual(bpayPaymentRequest.amount, "542.37")
            XCTAssertEqual(bpayPaymentRequest.billerCode, "123456")
            XCTAssertEqual(bpayPaymentRequest.crn, "98765432122232")
            XCTAssertEqual(bpayPaymentRequest.paymentDate, "2020-12-25")
            XCTAssertEqual(bpayPaymentRequest.reference, "Visible to customer")
            XCTAssertEqual(bpayPaymentRequest.sourceAccountID, 42)
            
        } catch {
            XCTFail("JSON Decoding error")
        }

    }
    
    func testPayAnyoneRequest() throws {

        guard let url = Bundle(for: type(of: self)).path(forResource: "pay_anyone_request", ofType: "json") else {
            XCTFail("Missing file: pay_anyone_request")
            return
        }
        
        do {
            let payAnyoneRequest = try JSONDecoder().decode(APIPayAnyoneRequest.self, from: Data(contentsOf: URL(fileURLWithPath: url)))
            XCTAssertEqual(payAnyoneRequest.amount, "542.37")
            XCTAssertEqual(payAnyoneRequest.accountNumber, "98765432")
            XCTAssertEqual(payAnyoneRequest.accountHolder, "Joe Blow")
            XCTAssertEqual(payAnyoneRequest.paymentDate, "2020-12-25")
            XCTAssertEqual(payAnyoneRequest.reference, "Visible to payer")
            XCTAssertEqual(payAnyoneRequest.sourceAccountID, 42)
            XCTAssertEqual(payAnyoneRequest.bsb, "123456")
            XCTAssertEqual(payAnyoneRequest.description, "Visible to both")
            
        } catch {
            XCTFail("JSON Decoding error")
        }

    }
    
    func testPaymentTransferRequest() throws {

        guard let url = Bundle(for: type(of: self)).path(forResource: "payment_transfer_request", ofType: "json") else {
            XCTFail("Missing file: payment_transfer_request")
            return
        }
        
        do {
            let paymentTransferRequest = try JSONDecoder().decode(APIPaymentTransferRequest.self, from: Data(contentsOf: URL(fileURLWithPath: url)))
            XCTAssertEqual(paymentTransferRequest.amount, "542.37")
            XCTAssertEqual(paymentTransferRequest.destinationAccountID, 43)
            XCTAssertEqual(paymentTransferRequest.description, "Visible to both sides")
            XCTAssertEqual(paymentTransferRequest.paymentDate, "2020-12-25")
            XCTAssertEqual(paymentTransferRequest.sourceAccountID, 42)
            
        } catch {
            XCTFail("JSON Decoding error")
        }

    }
    
    func testVerifyPayAnyoneRequest() throws {

        guard let url = Bundle(for: type(of: self)).path(forResource: "verify_payanyone_request", ofType: "json") else {
            XCTFail("Missing file: verify_payanyone_request")
            return
        }
        
        do {
            let verifyPayAnyoneRequest = try JSONDecoder().decode(APIVerifyPayAnyoneRequest.self, from: Data(contentsOf: URL(fileURLWithPath: url)))
            XCTAssertEqual(verifyPayAnyoneRequest.accountHolder, "Joe Blow")
            XCTAssertEqual(verifyPayAnyoneRequest.accountNumber, "98765432")
            XCTAssertEqual(verifyPayAnyoneRequest.bsb, "123456")
            
        } catch {
            XCTFail("JSON Decoding error")
        }

    }
}
