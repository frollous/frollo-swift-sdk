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
    
    /// Related transactions
    @NSManaged public var transactions: Set<Transaction>?

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
