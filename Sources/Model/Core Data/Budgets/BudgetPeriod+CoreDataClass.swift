//
//  Copyright © 2018 Frollo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import CoreData
import Foundation

/**
 Budget Period
 
 Core Data model of the budget period.
 */
public class BudgetPeriod: NSManagedObject, UniqueManagedObject {
    
    /// Core Data entity description name
    static var entityName = "BudgetPeriod"
    
    internal static var primaryKey = #keyPath(BudgetPeriod.budgetPeriodID)
    
    /// Date formatter to convert from stored date string to user's current locale
    public static let budgetPeriodDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    internal var primaryID: Int64 {
        return budgetPeriodID
    }
    
    /// End date of the budget
    public var endDate: Date {
        get {
            return BudgetPeriod.budgetPeriodDateFormatter.date(from: endDateString)!
        }
        set {
            endDateString = BudgetPeriod.budgetPeriodDateFormatter.string(from: newValue)
        }
    }
    
    /// Date the budget starts
    public var startDate: Date {
        get {
            return BudgetPeriod.budgetPeriodDateFormatter.date(from: startDateString)!
        }
        set {
            startDateString = BudgetPeriod.budgetPeriodDateFormatter.string(from: newValue)
        }
    }
    
    /// Tracking Status (Optional)
    public var trackingStatus: Budget.TrackingStatus? {
        get {
            if let rawValue = trackingStatusRawValue {
                return Budget.TrackingStatus(rawValue: rawValue)
            }
            return nil
        }
        set {
            trackingStatusRawValue = newValue?.rawValue
        }
    }
    
}

extension BudgetPeriod {
    
    internal func update(response: APIUniqueResponse, context: NSManagedObjectContext) {
        if let budgetPeriodResponse = response as? APIBudgetPeriodResponse {
            update(response: budgetPeriodResponse, context: context)
        }
    }
    
    internal func update(response: APIBudgetPeriodResponse, context: NSManagedObjectContext) {
        budgetPeriodID = response.id
        currentAmount = NSDecimalNumber(string: response.currentAmount)
        endDateString = response.endDate
        budgetID = response.budgetID
        index = response.index
        requiredAmount = NSDecimalNumber(string: response.requiredAmount)
        startDateString = response.startDate
        targetAmount = NSDecimalNumber(string: response.targetAmount)
        trackingStatus = response.trackingStatus
    }
    
    internal func linkObject(object: NSManagedObject) {}
    
}
