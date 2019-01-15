//
//  ReportTransactionHistory+CoreDataProperties.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 15/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//
//

import Foundation
import CoreData


extension ReportTransactionHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReportTransactionHistory> {
        return NSFetchRequest<ReportTransactionHistory>(entityName: "ReportTransactionHistory")
    }

    @NSManaged public var budget: NSDecimalNumber?
    @NSManaged public var budgetCategoryRawValue: String?
    @NSManaged public var linkedID: Int64
    @NSManaged public var dateString: String
    @NSManaged public var groupingRawValue: String
    @NSManaged public var name: String?
    @NSManaged public var periodRawValue: String
    @NSManaged public var value: NSDecimalNumber?
    @NSManaged public var reports: NSSet?
    @NSManaged public var overall: ReportTransactionHistory?
    @NSManaged public var transactionCategory: TransactionCategory?
    @NSManaged public var merchant: Merchant?

}

// MARK: Generated accessors for reports
extension ReportTransactionHistory {

    @objc(addReportsObject:)
    @NSManaged public func addToReports(_ value: ReportTransactionHistory)

    @objc(removeReportsObject:)
    @NSManaged public func removeFromReports(_ value: ReportTransactionHistory)

    @objc(addReports:)
    @NSManaged public func addToReports(_ values: NSSet)

    @objc(removeReports:)
    @NSManaged public func removeFromReports(_ values: NSSet)

}
