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

extension UserGoal {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserGoal> {
        return NSFetchRequest<UserGoal>(entityName: "UserGoal")
    }
    
    @NSManaged public var userGoalID: Int64
    @NSManaged public var statusRawValue: String
    @NSManaged public var goalID: Int64
    @NSManaged public var currency: String
    @NSManaged public var startAmount: NSDecimalNumber
    @NSManaged public var targetAmount: NSDecimalNumber
    @NSManaged public var monthlySavingAmount: NSDecimalNumber
    @NSManaged public var currentSavedAmount: NSDecimalNumber
    @NSManaged public var currentTargetAmount: NSDecimalNumber
    @NSManaged public var interestRate: NSDecimalNumber
    @NSManaged public var startDateString: String
    @NSManaged public var endDateString: String
    @NSManaged public var challengeEndDateString: String
    @NSManaged public var estimatedEndDateString: String
    @NSManaged public var goal: Goal?
    @NSManaged public var userChallenges: NSSet?
    
}

extension UserGoal {
    
    @objc(addUserChallengesObject:)
    @NSManaged public func addToUserChallenges(_ value: UserChallenge)
    
    @objc(removeUserChallengesObject:)
    @NSManaged public func removeFromUserChallenges(_ value: UserChallenge)
    
    @objc(addUserChallenges:)
    @NSManaged public func addToUserChallenges(_ values: NSSet)
    
    @objc(removeUserChallenges:)
    @NSManaged public func removeFromUserChallenges(_ values: NSSet)
    
}
