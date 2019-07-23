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
 Goal
 
 Core Data model of the goal.
 */
public class Goal: NSManagedObject, UniqueManagedObject {
    
    /**
     Frequency
     
     How often the `GoalPeriod`s occur
     */
    public enum Frequency: String, Codable, CaseIterable {
        
        /// Annually
        case annually
        
        /// Biannually - twice in a year
        case biannually
        
        /// Fortnightly
        case fortnightly
        
        /// Every four weeks
        case fourWeekly = "four_weekly"
        
        /// Monthly
        case monthly
        
        /// Quarterly
        case quarterly
        
        /// Singular
        case singular
        
        /// Weekly
        case weekly
        
    }
    
    /**
     Status
     
     Status of the goal
     */
    public enum Status: String, Codable, CaseIterable {
        
        /// Active - goal is currently being tracked
        case active
        
        /// Cancelled - user cancelled the goal
        case cancelled
        
        /// Completed - succesfully completed
        case completed
        
        /// Failed - user failed to successfully complete the goal
        case failed
        
        /// Finalising - goal is finished but some transactions may move from pending to posted which could affect the goal (usually within 2 business days)
        case finalising
        
        /// Unstarted - goal is pending and not started yet
        case unstarted
        
    }
    
    /**
     Target
     
     Target of the goal to be reached
     */
    public enum Target: String, Codable, CaseIterable {
        
        /// Amount - target amount to be reached
        case amount
        
        /// Date - target to be reached by a certain date
        case date
        
        /// Open Ended - target is not set but a regular contribution amount and end date is
        case openEnded = "open_ended"
        
    }
    
    /**
     Tracking Status
     
     How the user is tracking against an in progress goal
     */
    public enum TrackingStatus: String, Codable, CaseIterable {
        
        /// Ahead - user is ahead on contributions
        case ahead
        
        /// Behind - user is behind on contributions
        case behind
        
        /// On Track - user in on track on contributions
        case onTrack = "on_track"
        
    }
    
    /**
     Tracking Type
     
     How the goal is being tracked
     */
    public enum TrackingType: String, Codable, CaseIterable {
        
        /// Credit - only credits are counted towards the goal
        case credit
        
        /// Debit - only debits are counted towards the goal
        case debit
        
        /// Debit and Credit - Both debits and credits will affect the goal. E.g. withdrawing after a deposit will reduce the saved amount
        case debitCredit = "debit_credit"
        
    }
    
    /// Core Data entity description name
    static var entityName = "Goal"
    
    internal static var primaryKey = #keyPath(Goal.goalID)
    
    /// Date formatter to convert from stored date string to user's current locale
    public static let goalDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    internal var primaryID: Int64 {
        return goalID
    }
    
    /// Current active goal period
    public var currentPeriod: GoalPeriod? {
        let dateString = GoalPeriod.goalPeriodDateFormatter.string(from: Date())
        return periods?.first { $0.endDateString > dateString && dateString > $0.startDateString }
    }
    
    /// End date of the goal
    public var endDate: Date {
        get {
            return Goal.goalDateFormatter.date(from: endDateString)!
        }
        set {
            endDateString = Goal.goalDateFormatter.string(from: newValue)
        }
    }
    
    /// Estimated date the goal will be completed at the current rate of progress (Optional)
    public var estimatedEndDate: Date? {
        get {
            if let rawDateString = estimatedEndDateString {
                return Goal.goalDateFormatter.date(from: rawDateString)
            }
            return nil
        }
        set {
            if let newRawDate = newValue {
                estimatedEndDateString = Goal.goalDateFormatter.string(from: newRawDate)
            } else {
                estimatedEndDateString = nil
            }
        }
    }
    
    /// Frequency
    public var frequency: Frequency {
        get {
            return Frequency(rawValue: frequencyRawValue)!
        }
        set {
            frequencyRawValue = newValue.rawValue
        }
    }
    
    /// URL of the goal image
    public var imageURL: URL? {
        get {
            if let url = imageURLString {
                return URL(string: url)
            }
            return nil
        }
        set {
            imageURLString = newValue?.absoluteString
        }
    }
    
    /// Date the goal starts
    public var startDate: Date {
        get {
            return Goal.goalDateFormatter.date(from: startDateString)!
        }
        set {
            startDateString = Goal.goalDateFormatter.string(from: newValue)
        }
    }
    
    /// Goal status
    public var status: Status {
        get {
            return Status(rawValue: statusRawValue)!
        }
        set {
            statusRawValue = newValue.rawValue
        }
    }
    
    /// Target
    public var target: Target {
        get {
            return Target(rawValue: targetRawValue)!
        }
        set {
            targetRawValue = newValue.rawValue
        }
    }
    
    /// Tracking Status
    public var trackingStatus: TrackingStatus {
        get {
            return TrackingStatus(rawValue: trackingStatusRawValue)!
        }
        set {
            trackingStatusRawValue = newValue.rawValue
        }
    }
    
    /// Tracking Type
    public var trackingType: TrackingType {
        get {
            return TrackingType(rawValue: trackingTypeRawValue)!
        }
        set {
            trackingTypeRawValue = newValue.rawValue
        }
    }
    
    // MARK: - Updating object
    
    internal func linkObject(object: NSManagedObject) {
        if let goalPeriod = object as? GoalPeriod {
            addToPeriods(goalPeriod)
        }
    }
    
    internal func update(response: APIUniqueResponse, context: NSManagedObjectContext) {
        if let goalResponse = response as? APIGoalResponse {
            update(response: goalResponse, context: context)
        }
    }
    
    internal func update(response: APIGoalResponse, context: NSManagedObjectContext) {
        goalID = response.id
        accountID = response.accountID ?? -1
        currentAmount = NSDecimalNumber(string: response.currentAmount)
        currency = response.currency
        details = response.description
        endDateString = response.endDate
        estimatedEndDateString = response.estimatedEndDate
        frequency = response.frequency
        imageURLString = response.imageURL
        name = response.name
        periodAmount = NSDecimalNumber(string: response.periodAmount)
        periodCount = response.periodsCount
        startAmount = NSDecimalNumber(string: response.startAmount)
        startDateString = response.startDate
        status = response.status
        subType = response.subType
        target = response.target
        targetAmount = NSDecimalNumber(string: response.targetAmount)
        trackingStatus = response.trackingStatus
        trackingType = response.trackingType
        type = response.type
        
        if let amount = response.estimatedTargetAmount {
            estimatedTargetAmount = NSDecimalNumber(string: amount)
        } else {
            estimatedTargetAmount = nil
        }
    }
    
    internal func updateRequest() -> APIGoalUpdateRequest {
        return APIGoalUpdateRequest(description: details,
                                    imageURL: imageURLString,
                                    name: name)
    }
    
}
