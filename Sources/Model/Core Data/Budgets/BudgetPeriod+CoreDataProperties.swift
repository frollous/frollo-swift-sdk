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

extension BudgetPeriod {
    
    /**
     Fetch Request
     
     - returns: Fetch request for `BudgetPeriod` type
     */
    @nonobjc public class func fetchRequest() -> NSFetchRequest<BudgetPeriod> {
        return NSFetchRequest<BudgetPeriod>(entityName: "BudgetPeriod")
    }
    
    /// Unique ID of the budget period
    @NSManaged public var budgetPeriodID: Int64
    
    /// Budget ID of the parent budget
    @NSManaged public var budgetID: Int64
    
    /// Raw value of the start date. Use only in predicates
    @NSManaged public var startDateString: String
    
    /// Raw value of the end date. Use only in predicates
    @NSManaged public var endDateString: String
    
    /// Index of the period
    @NSManaged public var index: Int64
    
    /// Target amount to reach for the budget period
    @NSManaged public var targetAmount: NSDecimalNumber
    
    /// Current amount progressed against the budget period depending on `trackingType` of the budget
    @NSManaged public var currentAmount: NSDecimalNumber
    
    /// Required amount to get your targetAmount.
    @NSManaged public var requiredAmount: NSDecimalNumber
    
    /// Raw value of the tracking status. Use only in predicates
    @NSManaged public var trackingStatusRawValue: String?
    
    /// Budget associated with
    @NSManaged public var budget: Budget?
    
}
