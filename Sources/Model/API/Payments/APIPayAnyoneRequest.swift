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

struct APIPayAnyoneRequest: Codable {
    
    enum CodingKeys: String, CodingKey {
        case accountHolder = "account_holder"
        case accountNumber = "account_number"
        case amount
        case bsb
        case description
        case paymentDate = "payment_date"
        case reference
        case sourceAccountID = "source_account_id"
    }
    
    let accountHolder: String
    let accountNumber: String
    let amount: String
    let bsb: String
    let description: String?
    let paymentDate: String?
    let reference: String?
    let sourceAccountID: Int64
    
}
