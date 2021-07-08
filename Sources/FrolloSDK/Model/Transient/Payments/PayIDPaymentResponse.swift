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
 PayID Payment Response
 
 Represents the response after the Payment to a PayID is successful
 */
public struct PayIDPaymentResponse: Codable {
    
    enum CodingKeys: String, CodingKey {
        case amount
        case description
        case reference
        case paymentDate = "payment_date"
        case destinationAccountHolder = "destination_account_holder"
        case sourceAccountID = "source_account_id"
        case sourceAccountName = "source_account_name"
        case transactionReference = "transaction_reference"
        case status
        case isDuplicate = "is_duplicate"
        case paymentMode = "payment_type"
    }
    
    /// Amount of the the payment
    public let amount: String
    
    /// Description of the the payment
    public let description: String?
    
    /// Reference of the the payment
    public let reference: String?
    
    /// PayID name payee's account in the payment
    public let destinationAccountHolder: String
    
    /// Datet of the payment
    public let paymentDate: String
    
    /// Account ID of source account in the payment
    public let sourceAccountID: Int64
    
    /// Account Name of source account in the payment
    public let sourceAccountName: String
    
    /// Transaction reference of the payment
    public let transactionReference: String
    
    /// Status of the payment
    public let status: String
    
    /// Payment is duplicate; Optional - returned only for NPP
    public let isDuplicate: Bool?
    
    /// Mode with which the payment was made; Optional
    public let paymentMode: String?
}
