//
//  ReportTransactionHistory+CoreDataProperties.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 11/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//
//

import Foundation
import CoreData


extension ReportTransactionHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReportTransactionHistory> {
        return NSFetchRequest<ReportTransactionHistory>(entityName: "ReportTransactionHistory")
    }

    @NSManaged public var dateString: String
    @NSManaged public var value: NSDecimalNumber?
    @NSManaged public var budget: NSDecimalNumber?
    @NSManaged public var name: String?
    @NSManaged public var categoryID: Int64
    @NSManaged public var overall: Bool
    @NSManaged public var groupingRawValue: String
    @NSManaged public var periodRawValue: String
    @NSManaged public var fromDateString: String?
    @NSManaged public var toDateString: String?
    @NSManaged public var budgetCategoryRawValue: String?

}
