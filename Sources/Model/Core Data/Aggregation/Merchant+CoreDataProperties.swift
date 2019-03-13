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

extension Merchant {
    
    /**
     Fetch Request
     
     - returns: Fetch request for `Merchant` type
     */
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Merchant> {
        return NSFetchRequest<Merchant>(entityName: "Merchant")
    }
    
    /// Unique ID for the merchant
    @NSManaged public var merchantID: Int64
    
    /// Raw value of the merchant type. Use only in predicates (optional)
    @NSManaged public var merchantTypeRawValue: String?
    
    /// Name of the merchant
    @NSManaged public var name: String
    
    /// Raw value of the small logo URL string (optional)
    @NSManaged public var smallLogoURLString: String?
    
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

extension Merchant {
    
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

extension Merchant {
    
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

extension Merchant {
    
    /// Add a transaction history report relationship
    @objc(addHistoryReportsObject:)
    @NSManaged public func addToHistoryReports(_ value: ReportTransactionHistory)
    
    /// Remove a transaction history report relationship
    @objc(removeHistoryReportsObject:)
    @NSManaged public func removeFromHistoryReports(_ value: ReportTransactionHistory)
    
    /// Add transaction history report relationships
    @objc(addHistoryReports:)
    @NSManaged public func addToHistoryReports(_ values: NSSet)
    
    /// Remove transaction history report relationships
    @objc(removeHistoryReports:)
    @NSManaged public func removeFromHistoryReports(_ values: NSSet)
    
}

// MARK: Generated accessors for currentReports

extension Merchant {
    
    /// Add a transaction current report relationship
    @objc(addCurrentReportsObject:)
    @NSManaged public func addToCurrentReports(_ value: ReportTransactionCurrent)
    
    /// Remove a transaction current report relationship
    @objc(removeCurrentReportsObject:)
    @NSManaged public func removeFromCurrentReports(_ value: ReportTransactionCurrent)
    
    /// Add transaction current report relationships
    @objc(addCurrentReports:)
    @NSManaged public func addToCurrentReports(_ values: NSSet)
    
    /// Remove transaction current report relationships
    @objc(removeCurrentReports:)
    @NSManaged public func removeFromCurrentReports(_ values: NSSet)
    
}
