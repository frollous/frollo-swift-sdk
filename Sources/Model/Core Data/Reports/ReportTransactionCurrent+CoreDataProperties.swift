//
// Copyright © 2019 Frollo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//

import CoreData
import Foundation

extension ReportTransactionCurrent {
    
    /**
     Fetch Request
     
     - returns: Fetch request for `ReportTransactionCurrent` type
     */
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReportTransactionCurrent> {
        return NSFetchRequest<ReportTransactionCurrent>(entityName: "ReportTransactionCurrent")
    }
    
    /// Spend
    @NSManaged public var amount: NSDecimalNumber?
    
    /// Average amount from last 3 months
    @NSManaged public var average: NSDecimalNumber?
    
    /// Budgeted amount (Optional)
    @NSManaged public var budget: NSDecimalNumber?
    
    /// Raw value of the linked budget category if applicable. Use only in predicates (Optional)
    @NSManaged public var budgetCategoryRawValue: String?
    
    /// Day of the month
    @NSManaged public var day: Int64
    
    /// Raw value of the filtered budget category. Use only in predicates (Optional)
    @NSManaged public var filterBudgetCategoryRawValue: String?
    
    /// Raw value of the report grouping
    @NSManaged public var groupingRawValue: String
    
    /// Unique ID of the related object. E.g. merchant or category. -1 Represents no link or overall report
    @NSManaged public var linkedID: Int64
    
    /// Name of the related object (Optional)
    @NSManaged public var name: String?
    
    /// Previous month spend
    @NSManaged public var previous: NSDecimalNumber?
    
    /// Related merchant (Optional)
    @NSManaged public var merchant: Merchant?
    
    /// Related transaction category (Optional)
    @NSManaged public var transactionCategory: TransactionCategory?
    
}
