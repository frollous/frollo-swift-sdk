//
//  TransactionCategory+CoreDataClass.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 7/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//
//

import Foundation
import CoreData

/**
 Transaction Category
 
 Core Data representation of a transaction category giving details on what type a transaction is
 */
public class TransactionCategory: NSManagedObject, CacheableManagedObject {
    
    /**
     Transaction Category Type
     
     High level type of the category
     */
    public enum CategoryType: String, Codable {
        
        /// Credit Score Event Type
        case creditScore = "credit_score"
        
        /// Deferred compensation
        case deferredCompensation = "deferred_compensation"
        
        /// Expense
        case expense
        
        /// Income
        case income
        
        /// Transfer. Internal or external financial transfer
        case transfer
        
        /// Uncategorized
        case uncategorize
        
        /// Unknown. Transaction category is not recognised
        case unknown
        
    }
    
    /// Core Data entity description name
    static let entityName = "TransactionCategory"
    
    internal var primaryID: Int64 {
        get {
            return transactionCategoryID
        }
    }
    
    internal var linkedID: Int64? {
        get {
            return nil
        }
    }
    
    /// Category
    public var categoryType: CategoryType {
        get {
            return CategoryType(rawValue: categoryTypeRawValue!)!
        }
        set {
            categoryTypeRawValue = newValue.rawValue
        }
    }
    
    /// Default budget category the category is associated with. Transactions will default to this budget category when recategorised
    public var defaultBudgetCategory: BudgetCategory {
        get {
            return BudgetCategory(rawValue: defaultBudgetCategoryRawValue!)!
        }
        set {
            defaultBudgetCategoryRawValue = newValue.rawValue
        }
    }
    
    /// URL to an icon image for the category (optional)
    public var iconURL: URL? {
        get {
            if let rawURLString = iconURLString {
                return URL(string: rawURLString)
            }
            return nil
        }
        set {
            iconURLString = newValue?.absoluteString
        }
    }
    
    // MARK: - Updating object
    
    internal func linkObject(object: CacheableManagedObject) {
        if let bill = object as? Bill {
            addToBills(bill)
        }
        if let transaction = object as? Transaction {
            addToTransactions(transaction)
        }
    }
    
    internal func update(response: APIUniqueResponse, context: NSManagedObjectContext) {
        if let transactionCategoryResponse = response as? APITransactionCategoryResponse {
            update(response: transactionCategoryResponse, context: context)
        }
    }
    
    internal func update(response: APITransactionCategoryResponse, context: NSManagedObjectContext) {
        transactionCategoryID = response.id
        categoryType = response.categoryType
        defaultBudgetCategory = response.defaultBudgetCategory
        iconURLString = response.iconURL
        name = response.name
        placement = response.placement
        userDefined = response.userDefined
    }

}
