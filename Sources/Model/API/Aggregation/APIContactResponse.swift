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

public enum ContactType: String, CaseIterable {
    case payAnyone = "pay_anyone"
    case payid
    case bpay
    case international
}

public enum ContactPaymentDetailsType {
    case payAnyone(PayAnyone)
    case payid(Payid)
    case bpay(Bpay)
    case international(International)
    
    public func asPayAnyone() throws -> PayAnyone {
        switch self {
            case .payAnyone(let item):
                return item
            default:
                throw NSError()
        }
    }
    
    public func asPayid() throws -> Payid {
        switch self {
            case .payid(let item):
                return item
            default:
                throw NSError()
        }
    }
    
    public func asBpay() throws -> Bpay {
        switch self {
            case .bpay(let item):
                return item
            default:
                throw NSError()
        }
    }
    
    public func asInternational() throws -> International {
        switch self {
            case .international(let item):
                return item
            default:
                throw NSError()
        }
    }
}

extension ContactPaymentDetailsType {
    public class PayAnyone {
        public let accountHolder: String
        public let bsb: String
        public let accountNumber: String
        
        public init(accountHolder: String, bsb: String, accountNumber: String) {
            self.accountHolder = accountHolder
            self.bsb = bsb
            self.accountNumber = accountNumber
        }
    }
    
    public class Bpay {
        public let billerCode: String
        public let crn: String
        public let billerName: String
        
        public init(billerCode: String, crn: String, billerName: String) {
            self.billerCode = billerCode
            self.crn = crn
            self.billerName = billerName
        }
    }
    
    public class Payid {
        public let payid: String
        public let name: String
        public let idType: String
        
        public init(payid: String, name: String, idType: String) {
            self.payid = payid
            self.name = name
            self.idType = idType
        }
        
    }
    
    public class International {
        public let beneficiary: APIContactResponse.PaymentDetails.Beneficiary
        public let bankDetails: APIContactResponse.PaymentDetails.BankDetails
        
        public init(beneficiary: APIContactResponse.PaymentDetails.Beneficiary, bankDetails: APIContactResponse.PaymentDetails.BankDetails) {
            self.beneficiary = beneficiary
            self.bankDetails = bankDetails
        }
    }
}

public class Contact {
    public let id: Int64
    public let createdDate: String
    public let modifiedDate: String
    public let verified: Bool
    public let relatedProviderAccountIDs: [Int64]?
    public let name: String?
    public let nickName: String
    public let contactDescription: String?
    public let paymentMethod: ContactType
    public let paymentDetails: ContactPaymentDetailsType
    
    static func getPaymentDetails(paymentMethod: ContactType, response: APIContactResponse) -> ContactPaymentDetailsType {
        switch paymentMethod {
            case .payAnyone:
                return .payAnyone(.init(accountHolder: response.paymentDetails.accountHolder!, bsb: response.paymentDetails.bsb!, accountNumber: response.paymentDetails.accountNumber!))
            case .payid:
                return .payid(.init(payid: response.paymentDetails.payid!, name: response.paymentDetails.name!, idType: response.paymentDetails.idType!))
            case .bpay:
                return .bpay(.init(billerCode: response.paymentDetails.billerCode!, crn: response.paymentDetails.crn!, billerName: response.paymentDetails.billerName!))
            case .international:
                return .international(.init(beneficiary: response.paymentDetails.beneficiary!, bankDetails: response.paymentDetails.bankDetails!))
        }
    }
    
    init(response: APIContactResponse) {
        self.id = response.id
        self.createdDate = response.createdDate
        self.modifiedDate = response.modifiedDate
        self.verified = response.verified
        self.relatedProviderAccountIDs = response.relatedProviderAccountIDs
        self.name = response.name
        self.nickName = response.nickName
        self.contactDescription = response.contactDescription
        self.paymentMethod = ContactType(rawValue: response.paymentMethod)!
        self.paymentDetails = Self.getPaymentDetails(paymentMethod: ContactType(rawValue: response.paymentMethod)!, response: response)
    }
}

