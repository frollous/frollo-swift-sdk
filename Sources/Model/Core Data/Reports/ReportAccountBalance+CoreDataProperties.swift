//
//  ReportAccountBalance+CoreDataProperties.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 25/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//
//

import Foundation
import CoreData


extension ReportAccountBalance {

    /**
     Fetch Request
     
     - returns: Fetch request for `ReportTransactionHistory` type
     */
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReportAccountBalance> {
        return NSFetchRequest<ReportAccountBalance>(entityName: "ReportAccountBalance")
    }

    /// Related account ID. -1 if none linked
    @NSManaged public var accountID: Int64
    
    /// Currency of the report. ISO 4217 code
    @NSManaged public var currency: String
    
    /// Raw value of the date. Use only in predicates
    @NSManaged public var dateString: String
    
    /// Raw value of the period. Use only in predicates
    @NSManaged public var periodRawValue: String
    
    /// Balance of the report
    @NSManaged public var value: NSDecimalNumber?
    
    /// Related account (Optional)
    @NSManaged public var account: Account?

}
