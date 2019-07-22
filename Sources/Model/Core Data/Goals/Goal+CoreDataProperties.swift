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
    
    /**
     Fetch Request
     
     - returns: Fetch request for `Bill` type
     */
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Goal> {
        return NSFetchRequest<Goal>(entityName: "Goal")
    }
    
    /// Account ID goal is associated with if tracking automatically (Optional)
    @NSManaged public var accountID: Int64
    
    /// Currency ISO code of the goal
    @NSManaged public var currency: String
    
    /// Current amount progressed against the goal. Depending on `trackingType` this will include credits and/or debits towards the goal
    @NSManaged public var currentAmount: NSDecimalNumber
    
    /// Description of the goal (Optional)
    @NSManaged public var details: String?
    
    /// Raw value of the end date. Use only in predicates
    @NSManaged public var endDateString: String
    
    /// Raw value of the estimated end date. Use only in predicates (Optional)
    @NSManaged public var estimatedEndDateString: String?
    
    /// Estimated amount saved at the end of the goal at the current rate of progress (Optional)
    @NSManaged public var estimatedTargetAmount: NSDecimalNumber?
    
    /// Raw value of the frequence. Use only in predicates
    @NSManaged public var frequencyRawValue: String
    
    /// Unique ID of the goal
    @NSManaged public var goalID: Int64
    
    /// Raw value for the image URL (Optional)
    @NSManaged public var imageURLString: String?
    
    /// Name of the goal
    @NSManaged public var name: String
    
    /// Amount to be saved each period
    @NSManaged public var periodAmount: NSDecimalNumber
    
    /// Amount of periods until the goal is completed
    @NSManaged public var periodCount: Int64
    
    /// Starting amount of the goal
    @NSManaged public var startAmount: NSDecimalNumber
    
    /// Raw value of the start date. Use only in predicates
    @NSManaged public var startDateString: String
    
    /// Raw value of the status. Use only in predicates
    @NSManaged public var statusRawValue: String
    
    /// Sub-type of the goal (Optional)
    @NSManaged public var subType: String?
    
    /// Target amount to reach for the goal
    @NSManaged public var targetAmount: NSDecimalNumber
    
    /// Raw value of the target. Use only in predicates
    @NSManaged public var targetRawValue: String
    
    /// Raw value of the tracking status. Use only in predicates
    @NSManaged public var trackingStatusRawValue: String
    
    /// Raw value of the tracking type. Use only in predicates
    @NSManaged public var trackingTypeRawValue: String
    
    /// Type of the goal (Optional)
    @NSManaged public var type: String?
    
}
