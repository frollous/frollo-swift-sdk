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

extension Goal {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Goal> {
        return NSFetchRequest<Goal>(entityName: "Goal")
    }
    
    @NSManaged public var activeCount: Int64
    @NSManaged public var averageMonths: Int64
    @NSManaged public var averageTargetAmount: NSDecimalNumber
    @NSManaged public var completedCount: Int64
    @NSManaged public var details: String?
    @NSManaged public var goalID: Int64
    @NSManaged public var goalTypeRawValue: String
    @NSManaged public var largeLogoURLString: String?
    @NSManaged public var name: String
    @NSManaged public var smallLogoURLString: String?
    @NSManaged public var sourceRawValue: String
    @NSManaged public var startedCount: Int64
    @NSManaged public var userGoals: NSSet?
    
}

// MARK: Generated accessors for userGoals

extension Goal {
    
    @objc(addUserGoalsObject:)
    @NSManaged public func addToUserGoals(_ value: UserGoal)
    
    @objc(removeUserGoalsObject:)
    @NSManaged public func removeFromUserGoals(_ value: UserGoal)
    
    @objc(addUserGoals:)
    @NSManaged public func addToUserGoals(_ values: NSSet)
    
    @objc(removeUserGoals:)
    @NSManaged public func removeFromUserGoals(_ values: NSSet)
    
}
