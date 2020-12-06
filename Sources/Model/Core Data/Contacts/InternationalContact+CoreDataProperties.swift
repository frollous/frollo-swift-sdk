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

extension InternationalContact {
    
    /**
     Fetch Request
     
     - returns: Fetch request for `InternationalContact` type
     */
    @nonobjc public class func fetchRequest() -> NSFetchRequest<InternationalContact> {
        return NSFetchRequest<InternationalContact>(entityName: "InternationalContact")
    }
    
    /// Name of the International contact
    @NSManaged public var internationalContactName: String?
    
    /// Country of the International contact
    @NSManaged public var internationalContactCountry: String
    
    /// Description of the International contact
    @NSManaged public var internationalContactMessage: String?

    /// Country of bank of the International contact
    @NSManaged public var internationalBankCountry: String

    /// Account number of the International contact
    @NSManaged public var internationalAccountNumber: String

    /// Bank Address of the International contact
    @NSManaged public var internationalBankAddress: String?

    /// BIC of the International contact
    @NSManaged public var bic: String?

    /// Fedwire number of the International contact
    @NSManaged public var fedwireNumber: String?

    /// Sort code of the International contact
    @NSManaged public var sortCode: String?

    /// Chip number of the International contact
    @NSManaged public var chipNumber: String?

    /// Routing number of the International contact
    @NSManaged public var routingNumber: String?

    /// Legal entity identifier of the International contact
    @NSManaged public var legalEntityId: String?

}
