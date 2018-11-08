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

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Merchant> {
        return NSFetchRequest<Merchant>(entityName: "Merchant")
    }

    @NSManaged public var merchantID: Int64
    @NSManaged public var merchantTypeRawValue: String?
    @NSManaged public var name: String?
    @NSManaged public var smallLogoURLString: String?
    @NSManaged public var transactions: Set<Transaction>?

}

// MARK: Generated accessors for transactions
extension Merchant {

    @objc(addTransactionsObject:)
    @NSManaged public func addToTransactions(_ value: Transaction)

    @objc(removeTransactionsObject:)
    @NSManaged public func removeFromTransactions(_ value: Transaction)

    @objc(addTransactions:)
    @NSManaged public func addToTransactions(_ values: Set<Transaction>)

    @objc(removeTransactions:)
    @NSManaged public func removeFromTransactions(_ values: Set<Transaction>)

}
