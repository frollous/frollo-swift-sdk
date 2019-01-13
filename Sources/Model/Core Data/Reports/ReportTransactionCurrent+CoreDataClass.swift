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


public class ReportTransactionCurrent: NSManagedObject {
    
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
    
    public var date: Date? {
        get {
            let calendar = Calendar.current
            var dateComponents = calendar.dateComponents([.year, .month], from: Date())
            dateComponents.day = Int(day)
            return calendar.date(from: dateComponents)
        }
    }

    public var grouping: ReportGrouping {
        get {
            return ReportGrouping(rawValue: groupingRawValue)!
        }
        set {
            groupingRawValue = newValue.rawValue
        }
    }
    
    // MARK: - Update object
    
    
    
}
