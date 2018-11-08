//
//  Transaction+CoreDataProperties.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 8/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//
//

import Foundation
import CoreData


extension Transaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }

    @NSManaged public var accountID: Int64
    @NSManaged public var amount: NSDecimalNumber?
    @NSManaged public var baseTypeRawValue: String?
    @NSManaged public var budgetCategoryRawValue: String?
    @NSManaged public var currency: String?
    @NSManaged public var included: Bool
    @NSManaged public var memo: String?
    @NSManaged public var merchantID: Int64
    @NSManaged public var originalDescription: String?
    @NSManaged public var postDateString: String?
    @NSManaged public var simpleDescription: String?
    @NSManaged public var statusRawValue: String?
    @NSManaged public var transactionCategoryID: Int64
    @NSManaged public var transactionDateString: String?
    @NSManaged public var transactionID: Int64
    @NSManaged public var userDescription: String?
    @NSManaged public var account: Account?
    @NSManaged public var merchant: Merchant?
    @NSManaged public var transactionCategory: TransactionCategory?

}
