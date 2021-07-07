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

struct APIPaymentTransferRequest: Codable {
    
    enum CodingKeys: String, CodingKey {
        case amount
        case description
        case destinationAccountID = "destination_account_id"
        case paymentDate = "payment_date"
        case sourceAccountID = "source_account_id"
    }
    
    let amount: String
    let description: String?
    let destinationAccountID: Int64
    let paymentDate: String?
    let sourceAccountID: Int64
    
}
