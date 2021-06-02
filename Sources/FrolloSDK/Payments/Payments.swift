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

import Foundation

/// Managed all aspects of Payments
public class Payments: ResponseHandler {
    
    /// Date formatter to convert from stored date string to user's current locale
    public static let paymentDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    private let service: APIService
    
    internal init(service: APIService) {
        self.service = service
    }
    
    // MARK: - Make Payments
    
    /**
     Pay Anyone
     
     - parameters:
         - accountHolder: Name of the payee's bank account
         - accountNumber: Account number of the payee
         - amount: Amount of the payment
         - bsb: BSB of payee's bank
         - description: desctiption of the payment (Optional)
         - paymentDate: Date of the payment (Optional)
         - reference: reference of the payment (Optional)
         - sourceAccountID: Account ID of the payment source account
         - securityCode: Verification code/ OTP for payment
         - completion: Optional completion handler with `APIPayAnyoneResponse` result if succeeds and error if the request fails
     */
    public func payAnyone(accountHolder: String, accountNumber: String, amount: Decimal, bsb: String, description: String? = nil, paymentDate: Date? = nil, reference: String? = nil, sourceAccountID: Int64, securityCode: String? = nil, completion: @escaping (Result<PayAnyoneResponse, Error>) -> Void) {
        
        let paymentAmount = amount as NSDecimalNumber
        var date: String?
        if let paymentDate = paymentDate {
            date = Payments.paymentDateFormatter.string(from: paymentDate)
        }
        
        let request = APIPayAnyoneRequest(accountHolder: accountHolder, accountNumber: accountNumber, amount: paymentAmount.stringValue, bsb: bsb, description: description, paymentDate: date, reference: reference, sourceAccountID: sourceAccountID, overrideMethod: nil)
        
        service.payAnyone(request: request, otp: securityCode) { result in
            switch result {
                case .failure(let error):
                    error.logError()
                    
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                case .success(let response):
                    
                    DispatchQueue.main.async {
                        completion(.success(response))
                    }
            }
        }
    }
    
    /**
     Payment Transfer
     
     - parameters:
         - amount: Amount of the transfer
         - description: desctiption of the transfer (Optional)
         - destinationAccountID: Account ID of destination account of the transfer
         - paymentDate: Date of the payment transfer (Optional)
         - sourceAccountID: Account ID of source account of the transfer
         - securityCode: Verification code/ OTP for payment
         - completion: Optional completion handler with `PaymentTransferResponse` result if succeeds and error if the request fails
     */
    public func transferPayment(amount: Decimal, description: String? = nil, destinationAccountID: Int64, paymentDate: Date? = nil, sourceAccountID: Int64, securityCode: String? = nil, completion: @escaping (Result<PaymentTransferResponse, Error>) -> Void) {
        
        let paymentAmount = amount as NSDecimalNumber
        var date: String?
        if let paymentDate = paymentDate {
            date = Payments.paymentDateFormatter.string(from: paymentDate)
        }
        
        let request = APIPaymentTransferRequest(amount: paymentAmount.stringValue, description: description, destinationAccountID: destinationAccountID, paymentDate: date, sourceAccountID: sourceAccountID)
        
        service.transfer(request: request, otp: securityCode) { result in
            switch result {
                case .failure(let error):
                    error.logError()
                    
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                case .success(let response):
                    
                    DispatchQueue.main.async {
                        completion(.success(response))
                    }
            }
        }
    }
    
    /**
     BPAY Payment
     
     - parameters:
         - amount: Amount of the transfer
         - billerCode: BPAY Biller Code
         - crn: Customer Reference Number
         - paymentDate: Date of the payment (Optional)
         - reference: reference of the payment (Optional)
         - sourceAccountID: Account ID of source account of the payment
         - securityCode: Verification code/ OTP for payment
         - completion: Optional completion handler with `BPAYPaymentResponse` result if succeeds and error if the request fails
     */
    public func bpayPayment(amount: Decimal, billerCode: String, crn: String, paymentDate: Date? = nil, reference: String? = nil, sourceAccountID: Int64, securityCode: String? = nil, completion: @escaping (Result<BPAYPaymentResponse, Error>) -> Void) {
        
        let paymentAmount = amount as NSDecimalNumber
        var date: String?
        if let paymentDate = paymentDate {
            date = Payments.paymentDateFormatter.string(from: paymentDate)
        }
        
        let request = APIBPAYPaymentRequest(amount: paymentAmount.stringValue, billerCode: billerCode, crn: crn, paymentDate: date, reference: reference, sourceAccountID: sourceAccountID)
        
        service.bpayPayment(request: request, otp: securityCode) { result in
            switch result {
                case .failure(let error):
                    error.logError()
                    
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                case .success(let response):
                    
                    DispatchQueue.main.async {
                        completion(.success(response))
                    }
            }
        }
    }
    
