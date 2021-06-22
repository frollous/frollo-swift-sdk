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

extension User {
    
    /**
     Fetch Request
     
     - returns: Fetch request for `User` type
     */
    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }
    
    /// Attribution ad group of the user (optional)
    @NSManaged public var attributionAdGroup: String?
    
    /// Attribution campaign of the user (optional)
    @NSManaged public var attributionCampaign: String?
    
    /// Attribution creative of the user (optional)
    @NSManaged public var attributionCreative: String?
    
    /// Attribution network of the user (optional)
    @NSManaged public var attributionNetwork: String?
    
    /// Raw value for current address. Do not use
    @NSManaged public var addressRawValue: Data?
    
    /// Date of birth of the user (optional)
    @NSManaged public var dateOfBirth: Date?
    
    /// Email address of the user
    @NSManaged public var email: String
    
    /// User verified their email address
    @NSManaged public var emailVerified: Bool
    
    /// Facebook ID associated with the user (optional)
    @NSManaged public var facebookID: String?
    
    /// Raw value for features. Do not use
    @NSManaged public var featuresRawValue: Data?
    
    /// First name of the user
    @NSManaged public var firstName: String?
    
    /// Foreign tax user
    @NSManaged public var foreignTax: Bool
    
    /// Raw value of the user gender. Only use in predicates (optional)
    @NSManaged public var genderRawValue: String?
    
    /// Number of people in the household (optional, -1 is unknown)
    @NSManaged public var householdSize: Int64
    
    /// Raw value of household type. Only use in predicates (optional)
    @NSManaged public var householdTypeRawValue: String?
    
    /// Raw value of industry. Only use in predicates (optional)
    @NSManaged public var industryRawValue: String?
    
    /// Last name of the user (optional)
    @NSManaged public var lastName: String?
    
    /// Raw value for mailing address. Do not use
    @NSManaged public var mailingAddressRawValue: Data?
    
    /// Mobile phone number of the user (optional)
    @NSManaged public var mobileNumber: String?
    
    /// Raw value of occupation. Use only in predicates (optional)
    @NSManaged public var occupationRawValue: String?
    
    /// Primary currency ISO code associated with the user
    @NSManaged public var primaryCurrency: String
    
    /// Raw value for register steps. Do not use
    @NSManaged public var registerStepsRawValue: Data?
    
    /// Raw value of the user status. Use only in predicates
    @NSManaged public var statusRawValue: String
    
    /// Tax residency (optional)
    @NSManaged public var taxResidency: String?
    
    /// Tax file number (optional)
    @NSManaged public var tfn: String?
    
    /// Tax identification number (optional)
    @NSManaged public var tin: String?
    
    /// Unique ID of the user
    @NSManaged public var userID: Int64
    
    /// User has a valid password
    @NSManaged public var validPassword: Bool
    
    /// External ID (Optional)
    @NSManaged public var externalID: String?
    
}