public class APIContactResponse: APIUniqueResponse, Codable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdDate = "created_date"
        case modifiedDate = "modified_date"
        case verified
        case relatedProviderAccountIDs = "related_provider_account_ids"
        case name
        case nickName = "nick_name"
        case contactDescription = "description"
        case paymentMethod = "payment_method"
        case paymentDetails = "payment_details"
    }
    
    public var id: Int64
    public let createdDate: String
    public let modifiedDate: String
    public let verified: Bool
    public let relatedProviderAccountIDs: [Int64]?
    public let name: String?
    public let nickName: String
    public let contactDescription: String?
    public let paymentMethod: String
    public let paymentDetails: PaymentDetails
    
    public init(id: Int64, createdDate: String, modifiedDate: String, verified: Bool, relatedProviderAccountIDs: [Int64]?, name: String?, nickName: String, contactDescription: String?, paymentMethod: String, paymentDetails: PaymentDetails) {
        self.id = id
        self.createdDate = createdDate
        self.modifiedDate = modifiedDate
        self.verified = verified
        self.relatedProviderAccountIDs = relatedProviderAccountIDs
        self.name = name
        self.nickName = nickName
        self.contactDescription = contactDescription
        self.paymentMethod = paymentMethod
        self.paymentDetails = paymentDetails
    }
}

extension APIContactResponse {
    public class PaymentDetails: Codable {
        
        enum CodingKeys: String, CodingKey {
            case billerCode = "biller_code"
            case crn
            case billerName = "biller_name"
            case accountHolder = "account_holder"
            case bsb
            case accountNumber = "account_number"
            case payid
            case name
            case idType = "id_type"
            case beneficiary
            case bankDetails = "bank_details"
        }
        
        public let billerCode: String?
        public let crn: String?
        public let billerName: String?
        
        public let accountHolder: String?
        public let bsb: String?
        public let accountNumber: String?
        
        public let payid: String?
        public let name: String?
        public let idType: String?
        
        public let beneficiary: Beneficiary?
        public let bankDetails: BankDetails?
        
        public init(billerCode: String?, crn: String?, billerName: String?, accountHolder: String?, bsb: String?, accountNumber: String?, payid: String?, name: String?, idType: String?, beneficiary: Beneficiary?, bankDetails: BankDetails?) {
            self.billerCode = billerCode
            self.crn = crn
            self.billerName = billerName
            self.accountHolder = accountHolder
            self.bsb = bsb
            self.accountNumber = accountNumber
            self.payid = payid
            self.name = name
            self.idType = idType
            self.beneficiary = beneficiary
            self.bankDetails = bankDetails
        }
        
    }
}

extension APIContactResponse.PaymentDetails {
    public class Beneficiary: Codable {
        
        public enum CodingKeys: String, CodingKey {
            case name
            case country
            case message
        }
        
        public let name: String?
        public let country: String?
        public let message: String?
        
        public init(name: String?, country: String?, message: String?) {
            self.name = name
            self.country = country
            self.message = message
        }
    }
    
    public class BankDetails: Codable {
        
        public enum CodingKeys: String, CodingKey {
            case country
            case accountNumber = "account_number"
            case bankAddress = "bank_address"
            case bic
            case fedWireNumber = "fed_wire_number"
            case sortCode = "sort_code"
            case chipNumber = "chip_number"
            case routingNumber = "routing_number"
            case legalEntityIdentifier = "legal_entity_identifier"
        }
        
        public let country: String
        public let accountNumber: String
        public let bankAddress: BankAddress?
        public let bic: String?
        public let fedWireNumber: String?
        public let sortCode: String?
        public let chipNumber: String?
        public let routingNumber: String?
        public let legalEntityIdentifier: String?
        
        public init(country: String, accountNumber: String, bankAddress: BankAddress?, bic: String?, fedWireNumber: String?, sortCode: String?, chipNumber: String?, routingNumber: String?, legalEntityIdentifier: String?) {
            self.country = country
            self.accountNumber = accountNumber
            self.bankAddress = bankAddress
            self.bic = bic
            self.fedWireNumber = fedWireNumber
            self.sortCode = sortCode
            self.chipNumber = chipNumber
            self.routingNumber = routingNumber
            self.legalEntityIdentifier = legalEntityIdentifier
        }
    }
}

extension APIContactResponse.PaymentDetails.BankDetails {
    
    public class BankAddress: Codable {
        
        public enum CodingKeys: String, CodingKey {
            case name
        }
        
        public let name: String
        
        public init(name: String) {
            self.name = name
        }
    }
}
