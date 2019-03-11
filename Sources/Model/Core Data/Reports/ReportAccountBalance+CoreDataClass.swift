//
// Copyright © 2019 Frollo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//

import CoreData
import Foundation

/**
 Account Balance Report
 
 Core Data model of an account balance report
 */
public class ReportAccountBalance: NSManagedObject {
    
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