    /**
     PayID Payment
     
     - parameters:
     - payID: Value of the PayID
     - type: Type of the PayID
     - payIDName: Name of the PayID holder
     - amount: Amount of the payment
     - description: desctiption of the payment (Optional)
     - paymentDate: Date of the payment (Optional)
     - reference: reference of the payment (Optional)
     - sourceAccountID: Account ID of the payment source account
     - securityCode: Verification code/ OTP for payment
     - completion: Optional completion handler with `PayIDPaymentResponse` result if succeeds and error if the request fails
     */
    public func payIDPayment(payID: String, type: PayIDContact.PayIDType, payIDName: String, amount: Decimal, paymentDate: Date = Date(), description: String? = nil, reference: String? = nil, sourceAccountID: Int64, securityCode: String? = nil, completion: @escaping (Result<PayIDPaymentResponse, Error>) -> Void) {
        
        let paymentAmount = amount as NSDecimalNumber
        let date = Payments.paymentDateFormatter.string(from: paymentDate)
        
        let request = APIPayIDPaymentRequest(payID: payID, payIDType: type, payIDName: payIDName, amount: paymentAmount.stringValue, description: description, paymentDate: date, reference: reference, sourceAccountID: sourceAccountID)
        
        service.payIDPayment(request: request, otp: securityCode) { result in
            switch result {
                case .failure(let error):
                    error.logError()
                    
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                case .success(let response):
                    DispatchQueue.main.async {
                        completion(.success(response))
                    }
            }
        }
    }
    
    /**
     Pay Anyone NPP Payment
     
     - parameters:
     - accountHolder: Name of the payee's bank account
     - accountNumber: Account number of the payee
     - amount: Amount of the payment
     - bsb: BSB of payee's bank
     - description: desctiption of the payment (Optional)
     - paymentDate: Date of the payment (Optional)
     - reference: reference of the payment (Optional)
     - sourceAccountID: Account ID of the payment source account
     - securityCode: Verification code/ OTP for payment
     - completion: Optional completion handler with `APIPayAnyoneResponse` result if succeeds and error if the request fails
     */
    public func payAnyoneNPPPayment(accountHolder: String, accountNumber: String, amount: Decimal, bsb: String, description: String? = nil, paymentDate: Date = Date(), reference: String? = nil, sourceAccountID: Int64, securityCode: String? = nil, completion: @escaping (Result<PayAnyoneResponse, Error>) -> Void) {
        
        let paymentAmount = amount as NSDecimalNumber
        let date = Payments.paymentDateFormatter.string(from: paymentDate)
        
        let request = APIPayAnyoneRequest(accountHolder: accountHolder, accountNumber: accountNumber, amount: paymentAmount.stringValue, bsb: bsb, description: description, paymentDate: date, reference: reference, sourceAccountID: sourceAccountID, overrideMethod: nil)
        
        service.payAnyoneNPPPayment(request: request, otp: securityCode) { result in
            switch result {
                case .failure(let error):
                    error.logError()
                    
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                case .success(let response):
                    DispatchQueue.main.async {
                        completion(.success(response))
                    }
            }
        }
    }
    
    /**
     Verify pay anyone
     
     - parameters:
         - accountHolder: Name of the account holder to verify (Optional)
         - accountNumber: Account number of the account  to verify (Optional)
         - bsb: BSB number to verity
         - completion: Optional completion handler with `VerifyPayAnyoneResponse` result if succeeds and error if the request fails
     */
    public func verifyPayAnyone(accountHolder: String?, accountNumber: String?, bsb: String, completion: @escaping (Result<VerifyPayAnyoneResponse, Error>) -> Void) {
        
        let request = APIVerifyPayAnyoneRequest(accountHolder: accountHolder, accountNumber: accountNumber, bsb: bsb)
        
        service.verifyPayAnyone(request: request) { result in
            switch result {
                case .failure(let error):
                    error.logError()
                    
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                case .success(let response):
                    
                    DispatchQueue.main.async {
                        completion(.success(response))
                    }
            }
        }
    }
    
    /**
     Verify PayID
     
     - parameters:
     - payID: Value of the PayID
     - type: Type of the PayID
     - completion: Optional completion handler with `VerifyPayIDResponse` result if succeeds and error if the request fails
     */
    public func verifyPayID(payID: String, type: PayIDContact.PayIDType, completion: @escaping (Result<VerifyPayIDResponse, Error>) -> Void) {
        
        let request = APIVerifyPayIDRequest(payID: payID, type: type)
        
        service.verifyPayID(request: request) { result in
            switch result {
                case .failure(let error):
                    error.logError()
                    
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                case .success(let response):
                    
                    DispatchQueue.main.async {
                        completion(.success(response))
                    }
            }
        }
    }
    
    public func verifyBSB(_ bsb: String, completion: @escaping (Result<VerifyBSBResponse, Error>) -> Void) {
        service.verifyBSB(bsb) { result in
            switch result {
                case .failure(let error):
                    error.logError()
                    
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                case .success(let response):
                    
                    DispatchQueue.main.async {
                        completion(.success(response))
                    }
            }
        }
        
    }
    
}
