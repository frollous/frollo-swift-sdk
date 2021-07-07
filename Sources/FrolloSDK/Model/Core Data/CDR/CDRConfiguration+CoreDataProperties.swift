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

extension CDRConfiguration {
    
    /**
     Fetch Request
     
     - returns: Fetch request for `CDRConfiguration` type
     */
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDRConfiguration> {
        return NSFetchRequest<CDRConfiguration>(entityName: "CDRConfiguration")
    }
    
    /// The email to contact for support
    @NSManaged public var supportEmail: String
    
    /// The id of the ADR that handles CDR data
    @NSManaged public var adrID: String
    
    /// The name of the ADR that handles CDR data
    @NSManaged public var adrName: String
    
    /// The raw sharing durations JSON data
    @NSManaged public var sharingDurationRawValue: Data
    
    /// The raw Consent permissions JSON data
    @NSManaged public var permissionObjectsRawValue: Data?
    
}
