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

import CoreData
import Foundation

/**
 PayID Contact
 
 Contact of type PayID and associated properties
 */
public class PayIDContact: Contact {
    
    /**
     PayID Type
     
     Indicates the type of the payID
     */
    public enum PayIDType: String, CaseIterable, Codable {
        /// Phone number type PayID
        case phoneNumber = "mobile"
        
        /// Email type PayID
        case email
        
        /// Business Name type PayID
        case organisationID = "org_identifier"
        
        /// ABN type PayID
        case abn
    }
    
    /// Type of  the PayID contact, indicates `PayIDContact` subentity
    public var payIDType: PayIDType {
        get {
            return PayIDType(rawValue: payIDTypeRawValue)!
        }
        set {
            payIDTypeRawValue = newValue.rawValue
        }
    }
    
    internal override func update(response: APIContactResponse, context: NSManagedObjectContext) {
        super.update(response: response, context: context)
        
        guard case .payID(let contact) = response.contactDetailsType else {
            return
        }
        
        payID = contact.payid
        payIDName = contact.name
        payIDType = contact.type
    }
    
}
