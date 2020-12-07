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

struct APIContactResponse: APIUniqueResponse {
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdDate = "created_date"
        case modifiedDate = "modified_date"
        case verified
        case relatedProviderAccountIDs = "related_provider_account_ids"
        case name
        case nickName = "nick_name"
        case contactDescription = "description"
        case contactType = "payment_method"
        case contactDetailsType = "payment_details"
    }
    
    enum ContactDetailsType {
        
        struct PayAnyone: Codable {
            
            enum CodingKeys: String, CodingKey {
                case accountHolder = "account_holder"
                case bsb
                case accountNumber = "account_number"
            }
            
            let accountHolder: String
            let bsb: String
            let accountNumber: String
            
        }
        
        struct Biller: Codable {
            enum CodingKeys: String, CodingKey {
                case billerCode = "biller_code"
                case crn
                case billerName = "biller_name"
            }
            
            let billerCode: String
            let crn: String
            let billerName: String
        }
        
        struct PayID: Codable {
            enum CodingKeys: String, CodingKey {
                case payid
                case name
                case idType = "id_type"
            }
            
            let payid: String
            let name: String?
            let idType: PayIDContact.PayIDType
        }
        
        struct International: Codable {
            
            struct Beneficiary: Codable {
                enum CodingKeys: String, CodingKey {
                    case name
                    case country
                    case message
                }
                
                let name: String?
                let country: String
                let message: String?
            }
            
            struct BankAddress: Codable {
                enum CodingKeys: String, CodingKey {
                    case address
                }
                
                let address: String
            }
            
            struct BankDetails: Codable {
                
                enum CodingKeys: String, CodingKey {
                    case country
                    case accountNumber = "account_number"
                    case bankAddress = "bank_address"
                    case bic
                    case fedwireNumber = "fed_wire_number"
                    case sortCode = "sort_code"
                    case chipNumber = "chip_number"
                    case routingNumber = "routing_number"
                    case legalEntityIdentifier = "legal_entity_identifier"
                }
                
                let country: String
                let accountNumber: String
                let bankAddress: BankAddress?
                let bic: String?
                let fedwireNumber: String?
                let sortCode: String?
                let chipNumber: String?
                let routingNumber: String?
                let legalEntityIdentifier: String?
            }
            
            enum CodingKeys: String, CodingKey {
                case beneficiary
                case bankDetails = "bank_details"
            }
            
            let beneficiary: Beneficiary
            let bankDetails: BankDetails
        }
        
        case payAnyone(PayAnyone)
        case BPAY(Biller)
        case payID(PayID)
        case international(International)
        
    }
    
    var id: Int64
    let createdDate: String
    let modifiedDate: String
    let verified: Bool
    let relatedProviderAccountIDs: [Int64]?
    let name: String?
    let nickName: String
    let contactDescription: String?
    let contactType: Contact.ContactType
    let contactDetailsType: ContactDetailsType?
    
}

extension APIContactResponse: Codable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int64.self, forKey: .id)
        createdDate = try container.decode(String.self, forKey: .createdDate)
        modifiedDate = try container.decode(String.self, forKey: .modifiedDate)
        contactType = try container.decode(Contact.ContactType.self, forKey: .contactType)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        nickName = try container.decode(String.self, forKey: .nickName)
        contactDescription = try container.decodeIfPresent(String.self, forKey: .contactDescription)
        verified = try container.decode(Bool.self, forKey: .verified)
        relatedProviderAccountIDs = try container.decodeIfPresent([Int64].self, forKey: .relatedProviderAccountIDs)
        
        switch contactType {
            case .payAnyone:
                let contents = try container.decode(ContactDetailsType.PayAnyone.self, forKey: .contactDetailsType)
                self.contactDetailsType = .payAnyone(contents)
                
            case .payID:
                let contents = try container.decode(ContactDetailsType.PayID.self, forKey: .contactDetailsType)
                self.contactDetailsType = .payID(contents)
                
            case .BPAY:
                let contents = try container.decode(ContactDetailsType.Biller.self, forKey: .contactDetailsType)
                self.contactDetailsType = .BPAY(contents)
                
            case .international:
                let contents = try container.decode(ContactDetailsType.International.self, forKey: .contactDetailsType)
                self.contactDetailsType = .international(contents)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(modifiedDate, forKey: .modifiedDate)
        try container.encode(contactType, forKey: .contactType)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encode(nickName, forKey: .nickName)
        try container.encodeIfPresent(contactDescription, forKey: .contactDescription)
        try container.encode(verified, forKey: .verified)
        try container.encodeIfPresent(relatedProviderAccountIDs, forKey: .relatedProviderAccountIDs)
        
        if let contactDetails = contactDetailsType {
            switch contactDetails {
                case .payAnyone(let payload):
                    try container.encode(payload, forKey: .contactDetailsType)
                    
                case .payID(let payload):
                    try container.encode(payload, forKey: .contactDetailsType)
                    
                case .BPAY(let payload):
                    try container.encode(payload, forKey: .contactDetailsType)
                    
                case .international(let payload):
                    try container.encode(payload, forKey: .contactDetailsType)
                    
            }
        }
    }
    
}
