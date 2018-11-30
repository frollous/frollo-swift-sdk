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

    /**
     Fetch Request
     
     - returns: Fetch request for `Transaction` type
     */
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }

    /// Parent account ID
    @NSManaged public var accountID: Int64
    
    /// Amount the transaction is for
    @NSManaged public var amount: NSDecimalNumber
    
    /// Raw value of the transaction base type. Only use in predicates
    @NSManaged public var baseTypeRawValue: String?
    
    /// Raw value of the budget category. Only use in predicates
    @NSManaged public var budgetCategoryRawValue: String?
    
    /// Currency ISO code of the transaction
    @NSManaged public var currency: String
    
    /// Included in budget
    @NSManaged public var included: Bool
    
    /// Memo or notes added to the transaction (optional)
    @NSManaged public var memo: String?
    
    /// Merchant ID related to the transaction
    @NSManaged public var merchantID: Int64
    
    /// Original description of the transaction
    @NSManaged public var originalDescription: String
    
    /// Raw value of the post date. Use only in predicates (optional)
    @NSManaged public var postDateString: String?
    
    /// Simplified description of the transaction (optional)
    @NSManaged public var simpleDescription: String?
    
    /// Raw value of the transaction status. Use only in predicates
    @NSManaged public var statusRawValue: String
    
    /// Transaction Category ID related to the transaction
    @NSManaged public var transactionCategoryID: Int64
    
    /// Raw value of the transaction date. Use only in predicates
    @NSManaged public var transactionDateString: String
    
    /// Unique ID of the transaction
    @NSManaged public var transactionID: Int64
    
    /// User determined description of the transaction (optional)
    @NSManaged public var userDescription: String?
    
    /// Parent account
    @NSManaged public var account: Account?
    
    /// Related merchant
    @NSManaged public var merchant: Merchant?
    
    /// Related transaction category
    @NSManaged public var transactionCategory: TransactionCategory?

}