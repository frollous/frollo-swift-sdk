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

extension Address {
    
    /**
     Fetch Request
     
     - returns: Fetch request for `User` type
     */
    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "Address")
    }
    
    /// Attribution ad group of the user (optional)
    @NSManaged public var addressID: Int64
    
    /// Attribution campaign of the user (optional)
    @NSManaged public var buildingName: String?
    
    /// Attribution creative of the user (optional)
    @NSManaged public var country: String
    
    /// Attribution network of the user (optional)
    @NSManaged public var longForm: String?
    
    /// Raw value for current address. Do not use
    @NSManaged public var postcode: String?
    
    /// Date of birth of the user (optional)
    @NSManaged public var region: String?
    
    /// Email address of the user
    @NSManaged public var state: String?
    
    /// User verified their email address
    @NSManaged public var streetName: String?
    
    /// Facebook ID associated with the user (optional)
    @NSManaged public var streetNumber: String?
    
    /// Raw value for features. Do not use
    @NSManaged public var streetType: String?
    
    /// First name of the user
    @NSManaged public var suburb: String?
    
    /// First name of the user
    @NSManaged public var town: String?
    
    /// Foreign tax user
    @NSManaged public var unitNumber: String?
    
}
