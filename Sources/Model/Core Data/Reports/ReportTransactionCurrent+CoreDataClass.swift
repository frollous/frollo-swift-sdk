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
 Transaction Report: Current
 
 Core Data model of a current transaction report
 */
public class ReportTransactionCurrent: NSManagedObject {
    
    /// Linked budget category if applicable. See `grouping`
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
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month], from: Date())
        dateComponents.day = Int(day)
        return calendar.date(from: dateComponents)
    }
    
    /// Filter Budget Category - indicates the Budget Category the reports were filtered by (Optional)
    public var filterBudgetCategory: BudgetCategory? {
        get {
            if let rawValue = filterBudgetCategoryRawValue {
                return BudgetCategory(rawValue: rawValue)
            } else {
                return nil
            }
        }
        set {
            filterBudgetCategoryRawValue = newValue?.rawValue
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
