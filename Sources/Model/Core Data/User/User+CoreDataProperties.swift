//
//  User+CoreDataProperties.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 8/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//
//

import Foundation
import CoreData


extension User {

    /**
     Fetch Request
     
     - returns: Fetch request for `User` type
     */
    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

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
    @NSManaged public var firstName: String
    
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
    
    /// Raw value of occupation. Use only in predicates (optional)
    @NSManaged public var occupationRawValue: String?
    
    /// Postcode (optional)
    @NSManaged public var postcode: String?
    
    /// Primary currency ISO code associated with the user
    @NSManaged public var primaryCurrency: String
    
    /// Raw value of the user status. Use only in predicates
    @NSManaged public var statusRawValue: String
    
    /// Unique ID of the user
    @NSManaged public var userID: Int64
    
    /// User has a valid password
    @NSManaged public var validPassword: Bool

}
