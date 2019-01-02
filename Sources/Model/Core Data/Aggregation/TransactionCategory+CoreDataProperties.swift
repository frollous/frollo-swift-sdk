//
//  TransactionCategory+CoreDataProperties.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 8/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//
//

import Foundation
import CoreData


extension TransactionCategory {

    /**
     Fetch Request
     
     - returns: Fetch request for `Account` type
     */
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TransactionCategory> {
        return NSFetchRequest<TransactionCategory>(entityName: "TransactionCategory")
    }

    /// Raw value of the transaction category type. Use only in predicates
    @NSManaged public var categoryTypeRawValue: String?
    
    /// Raw value of the default budget category. Use only in predicates
    @NSManaged public var defaultBudgetCategoryRawValue: String?
    
    /// Raw value of the icon URL. Use only in predicates
    @NSManaged public var iconURLString: String?
    
    /// Name of the transaction category
    @NSManaged public var name: String?
    
    /// Placement order of the transaction for determining most popular categories. Higher is more popular
    @NSManaged public var placement: Int64
    
    /// Unique ID for the transaction category
    @NSManaged public var transactionCategoryID: Int64
    
    /// User defined category
    @NSManaged public var userDefined: Bool
    
    /// Associated bills (optional)
    @NSManaged public var bills: Set<Bill>?
    
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
