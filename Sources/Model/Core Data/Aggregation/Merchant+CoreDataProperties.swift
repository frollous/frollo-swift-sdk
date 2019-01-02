//
//  Merchant+CoreDataProperties.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 8/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//
//

import Foundation
import CoreData


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
