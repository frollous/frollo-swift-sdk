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

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReportTransactionCurrent> {
        return NSFetchRequest<ReportTransactionCurrent>(entityName: "ReportTransactionCurrent")
    }

    @NSManaged public var amount: NSDecimalNumber?
    @NSManaged public var average: NSDecimalNumber?
    @NSManaged public var budget: NSDecimalNumber?
    @NSManaged public var budgetCategoryRawValue: String?
    @NSManaged public var day: Int64
    @NSManaged public var groupingRawValue: String
    @NSManaged public var linkedID: Int64
    @NSManaged public var name: String?
    @NSManaged public var previous: NSDecimalNumber?
    @NSManaged public var merchant: Merchant?
    @NSManaged public var transactionCategory: TransactionCategory?
    @NSManaged public var reports: NSSet?
    @NSManaged public var overall: ReportTransactionCurrent?

}

// MARK: Generated accessors for reports
extension ReportTransactionCurrent {

    @objc(addReportsObject:)
    @NSManaged public func addToReports(_ value: ReportTransactionCurrent)

    @objc(removeReportsObject:)
    @NSManaged public func removeFromReports(_ value: ReportTransactionCurrent)

    @objc(addReports:)
    @NSManaged public func addToReports(_ values: NSSet)

    @objc(removeReports:)
    @NSManaged public func removeFromReports(_ values: NSSet)

}
