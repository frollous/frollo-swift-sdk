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

struct APICardResponse: APIUniqueResponse, Codable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case accountID = "account_id"
        case status
        case designType = "design_type"
        case createdAt = "created_at"
        case name
        case nickName = "nick_name"
        case cancelledAt = "cancelled_at"
        case type
        case panLastDigits = "pan_last_digits"
        case expiryDate = "expiry_date"
        case cardholderName = "cardholder_name"
        case issuer
        case pinSetAt = "pin_set_at"
    }
    
    var id: Int64
    let accountID: Int64
    let status: Card.CardStatus
    let designType: Card.CardDesignType
    let createdAt: Date
    let name: String?
    let nickName: String?
    let cancelledAt: Date?
    let type: String?
    let panLastDigits: String?
    let expiryDate: String?
    let cardholderName: String?
    let issuer: String?
    let pinSetAt: String?
}
