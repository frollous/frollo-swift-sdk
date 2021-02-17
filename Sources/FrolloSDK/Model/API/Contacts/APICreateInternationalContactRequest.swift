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

struct APICreateInternationalContactRequest: Codable {
    
    struct InternationalPaymentDetails: Codable {
        enum CodingKeys: String, CodingKey {
            case name
            case country
            case message
            case bankcountry = "bank_country"
            case accountNumber = "account_number"
            case bankAddress = "bank_address"
            case bic
            case fedwireNumber = "fed_wire_number"
            case sortCode = "sort_code"
            case chipNumber = "chip_number"
            case routingNumber = "routing_number"
            case legalEntityIdentifier = "legal_entity_identifier"
        }
        
        let name: String?
        let country: String
        let message: String?
        let bankcountry: String
        let accountNumber: String
        let bankAddress: String?
        let bic: String?
        let fedwireNumber: String?
        let sortCode: String?
        let chipNumber: String?
        let routingNumber: String?
        let legalEntityIdentifier: String?
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case nickName = "nick_name"
        case description
        case paymentMethod = "payment_method"
        case paymentDetails = "payment_details"
    }
    
    let name: String?
    let nickName: String
    let description: String?
    let paymentMethod: Contact.ContactType = .international
    let paymentDetails: InternationalPaymentDetails
}
