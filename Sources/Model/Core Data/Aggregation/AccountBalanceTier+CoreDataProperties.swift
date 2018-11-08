//
//  AccountBalanceTier+CoreDataProperties.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 8/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//
//

import Foundation
import CoreData


extension AccountBalanceTier {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AccountBalanceTier> {
        return NSFetchRequest<AccountBalanceTier>(entityName: "AccountBalanceTier")
    }

    @NSManaged public var maximum: NSDecimalNumber?
    @NSManaged public var minimum: NSDecimalNumber?
    @NSManaged public var name: String?
    @NSManaged public var account: Account?

}
