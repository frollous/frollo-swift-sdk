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

/**
 Transaction
 
 Core Data representation of a transaction from an account
 */
public class Transaction: NSManagedObject, CacheableManagedObject {
    
    /**
     Transaction Base Type
     
     The basic type of transaction
    */
    public enum BaseType: String, Codable {
        
        /// Credit
        case credit
        
        /// Debit
        case debit
        
        /// Other
        case other
        
        /// Unknown
        case unknown
        
    }
    
    /**
     Transaction Status
     
     Status of the transaction's lifecycle
    */
    public enum Status: String, Codable {
        
        /// Pending. Transaction is authorised but not posted
        case pending
        
        /// Posted. Transaction is complete
        case posted
        
        /// Scheduled. Transaction is scheduled for the future
        case scheduled
        
    }
    
    /// Core Data entity description name
    static var entityName = "Transaction"
    
    /// Date formatter to convert from stored date string to user's current locale
    public static let transactionDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    internal var primaryID: Int64 {
        get {
            return transactionID
        }
    }
    
    internal var linkedID: Int64? {
        get {
            return nil
        }
    }
    
    /// Transaction Base Type
    public var baseType: BaseType {
        get {
            return BaseType(rawValue: baseTypeRawValue!)!
        }
        set {
            baseTypeRawValue = newValue.rawValue
        }
    }
    
    /// Transaction's associated budget category. See `BudgetCategory`
    public var budgetCategory: BudgetCategory {
        get {
            return BudgetCategory(rawValue: budgetCategoryRawValue!)!
        }
        set {
            budgetCategoryRawValue = newValue.rawValue
        }
    }
    
    /// Date the transaction was posted, localized (optional)
    public var postDate: Date? {
        get {
            if let rawDateString = postDateString {
                return Transaction.transactionDateFormatter.date(from: rawDateString)
            }
            return nil
        }
        set {
            if let newRawDate = newValue {
                postDateString = Transaction.transactionDateFormatter.string(from: newRawDate)
            } else {
                postDateString = nil
            }
        }
    }
    
    /// Status of the transaction
    public var status: Status {
        get {
            return Status(rawValue: statusRawValue!)!
        }
        set {
            statusRawValue = newValue.rawValue
        }
    }
    
    /// Date the transaction occurred, localized
    public var transactionDate: Date {
        get {
            return Transaction.transactionDateFormatter.date(from: transactionDateString!)!
        }
        set {
            transactionDateString = Transaction.transactionDateFormatter.string(from: newValue)
        }
    }

    // MARK: - Updating Object
    
    internal func linkObject(object: CacheableManagedObject) {
        // Not used
    }
    
    internal func update(response: APIUniqueResponse, context: NSManagedObjectContext) {
        if let transactionResponse = response as? APITransactionResponse {
            update(response: transactionResponse, context: context)
        }
    }
    
    internal func update(response: APITransactionResponse, context: NSManagedObjectContext) {
        transactionID = response.id
        accountID = response.accountID
        amount = NSDecimalNumber(string: response.amount.amount)
        baseType = response.baseType
        budgetCategory = response.budgetCategory
        currency = response.amount.currency
        included = response.included
        merchantID = response.merchantID
        memo = response.memo
        originalDescription = response.description.original
        postDateString = response.postDate
        simpleDescription = response.description.simple
        status = response.status
        transactionCategoryID = response.categoryID
        transactionDateString = response.transactionDate
        userDescription = response.description.user
    }
    
    internal func updateRequest() -> APITransactionUpdateRequest {
        return APITransactionUpdateRequest(budgetCategory: budgetCategory,
                                           categoryID: transactionCategoryID,
                                           included: included,
                                           memo: memo,
                                           userDescription: userDescription)
    }
    
}
