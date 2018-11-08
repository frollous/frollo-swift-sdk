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
    
    /// Related transactions
    @NSManaged public var transactions: Set<Transaction>?

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
