//
// Copyright © 2018 Frollo. All rights reserved.
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

/**
 Transaction Category
 
 Core Data representation of a transaction category giving details on what type a transaction is
 */
public class TransactionCategory: NSManagedObject, UniqueManagedObject {
    
    /**
     Transaction Category Type
     
     High level type of the category
     */
    public enum CategoryType: String, Codable {
        
        /// Credit Score Event Type
        case creditScore = "credit_score"
        
        /// Deferred compensation
        case deferredCompensation = "deferred_compensation"
        
        /// Expense
        case expense
        
        /// Income
        case income
        
        /// Transfer. Internal or external financial transfer
        case transfer
        
        /// Uncategorized
        case uncategorize
        
        /// Unknown. Transaction category is not recognised
        case unknown
        
    }
    
    /// Core Data entity description name
    static let entityName = "TransactionCategory"
    
    internal static var primaryKey = #keyPath(TransactionCategory.transactionCategoryID)
    
    internal var primaryID: Int64 {
        return transactionCategoryID
    }
    
    /// Category
    public var categoryType: CategoryType {
        get {
            return CategoryType(rawValue: categoryTypeRawValue)!
        }
        set {
            categoryTypeRawValue = newValue.rawValue
        }
    }
    
    /// Default budget category the category is associated with. Transactions will default to this budget category when recategorised
    public var defaultBudgetCategory: BudgetCategory {
        get {
            return BudgetCategory(rawValue: defaultBudgetCategoryRawValue)!
        }
        set {
            defaultBudgetCategoryRawValue = newValue.rawValue
        }
    }
    
    /// URL to an icon image for the category (optional)
    public var iconURL: URL? {
        get {
            if let rawURLString = iconURLString {
                return URL(string: rawURLString)
            }
            return nil
        }
        set {
            iconURLString = newValue?.absoluteString
        }
    }
    
    // MARK: - Updating object
    
    internal func linkObject(object: NSManagedObject) {
        if let bill = object as? Bill {
            addToBills(bill)
        }
        if let transaction = object as? Transaction {
            addToTransactions(transaction)
        }
        if let currentReport = object as? ReportTransactionCurrent {
            addToCurrentReports(currentReport)
        }
        if let historyReport = object as? ReportTransactionHistory {
            addToHistoryReports(historyReport)
        }
    }
    
    internal func update(response: APIUniqueResponse, context: NSManagedObjectContext) {
        if let transactionCategoryResponse = response as? APITransactionCategoryResponse {
            update(response: transactionCategoryResponse, context: context)
        }
    }
    
    internal func update(response: APITransactionCategoryResponse, context: NSManagedObjectContext) {
        transactionCategoryID = response.id
        categoryType = response.categoryType
        defaultBudgetCategory = response.defaultBudgetCategory
        iconURLString = response.iconURL
        name = response.name
        placement = response.placement
        userDefined = response.userDefined
    }
    
}
