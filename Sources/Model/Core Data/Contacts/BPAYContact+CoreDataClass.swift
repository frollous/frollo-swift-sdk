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
 BPAY Contact
 
 Contact of type BPAY and associated properties
 */
public class BPAYContact: Contact {
    
    /**
     CRN Type
     
     Indicates the type of the Biller CRN
     */
    public enum CRNType: String, CaseIterable, Codable {
        case fixed = "fixed_crn"
        case variable = "variable_crn"
        case intelligent = "intelligent_crn"
    }
    
    /// Type of  the PayID contact, indicates `PayIDContact` subentity
    public var crnType: CRNType {
        get {
            return CRNType(rawValue: crnTypeRawValue)!
        }
        set {
            crnTypeRawValue = newValue.rawValue
        }
    }
    
    internal override func update(response: APIContactResponse, context: NSManagedObjectContext) {
        super.update(response: response, context: context)
        
        guard case .BPAY(let contact) = response.contactDetailsType else {
            return
        }
        
        billerCode = contact.billerCode
        crn = contact.crn
        billerName = contact.billerName
        crnType = contact.crnType
    }
    
}
