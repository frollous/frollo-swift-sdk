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
 PayAnyoneResponse
 
 Represents the response after pay anyone is successful
 */
public struct PayAnyoneResponse: Codable {
    
    enum CodingKeys: String, CodingKey {
        case amount
        case description
        case destinationBSB = "destination_bsb"
        case destinationAccountHolder = "destination_account_holder"
        case destinationAccountNumber = "destination_account_number"
        case paymentDate = "payment_date"
        case sourceAccountID = "source_account_id"
        case sourceAccountName = "source_account_name"
        case status
        case transactionID = "transaction_id"
        case transactionReference = "transaction_reference"
        case isDuplicate = "is_duplicate"
    }
    
    /// Amount of the the payment
    public let amount: String
    
    /// Description of the the payment
    public let description: String?
    
    /// BSB of payee's account of the payment
    public let destinationBSB: String?
    
    /// Account name of payee's account in the payment
    public let destinationAccountHolder: String
    
    /// Account number of payee's account in the payment
    public let destinationAccountNumber: String?
    
    /// Datet of the payment
    public let paymentDate: String
    
    /// Account ID of source account in the payment
    public let sourceAccountID: Int64
    
    /// Account name of source account in the payment
    public let sourceAccountName: String
    
    /// Status of the payment
    public let status: String
    
    /// Transaction ID of the payment
    public let transactionID: String?
    
    /// Transaction reference of the payment
    public let transactionReference: String
    
    /// Payment is duplicate; Optional - returned only for NPP
    public let isDuplicate: Bool?
}
