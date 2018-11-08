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

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var dateOfBirth: Date?
    @NSManaged public var email: String?
    @NSManaged public var emailVerified: Bool
    @NSManaged public var facebookID: String?
    @NSManaged public var featuresRawValue: Data?
    @NSManaged public var firstName: String?
    @NSManaged public var genderRawValue: String?
    @NSManaged public var householdSize: Int64
    @NSManaged public var householdTypeRawValue: String?
    @NSManaged public var industryRawValue: String?
    @NSManaged public var lastName: String?
    @NSManaged public var occupationRawValue: String?
    @NSManaged public var postcode: String?
    @NSManaged public var primaryCurrency: String?
    @NSManaged public var statusRawValue: String?
    @NSManaged public var userID: Int64
    @NSManaged public var validPassword: Bool

}
