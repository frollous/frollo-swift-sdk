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
import SwiftyJSON

/**
 Contact
 
 Core Data represenation of a payment contact
 */
public class Contact: NSManagedObject, UniqueManagedObject {
    
    internal var primaryID: Int64 {
        return contactID
    }
    
    /**
     Contact Type
     
     Indicates the type of the contact
     */
    public enum ContactType: String, CaseIterable, Codable {
        
        /// The contact is of type pay anyone; has account number and bsb
        case payAnyone = "pay_anyone"
        
        /// The contact is of type payID
        case payID = "pay_id"
        
        /// The contact is of type pay anyone; has biller code and crn
        case BPAY = "bpay"
        
        /// The contact is of international type
        case international
        
    }
    
    /// Core Data entity description name
    static var entityName = "Contact"
    
    internal static var primaryKey = #keyPath(Contact.contactID)
    
    /// Type of content the contact, indicates `Contact` subentity
    public var contactType: ContactType {
        get {
            return ContactType(rawValue: contactTypeRawValue)!
        }
        set {
            contactTypeRawValue = newValue.rawValue
        }
    }
    
    /// An array of Provider Account IDs related to the contact. (Optional)
    public var associatedProviderAccountIDs: [Int64]? {
        get {
            if let providerAccountIDsData = providerAccountIDsRawValue {
                let decoder = JSONDecoder()
                
                do {
                    let providerAccountIDs = try decoder.decode([Int64].self, from: providerAccountIDsData)
                    return providerAccountIDs
                } catch {
                    error.logError()
                }
            }
            return nil
        }
        set {
            if let newRawValue = newValue {
                let encoder = JSONEncoder()
                do {
                    providerAccountIDsRawValue = try encoder.encode(newRawValue)
                } catch {
                    providerAccountIDsRawValue = nil
                }
            } else {
                providerAccountIDsRawValue = nil
            }
        }
    }
    
    // MARK: Updating Object
    
    internal func linkObject(object: NSManagedObject) {
        // Do nothing
    }
    
    internal func update(response: APIUniqueResponse, context: NSManagedObjectContext) {
        if let contactsResponse = response as? APIContactResponse {
            update(response: contactsResponse, context: context)
        }
    }
    
    internal func update(response: APIContactResponse, context: NSManagedObjectContext) {
        contactID = response.id
        createdDateString = response.createdDate
        modifiedDateString = response.modifiedDate
        isVerified = response.verified
        name = response.name
        nickName = response.nickName
        contactDescription = response.contactDescription
        contactType = response.contactType
        associatedProviderAccountIDs = response.relatedProviderAccountIDs
    }
    
}
