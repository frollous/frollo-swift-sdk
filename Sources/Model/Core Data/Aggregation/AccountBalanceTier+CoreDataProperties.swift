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

    /**
     Fetch Request
     
     - returns: Fetch request for `AccountBalanceTier` type
     */
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AccountBalanceTier> {
        return NSFetchRequest<AccountBalanceTier>(entityName: "AccountBalanceTier")
    }

    /// Maximum balance value included in this tier (optional)
    @NSManaged public var maximum: NSDecimalNumber?
    
    /// Minimum balance value included in this tier (optional)
    @NSManaged public var minimum: NSDecimalNumber?
    
    /// Name of this tier (optional)
    @NSManaged public var name: String?
    
    /// Parent account
    @NSManaged public var account: Account?

}
