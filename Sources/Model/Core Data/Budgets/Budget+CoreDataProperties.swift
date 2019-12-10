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

extension Budget {
    
    /**
     Fetch Request
     
     - returns: Fetch request for `Budget` type
     */
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Budget> {
        return NSFetchRequest<Budget>(entityName: "Budget")
    }
    
    /// Unique ID of the budget
    @NSManaged public var budgetID: Int64
    
    /// User ID
    @NSManaged public var userID: Int64
    
    /// Returns true if the budget is active
    @NSManaged public var isCurrent: Bool
    
    /// Raw value for the type. Only use in predicates
    @NSManaged public var typeRawValue: String
    
    /// Value of the `budgetType`. `name` if budget category and `id` if category and merchant.
    @NSManaged public var typeValue: String
    
    /// Raw value of tracking status. Only use in predicates
    @NSManaged public var trackingStatusRawValue: String
    
    /// Raw value of status. Only use in predicates
    @NSManaged public var statusRawValue: String
    
    /// Raw value of the frequency. Only use in predicates
    @NSManaged public var frequencyRawValue: String
    
    /// Currency of the budget
    @NSManaged public var currency: String
    
    /// Current amount of the Budget
    @NSManaged public var currentAmount: NSDecimalNumber
    
    /// The amount you want each BudgetPeriod to be.
    @NSManaged public var periodAmount: NSDecimalNumber
    
    /// Raw value for the image URL (Optional)
    @NSManaged public var imageURLString: String?
    
    /// The date at which to start the Budget (Optional)
    @NSManaged public var startDateString: String?
    
    /// The number of periods that belong to this Budget
    @NSManaged public var periodsCount: Int64
    
    /// Custom JSON metadata (optional)
    @NSManaged public var metadataRawValue: Data?
    
    /// Budget periods
    @NSManaged public var periods: Set<BudgetPeriod>?
    
}

// MARK: Generated accessors for budget periods

extension Budget {
    
    /// Add a budget period relationship
    @objc(addPeriodsObject:)
    @NSManaged public func addToPeriods(_ value: BudgetPeriod)
    
    /// Remove a budget period relationship
    @objc(removePeriodsObject:)
    @NSManaged public func removeFromPeriods(_ value: BudgetPeriod)
    
    /// Add budget period relationships
    @objc(addPeriods:)
    @NSManaged public func addToPeriods(_ values: Set<BudgetPeriod>)
    
    /// Remove budget period relationships
    @objc(removePeriods:)
    @NSManaged public func removeFromPeriods(_ values: Set<BudgetPeriod>)
    
}
