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
 International Contact
 
 Contact of type International and associated properties
 */
public class InternationalContact: Contact {
    
    internal override func update(response: APIContactResponse, context: NSManagedObjectContext) {
        super.update(response: response, context: context)
        
        guard case .international(let contact) = response.contactDetailsType else {
            return
        }
        
        internationalContactName = contact.name
        internationalContactCountry = contact.country
        internationalContactMessage = contact.message
        internationalBankCountry = contact.bankCountry
        internationalAccountNumber = contact.accountNumber
        internationalBankAddress = contact.bankAddress?.name
        bic = contact.bic
        fedwireNumber = contact.fedwireNumber
        sortCode = contact.sortCode
        chipNumber = contact.chipNumber
        routingNumber = contact.routingNumber
        legalEntityId = contact.legalEntityIdentifier
    }
    
}
