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

struct APICreateContactRequest: Codable {
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
    let paymentMethod: Contact.ContactType
    let paymentDetails: PaymentDetails
    
    init(name: String?, nickName: String, description: String?, type: Contact.ContactType, details: PaymentDetails) {
        self.name = name
        self.nickName = nickName
        self.description = description
        self.paymentMethod = type
        self.paymentDetails = details
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decodeIfPresent(String.self, forKey: .name)
        nickName = try container.decode(String.self, forKey: .nickName)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        paymentMethod = try container.decode(Contact.ContactType.self, forKey: .paymentMethod)
        
        switch paymentMethod {
            case .payAnyone:
                let contents = try container.decode(PaymentDetails.PayAnyone.self, forKey: .paymentDetails)
                self.paymentDetails = .payAnyone(contents)
                
            case .payID:
                let contents = try container.decode(PaymentDetails.PayID.self, forKey: .paymentDetails)
                self.paymentDetails = .payID(contents)
                
            case .BPAY:
                let contents = try container.decode(PaymentDetails.Biller.self, forKey: .paymentDetails)
                self.paymentDetails = .BPAY(contents)
                
            case .international:
                let contents = try container.decode(PaymentDetails.International.self, forKey: .paymentDetails)
                self.paymentDetails = .international(contents)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(name, forKey: .name)
        try container.encode(nickName, forKey: .nickName)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(paymentMethod, forKey: .paymentMethod)
        
        switch paymentDetails {
            case .payAnyone(let payload):
                try container.encode(payload, forKey: .paymentDetails)
                
            case .payID(let payload):
                try container.encode(payload, forKey: .paymentDetails)
                
            case .BPAY(let payload):
                try container.encode(payload, forKey: .paymentDetails)
                
            case .international(let payload):
                try container.encode(payload, forKey: .paymentDetails)
                
        }
    }
}
