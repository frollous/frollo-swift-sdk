//
//  ReportTransactionCurrent+CoreDataProperties.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 15/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//
//

import Foundation
import CoreData


extension ReportTransactionCurrent {

    /**
     Fetch Request
     
     - returns: Fetch request for `ReportTransactionCurrent` type
     */
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReportTransactionCurrent> {
        return NSFetchRequest<ReportTransactionCurrent>(entityName: "ReportTransactionCurrent")
    }

    /// Spend
    @NSManaged public var amount: NSDecimalNumber?
    
    /// Average amount from last 3 months
    @NSManaged public var average: NSDecimalNumber?
    
    /// Budgeted amount (Optional)
    @NSManaged public var budget: NSDecimalNumber?
    
    /// Raw value of the filtered budget category. Use only in predicates (Optional)
    @NSManaged public var budgetCategoryRawValue: String?
    
    /// Day of the month
    @NSManaged public var day: Int64
    
    /// Raw value of the report grouping
    @NSManaged public var groupingRawValue: String
    
    /// Unique ID of the related object. E.g. merchant or category. -1 Represents no link or overall report
    @NSManaged public var linkedID: Int64
    
    /// Name of the related object (Optional)
    @NSManaged public var name: String?
    
    /// Previous month spend
    @NSManaged public var previous: NSDecimalNumber?
    
    /// Related merchant (Optional)
    @NSManaged public var merchant: Merchant?
    
    /// Related transaction category (Optional)
    @NSManaged public var transactionCategory: TransactionCategory?

}
