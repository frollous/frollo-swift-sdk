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
 PayAnyone Contact
 
 Contact of type Pay Anyone and associated properties
 */
public class PayAnyoneContact: Contact {
    
    internal override func update(response: APIContactResponse, context: NSManagedObjectContext) {
        super.update(response: response, context: context)
        
        guard case .payAnyone(let contact) = response.contactDetailsType else {
            return
        }
        
        accountHolder = contact.accountHolder
        bsb = contact.bsb
        accountNumber = contact.accountNumber
    }
    
}
