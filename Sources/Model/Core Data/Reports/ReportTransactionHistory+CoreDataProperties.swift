//
//  ReportTransactionHistory+CoreDataProperties.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 14/1/19.
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
    @NSManaged public var categoryID: Int64
    @NSManaged public var dateString: String
    @NSManaged public var fromDateString: String?
    @NSManaged public var groupingRawValue: String
    @NSManaged public var name: String?
    @NSManaged public var periodRawValue: String
    @NSManaged public var toDateString: String?
    @NSManaged public var value: NSDecimalNumber?
    @NSManaged public var categoryReports: NSSet?
    @NSManaged public var overall: ReportTransactionHistory?

}

// MARK: Generated accessors for categoryReports
extension ReportTransactionHistory {

    @objc(addCategoryReportsObject:)
    @NSManaged public func addToCategoryReports(_ value: ReportTransactionHistory)

    @objc(removeCategoryReportsObject:)
    @NSManaged public func removeFromCategoryReports(_ value: ReportTransactionHistory)

    @objc(addCategoryReports:)
    @NSManaged public func addToCategoryReports(_ values: NSSet)

    @objc(removeCategoryReports:)
    @NSManaged public func removeFromCategoryReports(_ values: NSSet)

}
