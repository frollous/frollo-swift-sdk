//
//  ReportTransactionCurrent+CoreDataClass.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 11/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//
//

import Foundation
import CoreData

/**
 Transaction Report: Current
 
 Core Data model of a current transaction report
 */
public class ReportTransactionCurrent: NSManagedObject {
    
    /// Budget Category - indicates the Budget Category the reports where filtered by (Optional)
    public var budgetCategory: BudgetCategory? {
        get {
            if let rawValue = budgetCategoryRawValue {
                return BudgetCategory(rawValue: rawValue)
            } else {
                return nil
            }
        }
        set {
            budgetCategoryRawValue = newValue?.rawValue
        }
    }
    
    /// Date - converts the day value of the report to the relevant date in the current month
    public var date: Date? {
        get {
            let calendar = Calendar.current
            var dateComponents = calendar.dateComponents([.year, .month], from: Date())
            dateComponents.day = Int(day)
            return calendar.date(from: dateComponents)
        }
    }

    /// Grouping - how the report response has been broken down
    public var grouping: ReportGrouping {
        get {
            return ReportGrouping(rawValue: groupingRawValue)!
        }
        set {
            groupingRawValue = newValue.rawValue
        }
    }
    
}
