//
// Copyright © 2018 Frollo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//

import CoreData
import Foundation

extension Consent {
    
    /**
     Fetch Request
     
     - returns: Fetch request for `Consent` type
     */
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Consent> {
        return NSFetchRequest<Consent>(entityName: "Consent")
    }
    
    /// Unique ID of the consent
    @NSManaged public var consentID: Int64
    
    /// Raw value for the additional permissions. Use only in predicates (Optional)
    @NSManaged public var additionalPermissionsRawValue: Data?
    
    /// The url used to login with the provider (Optional)
    @NSManaged public var authorizationURLString: String?
    
    /// The confirmation PDF generated after the consent becomes active (Optional)
    @NSManaged public var confirmationPDFURLString: String?
    
    /// Raw value for the permissions. Use only in predicates (Optional)
    @NSManaged public var permissionObjectsRawValue: Data?
    
    /// The provider account ID related to the consent
    @NSManaged public var providerAccountID: Int64
    
    /// The provider ID related to the consent
    @NSManaged public var providerID: Int64
    
    /// The duration (in seconds) of the sharing
    @NSManaged public var sharingDurationRawValue: Int64
    
    /// Raw value of the consent started at date. Use only in predicates (Optional)
    @NSManaged public var sharingStartedAtRawValue: String?
    
    /// Raw value of the consent stopped at date. Use only in predicates (Optional)
    @NSManaged public var sharingStoppedAtRawValue: String?
    
    /// Raw value for the status. Use only in predicates
    @NSManaged public var statusRawValue: String
    
    /// The PDF URL string that contains the withdrawal information (Optional)
    @NSManaged public var withdrawalPDFURLString: String?
    
    /// The provider associated with the consent (Optional)
    @NSManaged public var provider: Provider?
    
    /// The provider account associated with the consent (Optional)
    @NSManaged public var providerAccount: ProviderAccount?
    
}
