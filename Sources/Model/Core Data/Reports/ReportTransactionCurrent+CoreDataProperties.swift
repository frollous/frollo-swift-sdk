//
//  ReportTransactionCurrent+CoreDataProperties.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 11/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//
//

import Foundation
import CoreData


extension ReportTransactionCurrent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReportTransactionCurrent> {
        return NSFetchRequest<ReportTransactionCurrent>(entityName: "ReportTransactionCurrent")
    }

    @NSManaged public var groupingRawValue: String
    @NSManaged public var budgetCategoryRawValue: String?
    @NSManaged public var day: Int64
    @NSManaged public var amount: NSDecimalNumber?
    @NSManaged public var previous: NSDecimalNumber?
    @NSManaged public var average: NSDecimalNumber?
    @NSManaged public var budget: NSDecimalNumber?
    @NSManaged public var name: String?
    @NSManaged public var merchantID: Int64

}
