//
//  Transaction+CoreDataClass.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 8/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Transaction)
public class Transaction: NSManagedObject, CacheableManagedObject {
    
    public enum BaseType: String, Codable {
        case credit
        case debit
        case other
        case unknown
    }
    
    public enum Status: String, Codable {
        case pending
        case posted
        case scheduled
    }
    
    static var entityName = "Transaction"
    
    var primaryID: Int64 {
        get {
            return transactionID
        }
    }
    
    var linkedID: Int64? {
        get {
            return nil
        }
    }
    
    public var baseType: BaseType {
        get {
            return BaseType(rawValue: baseTypeRawValue!)!
        }
        set {
            baseTypeRawValue = newValue.rawValue
        }
    }
    
    public var budgetCategory: BudgetCategory {
        get {
            return BudgetCategory(rawValue: budgetCategoryRawValue!)!
        }
        set {
            budgetCategoryRawValue = newValue.rawValue
        }
    }
    
    public var status: Status {
        get {
            return Status(rawValue: statusRawValue!)!
        }
        set {
            statusRawValue = newValue.rawValue
        }
    }

    // MARK: - Updating Object
    
    func linkObject(object: CacheableManagedObject) {
        // TODO: - Implement
    }
    
    func update(response: APIUniqueResponse, context: NSManagedObjectContext) {
        if let transactionResponse = response as? APITransactionResponse {
            update(response: transactionResponse, context: context)
        }
    }
    
    func update(response: APITransactionResponse, context: NSManagedObjectContext) {
        transactionID = response.id
        accountID = response.accountID
        amount = NSDecimalNumber(string: response.amount.amount)
        baseType = response.baseType
        budgetCategory = response.budgetCategory
        currency = response.amount.currency
        included = response.included
        merchantID = response.merchantID
        merchantName = response.merchantName
        memo = response.memo
        originalDescription = response.description.original
        postDate = response.postDate
        simpleDescription = response.description.simple
        status = response.status
        transactionCategoryID = response.categoryID
        transactionDate = response.transactionDate
        userDescription = response.description.user
    }
    
}
