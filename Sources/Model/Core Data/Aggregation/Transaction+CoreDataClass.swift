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
    
    static let transactionDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
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
    
    public var status: Status {
        get {
            return Status(rawValue: statusRawValue!)!
        }
        set {
            statusRawValue = newValue.rawValue
        }
    }
    
    public var transactionDate: Date {
        get {
            return Transaction.transactionDateFormatter.date(from: transactionDateString!)!
        }
        set {
            transactionDateString = Transaction.transactionDateFormatter.string(from: newValue)
        }
    }

    // MARK: - Updating Object
    
    func linkObject(object: CacheableManagedObject) {
        // Not used
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
        memo = response.memo
        originalDescription = response.description.original
        postDateString = response.postDate
        simpleDescription = response.description.simple
        status = response.status
        transactionCategoryID = response.categoryID
        transactionDateString = response.transactionDate
        userDescription = response.description.user
    }
    
    func updateRequest() -> APITransactionUpdateRequest {
        return APITransactionUpdateRequest(budgetCategory: budgetCategory,
                                           categoryID: transactionCategoryID,
                                           included: included,
                                           memo: memo,
                                           userDescription: userDescription)
    }
    
}
