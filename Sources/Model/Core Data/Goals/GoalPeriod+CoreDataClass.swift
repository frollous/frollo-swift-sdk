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
//

import CoreData
import Foundation

/**
 Goal Period
 
 Core Data model of the goal period.
 */
public class GoalPeriod: NSManagedObject, UniqueManagedObject {
    
    /// Core Data entity description name
    static var entityName = "GoalPeriod"
    
    internal static var primaryKey = #keyPath(GoalPeriod.goalPeriodID)
    
    /// Date formatter to convert from stored date string to user's current locale
    public static let goalPeriodDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    internal var primaryID: Int64 {
        return goalPeriodID
    }
    
    /// End date of the goal
    public var endDate: Date {
        get {
            return GoalPeriod.goalPeriodDateFormatter.date(from: endDateString)!
        }
        set {
            endDateString = GoalPeriod.goalPeriodDateFormatter.string(from: newValue)
        }
    }
    
    /// Date the goal starts
    public var startDate: Date {
        get {
            return GoalPeriod.goalPeriodDateFormatter.date(from: startDateString)!
        }
        set {
            startDateString = GoalPeriod.goalPeriodDateFormatter.string(from: newValue)
        }
    }
    
    /// Tracking Status (Optional)
    public var trackingStatus: Goal.TrackingStatus? {
        get {
            if let rawValue = trackingStatusRawValue {
                return Goal.TrackingStatus(rawValue: rawValue)
            }
            return nil
        }
        set {
            trackingStatusRawValue = newValue?.rawValue
        }
    }
    
    // MARK: - Updating object
    
    internal func linkObject(object: NSManagedObject) {
        // Nothing to link
    }
    
    internal func update(response: APIUniqueResponse, context: NSManagedObjectContext) {
        if let goalPeriodResponse = response as? APIGoalPeriodResponse {
            update(response: goalPeriodResponse, context: context)
        }
    }
    
    internal func update(response: APIGoalPeriodResponse, context: NSManagedObjectContext) {
        goalPeriodID = response.id
        currentAmount = NSDecimalNumber(string: response.currentAmount)
        endDateString = response.endDate
        goalID = response.goalID
        requiredAmount = NSDecimalNumber(string: response.requiredAmount)
        startDateString = response.startDate
        targetAmount = NSDecimalNumber(string: response.targetAmount)
        trackingStatus = response.trackingStatus
    }
    
}
