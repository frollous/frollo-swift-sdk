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
public struct PayIDPaymentResponse {
    
    /// Amount of the the payment
    public let amount: String
    
    /// Description of the the payment
    public let description: String?
    
    /// BSB of payee's account of the payment
    public let destinationPayID: String
    
    /// Account number of payee's account in the payment
    public let destinationPayIDType: PayIDContact.PayIDType
    
    /// PayID name payee's account in the payment
    public let destinationAccountHolder: String
    
    /// Datet of the payment
    public let paymentDate: String
    
    /// Account ID of source account in the payment
    public let sourceAccountID: Int64
    
    /// Transaction ID of the payment
    public let transactionID: String
    
}
