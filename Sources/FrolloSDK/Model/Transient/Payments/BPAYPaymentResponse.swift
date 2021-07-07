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

/**
 BPAYPaymentResponse
 
 Represents the response after BPAY payment is successful
 */
public struct BPAYPaymentResponse: Codable {
    
    enum CodingKeys: String, CodingKey {
        case amount
        case billerCode = "biller_code"
        case billerName = "biller_name"
        case crn
        case paymentDate = "payment_date"
        case reference
        case sourceAccountID = "source_account_id"
        case sourceAccountName = "source_account_name"
        case status
        case transactionID = "transaction_id"
        case transactionReference = "transaction_reference"
        case paymentMode = "payment_type"
    }
    
    /// Amount of the the payment
    public let amount: String
    
    /// Biller code of the the Biller
    public let billerCode: String
    
    /// Biller name of the the Biller
    public let billerName: String
    
    /// CRN
    public let crn: String
    
    /// Date of the payment
    public let paymentDate: String
    
    /// reference of the payment
    public let reference: String?
    
    /// Account ID of source account in the payment
    public let sourceAccountID: Int64
    
    /// Account name of source account in the payment
    public let sourceAccountName: String
    
    /// Status of the payment
    public let status: String
    
    /// Transaction ID of the payment
    public let transactionID: Int64?
    
    /// Transaction reference of the payment
    public let transactionReference: String

    /// Mode with which the payment was made; Optional
    public let paymentMode: String?
}
