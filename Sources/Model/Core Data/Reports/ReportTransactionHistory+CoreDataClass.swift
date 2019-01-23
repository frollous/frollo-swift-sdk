//
//  ReportTransactionHistory+CoreDataClass.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 11/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//
//

import Foundation
import CoreData

/**
 Transaction Report: History
 
 Core Data model of a history transaction report
 */
public class ReportTransactionHistory: NSManagedObject {
    
    /// Period - the time period the report is broken down to
    public enum Period: String, Codable, CaseIterable {
        
        /// Days
        case day = "by_day"
        
        /// Months
        case month = "by_month"
        
        /// Weeks
        case week = "by_week"
        
    }
    
    /// Date formatter to convert daily date from stored date string to user's current locale
    public static let dailyDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    /// Date formatter to convert monthly date from stored date string to user's current locale
    public static let monthlyDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.dateFormat = "yyyy-MM"
        return dateFormatter
    }()
    
    /// Date formatter to convert weekly date from stored date string to user's current locale
    public static let weeklyDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.dateFormat = "yyyy-MM-W"
        return dateFormatter
    }()
    
    /// Budget category if the report was filtered to a specific category
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
    
    /// Date of the report period
    public var date: Date {
        get {
            switch period {
                case .day:
                    return ReportTransactionHistory.dailyDateFormatter.date(from: dateString)!
                case .month:
                    return ReportTransactionHistory.monthlyDateFormatter.date(from: dateString)!
                case .week:
                    return ReportTransactionHistory.weeklyDateFormatter.date(from: dateString)!
            }
        }
        set {
            switch period {
                case .day:
                    dateString = ReportTransactionHistory.dailyDateFormatter.string(from: newValue)
                case .month:
                    dateString = ReportTransactionHistory.monthlyDateFormatter.string(from: newValue)
                case .week:
                    dateString = ReportTransactionHistory.weeklyDateFormatter.string(from: newValue)
            }
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
    
    /// Period of the report
    public var period: Period {
        get {
            return Period(rawValue: periodRawValue)!
        }
        set {
            periodRawValue = newValue.rawValue
        }
    }

}
