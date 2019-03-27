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

public class UserGoal: NSManagedObject, UniqueManagedObject {
    
    public enum Status: String, Codable, CaseIterable {
        case active
        case cancelled
        case completed
        case failed
        case finalising
        case unstarted
    }
    
    /// Core Data entity description name
    static var entityName = "UserGoal"
    
    internal static var primaryKey = #keyPath(UserGoal.userGoalID)
    
    internal var primaryID: Int64 {
        return userGoalID
    }
    
    /// Date formatter to convert from stored date string to user's current locale
    public static let goalDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    public var challengeEndDate: Date {
        get {
            return UserGoal.goalDateFormatter.date(from: challengeEndDateString)!
        }
        set {
            challengeEndDateString = UserGoal.goalDateFormatter.string(from: newValue)
        }
    }
    
    public var endDate: Date {
        get {
            return UserGoal.goalDateFormatter.date(from: endDateString)!
        }
        set {
            endDateString = UserGoal.goalDateFormatter.string(from: newValue)
        }
    }
    
    public var estimatedEndDate: Date {
        get {
            return UserGoal.goalDateFormatter.date(from: estimatedEndDateString)!
        }
        set {
            estimatedEndDateString = UserGoal.goalDateFormatter.string(from: newValue)
        }
    }
    
    public var startDate: Date {
        get {
            return UserGoal.goalDateFormatter.date(from: startDateString)!
        }
        set {
            startDateString = UserGoal.goalDateFormatter.string(from: newValue)
        }
    }
    
    public var status: Status {
        get {
            return Status(rawValue: statusRawValue)!
        }
        set {
            statusRawValue = newValue.rawValue
        }
    }
    
    // MARK: - Updating object
    
    internal func linkObject(object: NSManagedObject) {
        // Do nothing
    }
    
    internal func update(response: APIUniqueResponse, context: NSManagedObjectContext) {
        if let userGoalResponse = response as? APIUserGoalResponse {
            update(response: userGoalResponse, context: context)
        }
    }
    
    internal func update(response: APIUserGoalResponse, context: NSManagedObjectContext) {
        userGoalID = response.id
        goalID = response.goalID
        challengeEndDateString = response.challengeEndDate
        currency = response.currency
        currentSavedAmount = Decimal(response.currentSavedAmount) as NSDecimalNumber
        currentTargetAmount = Decimal(response.currentTargetAmount) as NSDecimalNumber
        endDateString = response.baseEndDate
        estimatedEndDateString = response.estimatedEndDate
        interestRate = NSDecimalNumber(string: response.interestRate)
        monthlySavingAmount = Decimal(response.monthlySavingAmount) as NSDecimalNumber
        startAmount = Decimal(response.startAmount) as NSDecimalNumber
        startDateString = response.startDate
        status = response.status
        targetAmount = Decimal(response.targetAmount) as NSDecimalNumber
    }
    
}
