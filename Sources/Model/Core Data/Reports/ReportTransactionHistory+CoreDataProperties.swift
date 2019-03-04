//
//  ReportTransactionHistory+CoreDataProperties.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 15/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//
//

import CoreData
import Foundation

extension ReportTransactionHistory {
    
    /**
     Fetch Request
     
     - returns: Fetch request for `ReportTransactionHistory` type
     */
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReportTransactionHistory> {
        return NSFetchRequest<ReportTransactionHistory>(entityName: "ReportTransactionHistory")
    }
    
    /// Budget value for the report (Optional)
    @NSManaged public var budget: NSDecimalNumber?
    
    /// Raw value of the linked budget category if applicable. Use only in predicates (Optional)
    @NSManaged public var budgetCategoryRawValue: String?
    
    /// Raw value of the filtered budget category. Use only in predicates (Optional)
    @NSManaged public var filterBudgetCategoryRawValue: String?
    
    /// Unique ID of the related object. E.g. merchant or category. -1 Represents no link or overall report
    @NSManaged public var linkedID: Int64
    
    /// Raw value of the date. Use only in predicates
    @NSManaged public var dateString: String
    
    /// Raw value of the report grouping. Use only in predicates
    @NSManaged public var groupingRawValue: String
    
    /// Name of the related object (Optional)
    @NSManaged public var name: String?
    
    /// Raw value of the report period. Use only in predicates
    @NSManaged public var periodRawValue: String
    
    /// Value of the report
    @NSManaged public var value: NSDecimalNumber?
    
    /// Breakdown reports if this is an overall report (Optional)
    @NSManaged public var reports: NSSet?
    
    /// Parent overall report if this is a breakdown report (Optional)
    @NSManaged public var overall: ReportTransactionHistory?
    
    /// Related transaction category (Optional)
    @NSManaged public var transactionCategory: TransactionCategory?
    
    /// Related merchant (Optional)
    @NSManaged public var merchant: Merchant?
    
}

// MARK: Generated accessors for reports

extension ReportTransactionHistory {
    
    /// Add a transaction history report relationship
    @objc(addReportsObject:)
    @NSManaged public func addToReports(_ value: ReportTransactionHistory)
    
    /// Remove a transaction history report relationship
    @objc(removeReportsObject:)
    @NSManaged public func removeFromReports(_ value: ReportTransactionHistory)
    
    /// Add transaction history report relationships
    @objc(addReports:)
    @NSManaged public func addToReports(_ values: NSSet)
    
    /// Remove transaction history report relationships
    @objc(removeReports:)
    @NSManaged public func removeFromReports(_ values: NSSet)
    
}
