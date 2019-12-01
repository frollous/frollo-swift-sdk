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
    
    /// Account ID goal is associated with
    @NSManaged public var accountID: Int64
    
    /// Returns true if the budget is active
    @NSManaged public var isCurrent: Bool
    
    /// Raw value for the image URL (Optional)
    @NSManaged public var imageURLString: String?
    
    /// Raw value of tracking status
    @NSManaged public var trackingStatusRawValue: String
    
    /// Raw value of tracking type
    @NSManaged public var trackingTypeRawValue: String
    
    /// Raw value of status
    @NSManaged public var statusRawValue: String
    
    /// Raw value of the frequency
    @NSManaged public var frequencyRawValue: String
    
    /// Currency of the budget
    @NSManaged public var currency: String
    
    /// The current progress amount the Budget has. Depending on the tracking_type, this is the sum of all transactions for the Budget.
    @NSManaged public var currentAmount: NSDecimalNumber
    
    /// The amount you want each BudgetPeriod to be.
    @NSManaged public var periodAmount: NSDecimalNumber
    
    /// The starting amount of the Budget.
    @NSManaged public var startAmount: NSDecimalNumber
    
    /// The overall target amount of the Budget.
    @NSManaged public var targetAmount: NSDecimalNumber
    
    /// The date at which to start the Budget.
    @NSManaged public var startDateString: String
    
    /// A calculated field that gives you the estimated targetAmount that you would hit at the end_date, based on your previous performance. (optional)
    @NSManaged public var estimatedTargetAmount: NSDecimalNumber?
    
    /// The number of periods that belong to this budget.
    @NSManaged public var periodsCount: Int64
    
    /// Custom JSON metadata (optional)
    @NSManaged public var metadataRawValue: Data?
    
    /// Account associated with the budget (Optional)
    @NSManaged public var account: Account?
    
    /// Current budget period
    @NSManaged public var currentPeriod: BudgetPeriod?
    
}
