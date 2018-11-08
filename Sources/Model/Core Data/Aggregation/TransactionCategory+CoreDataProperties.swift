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

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TransactionCategory> {
        return NSFetchRequest<TransactionCategory>(entityName: "TransactionCategory")
    }

    @NSManaged public var categoryTypeRawValue: String?
    @NSManaged public var defaultBudgetCategoryRawValue: String?
    @NSManaged public var iconURLString: String?
    @NSManaged public var name: String?
    @NSManaged public var placement: Int64
    @NSManaged public var transactionCategoryID: Int64
    @NSManaged public var userDefined: Bool
    @NSManaged public var transactions: Set<Transaction>?

}

// MARK: Generated accessors for transactions
extension TransactionCategory {

    @objc(addTransactionsObject:)
    @NSManaged public func addToTransactions(_ value: Transaction)

    @objc(removeTransactionsObject:)
    @NSManaged public func removeFromTransactions(_ value: Transaction)

    @objc(addTransactions:)
    @NSManaged public func addToTransactions(_ values: Set<Transaction>)

    @objc(removeTransactions:)
    @NSManaged public func removeFromTransactions(_ values: Set<Transaction>)

}
