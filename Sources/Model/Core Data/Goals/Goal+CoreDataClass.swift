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

public class Goal: NSManagedObject, UniqueManagedObject {
    
    public enum GoalType: String, Codable, CaseIterable {
        case debt
        case loan
        case save
    }
    
    public enum Source: String, Codable, CaseIterable {
        case custom
        case suggested
        case trending
    }
    
    /// Core Data entity description name
    static var entityName = "Goal"
    
    internal static var primaryKey = #keyPath(Goal.goalID)
    
    internal var primaryID: Int64 {
        return goalID
    }
    
    public var goalType: GoalType {
        get {
            return GoalType(rawValue: goalTypeRawValue)!
        }
        set {
            goalTypeRawValue = newValue.rawValue
        }
    }
    
    /// URL to the large logo image of the goal (optional)
    public var largeLogoURL: URL? {
        get {
            if let urlString = largeLogoURLString {
                return URL(string: urlString)
            }
            return nil
        }
        set {
            largeLogoURLString = newValue?.absoluteString
        }
    }
    
    /// URL to the small logo image (optional)
    public var smallLogoURL: URL? {
        get {
            if let urlString = smallLogoURLString {
                return URL(string: urlString)
            }
            return nil
        }
        set {
            smallLogoURLString = newValue?.absoluteString
        }
    }
    
    public var source: Source {
        get {
            return Source(rawValue: sourceRawValue)!
        }
        set {
            sourceRawValue = newValue.rawValue
        }
    }
    
    // MARK: - Updating object
    
    internal func linkObject(object: NSManagedObject) {
        if let challenge = object as? Challenge {
            addToSuggestedChallenges(challenge)
        }
        if let userGoal = object as? UserGoal {
            addToUserGoals(userGoal)
        }
    }
    
    internal func update(response: APIUniqueResponse, context: NSManagedObjectContext) {
        if let goalResponse = response as? APIGoalResponse {
            update(response: goalResponse, context: context)
        }
    }
    
    internal func update(response: APIGoalResponse, context: NSManagedObjectContext) {
        goalID = response.id
        activeCount = response.community.activeCount
        averageMonths = response.community.averageMonths
        averageTargetAmount = Decimal(response.community.averageTargetAmount) as NSDecimalNumber
        completedCount = response.community.completedCount
        details = response.description
        goalType = response.goalType
        largeLogoURLString = response.largeLogoURL
        name = response.name
        smallLogoURLString = response.smallLogoURL
        source = response.source
        startedCount = response.community.startedCount
    }
    
}
