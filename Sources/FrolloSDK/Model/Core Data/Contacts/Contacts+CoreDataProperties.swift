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

extension Contact {
    
    /**
     Fetch Request
     
     - returns: Fetch request for `Contact` type
     */
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Contact> {
        return NSFetchRequest<Contact>(entityName: "Contact")
    }
    
    /// Unique identifier of the contact
    @NSManaged public var contactID: Int64
    
    /// Name of the contact (optional)
    @NSManaged public var name: String?
    
    /// Nick name of the contact
    @NSManaged public var nickName: String
    
    /// Description of the contact (Optional)
    @NSManaged public var contactDescription: String?
    
    /// The type of payment method of contact; eg Biller, PayID etc
    @NSManaged public var contactTypeRawValue: String
    
    /// Date the contact was created
    @NSManaged public var createdDateString: String
    
    /// Date the contact was last updated
    @NSManaged public var modifiedDateString: String
    
    /// Raw value for the associated provider account IDs
    @NSManaged public var providerAccountIDsRawValue: Data?
    
    /// Is contact verified or not
    @NSManaged public var isVerified: Bool
    
}
