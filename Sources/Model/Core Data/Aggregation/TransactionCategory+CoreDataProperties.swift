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

extension TransactionCategory {
    
    /**
     Fetch Request
     
     - returns: Fetch request for `Account` type
     */
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TransactionCategory> {
        return NSFetchRequest<TransactionCategory>(entityName: "TransactionCategory")
    }
    
    /// Raw value of the transaction category type. Use only in predicates
    @NSManaged public var categoryTypeRawValue: String
    
    /// Raw value of the default budget category. Use only in predicates
    @NSManaged public var defaultBudgetCategoryRawValue: String
    
    /// Raw value of the icon URL. Use only in predicates
    @NSManaged public var iconURLString: String?
    
    /// Name of the transaction category
    @NSManaged public var name: String
    
    /// Placement order of the transaction for determining most popular categories. Higher is more popular
    @NSManaged public var placement: Int64
    
    /// Unique ID for the transaction category
    @NSManaged public var transactionCategoryID: Int64
    
    /// User defined category
    @NSManaged public var userDefined: Bool
    
    /// Associated bills (optional)
    @NSManaged public var bills: Set<Bill>?
    
    /// Related transaction history reports
    @NSManaged public var historyReports: NSSet?
    
    /// Related transaction current reports
    @NSManaged public var currentReports: NSSet?
    
    /// Related transactions
    @NSManaged public var transactions: Set<Transaction>?
    
}

// MARK: Generated accessors for bills

extension TransactionCategory {
    
    /// Add a bill relationship
    @objc(addBillsObject:)
    @NSManaged public func addToBills(_ value: Bill)
    
    /// Remove a bill relationship
    @objc(removeBillsObject:)
    @NSManaged public func removeFromBills(_ value: Bill)
    
    /// Add bill relationships
    @objc(addBills:)
    @NSManaged public func addToBills(_ values: Set<Bill>)
    
    /// Remove bill relationships
    @objc(removeBills:)
    @NSManaged public func removeFromBills(_ values: Set<Bill>)
    
}

// MARK: Generated accessors for transactions

extension TransactionCategory {
    
    /// Add a transaction relationship
    @objc(addTransactionsObject:)
    @NSManaged public func addToTransactions(_ value: Transaction)
    
    /// Remove a transaction relationship
    @objc(removeTransactionsObject:)
    @NSManaged public func removeFromTransactions(_ value: Transaction)
    
    /// Add transaction relationships
    @objc(addTransactions:)
    @NSManaged public func addToTransactions(_ values: Set<Transaction>)
    
    /// Remove transaction relationships
    @objc(removeTransactions:)
    @NSManaged public func removeFromTransactions(_ values: Set<Transaction>)
    
}

// MARK: Generated accessors for historyReports

extension TransactionCategory {
    
    /// Add transaction history report relationships
    @objc(addHistoryReports:)
    @NSManaged public func addToHistoryReports(_ values: NSSet)
    
    /// Remove transaction history report relationships
    @objc(removeHistoryReports:)
    @NSManaged public func removeFromHistoryReports(_ values: NSSet)
    
}

// MARK: Generated accessors for currentReports

extension TransactionCategory {
    
    /// Add transaction current report relationships
    @objc(addCurrentReports:)
    @NSManaged public func addToCurrentReports(_ values: NSSet)
    
    /// Remove transaction current report relationships
    @objc(removeCurrentReports:)
    @NSManaged public func removeFromCurrentReports(_ values: NSSet)
    
}
