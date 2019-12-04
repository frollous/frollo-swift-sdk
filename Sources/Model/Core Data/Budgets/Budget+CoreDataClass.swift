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
import SwiftyJSON

/**
 Budget
 
 Core Data model of the budget.
 */
public class Budget: NSManagedObject, UniqueManagedObject {
    
    /**
     Frequency
     
     How often the `BudgetPeriod`s occur
     */
    public enum Frequency: String, Codable, CaseIterable {
        
        /// Annually
        case annually
        
        /// Biannually - twice in a year
        case biannually
        
        /// Daily
        case daily
        
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
     
     Status of the budget
     */
    public enum Status: String, Codable, CaseIterable {
        
        /// Active - budget is currently active
        case active
        
        /// Cancelled - user cancelled the budget
        case cancelled
        
        /// Completed - succesfully completed
        case completed
        
        /// Failed - user failed to successfully complete the budget
        case failed
        
        /// Finalising - budget is finished but some transactions may move from pending to posted which could affect the budget (usually within 2 business days)
        case finalising
        
        /// Unstarted - budget is pending and not started yet
        case unstarted
        
    }
    
    /**
     Tracking Status
     
     How the user is tracking against an in progress budget or how the tracked against a previous budget period
     */
    public enum TrackingStatus: String, Codable, CaseIterable {
        
        /// Ahead - user is ahead on budget
        case ahead
        
        /// Behind - user is behind the budget
        case behind
        
        /// On Track - user in on track of the budget
        case onTrack = "on_track"
        
    }
    
    /**
     Type
     
     Type of the budget
     */
    public enum BudgetType: String, Codable, CaseIterable {
        
        /// BudgetCategory
        case budgetCategory = "budget_category"
        
        /// Category
        case category
        
        /// Metchant
        case merchant
        
    }
    
    // Core Data entity description name
    static var entityName = "Budget"
    
    internal static var primaryKey = #keyPath(Budget.budgetID)
    
    internal var primaryID: Int64 {
        return budgetID
    }
    
    /// Date formatter to convert from stored date string to user's current locale
    public static let budgetDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    // Start date of the budget
    public var startDate: Date {
        get {
            return Budget.budgetDateFormatter.date(from: startDateString)!
        }
        set {
            startDateString = Budget.budgetDateFormatter.string(from: newValue)
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
    
    /// Metadata - custom JSON to be stored with the budget
    public var metadata: JSON {
        get {
            if let rawValue = metadataRawValue {
                do {
                    return try JSON(data: rawValue)
                } catch {
                    Log.error(error.localizedDescription)
                }
            }
            return [:]
        }
        set {
            do {
                metadataRawValue = try newValue.rawData()
            } catch {
                Log.error(error.localizedDescription)
                
                metadataRawValue = try? JSONSerialization.data(withJSONObject: [:], options: [])
            }
        }
    }
    
    /// Budget status
    public var status: Status {
        get {
            return Status(rawValue: statusRawValue)!
        }
        set {
            statusRawValue = newValue.rawValue
        }
    }
    
    /// Specifies if the Budget is on track or not.
    public var trackingStatus: TrackingStatus {
        get {
            return TrackingStatus(rawValue: trackingStatusRawValue)!
        }
        set {
            trackingStatusRawValue = newValue.rawValue
        }
    }
    
    /// The strategy for tracking the Budget.
    public var budgetType: BudgetType {
        get {
            return BudgetType(rawValue: typeRawValue)!
        }
        set {
            typeRawValue = newValue.rawValue
        }
    }
    
}

extension Budget {
    
    internal func update(response: APIUniqueResponse, context: NSManagedObjectContext) {
        if let budgetResponse = response as? APIBudgetResponse {
            update(response: budgetResponse, context: context)
        }
    }
    
    internal func update(response: APIBudgetResponse, context: NSManagedObjectContext) {
        budgetID = response.id
        isCurrent = response.isCurrent
        budgetType = response.budgetType
        typeValue = response.typeValue
        userID = response.userID
        currentAmount = NSDecimalNumber(string: response.currentAmount)
        currency = response.currency
        startDateString = response.startDate
        frequency = response.frequency
        metadata = response.metadata ?? [:]
        currentAmount = NSDecimalNumber(string: response.currentAmount)
        periodAmount = NSDecimalNumber(string: response.periodAmount)
        periodsCount = response.periodsCount
        startDateString = response.startDate
        status = response.status
        targetAmount = NSDecimalNumber(string: response.targetAmount)
        trackingStatus = response.trackingStatus
        
        if let amount = response.estimatedTargetAmount {
            estimatedTargetAmount = NSDecimalNumber(string: amount)
        } else {
            estimatedTargetAmount = nil
        }
    }
    
    func linkObject(object: NSManagedObject) {
        if let budgetPeriod = object as? BudgetPeriod {
            addToPeriods(budgetPeriod)
        }
    }
    
}
