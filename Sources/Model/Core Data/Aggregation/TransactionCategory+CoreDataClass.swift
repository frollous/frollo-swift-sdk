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

@objc(TransactionCategory)
public class TransactionCategory: NSManagedObject, CacheableManagedObject {
    
    public enum CategoryType: String, Codable {
        case creditScore = "credit_score"
        case deferredCompensation = "deferred_compensation"
        case expense
        case income
        case transfer
        case uncategorize
        case unknown
    }
    
    static let entityName = "TransactionCategory"
    
    var primaryID: Int64 {
        get {
            return transactionCategoryID
        }
    }
    
    var linkedID: Int64? {
        get {
            return nil
        }
    }
    
    public var categoryType: CategoryType {
        get {
            return CategoryType(rawValue: categoryTypeRawValue!)!
        }
        set {
            categoryTypeRawValue = newValue.rawValue
        }
    }
    
    public var defaultBudgetCategory: BudgetCategory {
        get {
            return BudgetCategory(rawValue: defaultBudgetCategoryRawValue!)!
        }
        set {
            defaultBudgetCategoryRawValue = newValue.rawValue
        }
    }
    
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
    
    func linkObject(object: CacheableManagedObject) {
        // Do nothing
    }
    
    func update(response: APIUniqueResponse, context: NSManagedObjectContext) {
        if let transactionCategoryResponse = response as? APITransactionCategoryResponse {
            update(response: transactionCategoryResponse, context: context)
        }
    }
    
    func update(response: APITransactionCategoryResponse, context: NSManagedObjectContext) {
        transactionCategoryID = response.id
        categoryType = response.categoryType
        defaultBudgetCategory = response.defaultBudgetCategory
        iconURLString = response.iconURL
        name = response.name
        placement = response.placement
        userDefined = response.userDefined
    }

}
