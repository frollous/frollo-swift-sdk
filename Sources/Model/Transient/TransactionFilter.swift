//
//  Copyright © 2019 Frollo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

// Repersents a model that contains all the filters to apply on transaction list
public struct TransactionFilter {
    
    // Initializer
    public init(transactionIDs: [Int64]? = nil, accountIDs: [Int64]? = nil, budgetCategories: [BudgetCategory]? = nil, transactionCategoryIDs: [Int64]? = nil, merchantIDs: [Int64]? = nil, searchTerm: String? = nil, minimumAmount: String? = nil, maximumAmount: String? = nil, baseType: Transaction.BaseType? = nil, tags: [String]? = nil, status: Transaction.Status? = nil, fromDate: String? = nil, toDate: String? = nil, transactionIncluded: Bool? = nil, accountIncluded: Bool? = nil, after: String? = nil, before: String? = nil) {
        
        self.transactionIDs = transactionIDs
        self.accountIDs = accountIDs
        self.budgetCategories = budgetCategories
        self.transactionCategoryIDs = transactionCategoryIDs
        self.merchantIDs = merchantIDs
        self.searchTerm = searchTerm
        self.minimumAmount = minimumAmount
        self.maximumAmount = maximumAmount
        self.baseType = baseType
        self.tags = tags
        self.status = status
        self.fromDate = fromDate
        self.toDate = toDate
        self.transactionIncluded = transactionIncluded
        self.accountIncluded = accountIncluded
        self.after = after
        self.before = before
    }
    
    // Array of `Transaction.transactionID` to filter transactions
    public var transactionIDs: [Int64]?
    
    // Array of `Transaction.accountID` to filter transactions
    public var accountIDs: [Int64]?
    
    // Array of `BudgetCategory` to filter transactions
    public var budgetCategories: [BudgetCategory]?
    
    // Array of `Transaction.transactionCategoryID` to filter transactions
    public var transactionCategoryIDs: [Int64]?
    
    // Array of `Transaction.mechantID` to filter transactions
    public var merchantIDs: [Int64]?
    
    // Search term to filter transactions
    public var searchTerm: String?
    
    // Amount to filter tramsactions from (inclusive)
    public var minimumAmount: String?
    
    // Amount to filter transactions to (inclusive)
    public var maximumAmount: String?
    
    // 'Transaction.BaseType' to filter transactions
    public var baseType: Transaction.BaseType?
    
    // Array of tags to filter transactions
    public var tags: [String]?
    
    // 'Transaction.Status' to filter transactions
    public var status: Transaction.Status?
    
    // Date to filter transactions from (inclusive)
    public var fromDate: String?
    
    // Date to filter transactions to (inclusive)
    public var toDate: String?
    
    // 'included' status of 'Transaction' to filter by
    public var transactionIncluded: Bool?
    
    // 'included' status of 'Account' to filter by
    public var accountIncluded: Bool?
    
    // after field to get next list in pagination. Format is "<epoch_date>_<transaction_id>"
    public var after: String?
    
    // after field to get previous list in pagination. Format is "<epoch_date>_<transaction_id>"
    public var before: String?
    
    // predicates for `TransactionFilter`
    public var filterPredicates: [NSPredicate] {
        
        var filterPredicates = [NSPredicate]()
        
        // Filter by from Date
        if let fromDate = fromDate, let date = Transaction.transactionDateFormatter.date(from: fromDate) {
            let fromDateString = Transaction.transactionDateFormatter.string(from: date)
            filterPredicates.append(NSPredicate(format: #keyPath(Transaction.transactionDateString) + " >= %@ ", argumentArray: [fromDateString]))
        }
        
        // Filter by to Date
        if let toDate = toDate, let date = Transaction.transactionDateFormatter.date(from: toDate) {
            let toDateString = Transaction.transactionDateFormatter.string(from: date)
            filterPredicates.append(NSPredicate(format: #keyPath(Transaction.transactionDateString) + " <= %@ ", argumentArray: [toDateString]))
        }
        
        // Filter by transactionIDs
        if let transactionIDs = transactionIDs, !transactionIDs.isEmpty {
            filterPredicates.append(NSPredicate(format: #keyPath(Transaction.transactionID) + " IN %@ ", argumentArray: [transactionIDs]))
        }
        
        // Filter by accountIDs
        if let accountIDs = accountIDs, !accountIDs.isEmpty {
            filterPredicates.append(NSPredicate(format: #keyPath(Transaction.accountID) + " IN %@ ", argumentArray: [accountIDs]))
        }
        
        // Filter by transaction categoryIDs
        if let transactionCategoryIDs = transactionCategoryIDs, !transactionCategoryIDs.isEmpty {
            filterPredicates.append(NSPredicate(format: #keyPath(Transaction.transactionCategoryID) + " IN %@ ", argumentArray: [transactionCategoryIDs]))
        }
        
        // Filter by budget categories
        if let budgetCategories = budgetCategories, !budgetCategories.isEmpty {
            filterPredicates.append(NSPredicate(format: #keyPath(Transaction.budgetCategoryRawValue) + " IN %@ ", argumentArray: [budgetCategories.map { $0.rawValue }]))
        }
        
        // Filter by basetype
        if let baseType = baseType {
            filterPredicates.append(NSPredicate(format: #keyPath(Transaction.baseTypeRawValue) + " == %@", argumentArray: [baseType.rawValue]))
        }
        
        // Filter by minimum amount
        if let minimumAmount = minimumAmount {
            filterPredicates.append(NSPredicate(format: #keyPath(Transaction.amount) + " >= %@ ", argumentArray: [NSDecimalNumber(string: minimumAmount)]))
        }
        
        // Filter by maximum amount
        if let maximumAmount = maximumAmount {
            filterPredicates.append(NSPredicate(format: #keyPath(Transaction.amount) + " <= %@ ", argumentArray: [NSDecimalNumber(string: maximumAmount)]))
        }
        
        // Filter by status
        if let status = status {
            filterPredicates.append(NSPredicate(format: #keyPath(Transaction.statusRawValue) + " == %@ ", argumentArray: [status.rawValue]))
        }
        
        // Filter by tag
        if let tags = tags, !tags.isEmpty {
            var tagsPredicate = [NSPredicate]()
            tags.forEach { tagName in
                tagsPredicate.append(NSPredicate(format: #keyPath(Transaction.userTagsRawValue) + " CONTAINS[cd] %@", argumentArray: [tagName]))
            }
            filterPredicates.append(NSCompoundPredicate(orPredicateWithSubpredicates: tagsPredicate))
        }
        
        // Filter by transaction Included
        if let transactionIncluded = transactionIncluded {
            filterPredicates.append(NSPredicate(format: #keyPath(Transaction.included) + " == %@", argumentArray: [transactionIncluded ? "TRUE" : "FALSE"]))
        }
        
        // Filter by account Included
        if let accountIncluded = accountIncluded {
            filterPredicates.append(NSPredicate(format: #keyPath(Transaction.account.included) + " == %@", argumentArray: [accountIncluded ? "TRUE" : "FALSE"]))
        }
        
        // Filter by search term
        if let searchTerm = searchTerm, !searchTerm.isEmpty {
            var searchTermPredicates: [NSPredicate] = []
            
            searchTermPredicates.append(NSPredicate(format: #keyPath(Transaction.userDescription) + " CONTAINS[cd] %@ ", argumentArray: [searchTerm]))
            
            searchTermPredicates.append(NSPredicate(format: #keyPath(Transaction.simpleDescription) + " CONTAINS[cd] %@ ", argumentArray: [searchTerm]))
            
            searchTermPredicates.append(NSPredicate(format: #keyPath(Transaction.originalDescription) + " CONTAINS[cd] %@ ", argumentArray: [searchTerm]))
            
            searchTermPredicates.append(NSPredicate(format: #keyPath(Transaction.memo) + " CONTAINS[cd] %@ ", argumentArray: [searchTerm]))
            
            filterPredicates.append(NSCompoundPredicate(orPredicateWithSubpredicates: searchTermPredicates))
        }
        
        return filterPredicates
        
    }
    
    internal var urlString: String? {
        
        var urlComponents = URLComponents()
        urlComponents.path = "aggregation/transactions"
        var queryItems = [URLQueryItem]()
        
        if let accountIDs = accountIDs, !accountIDs.isEmpty {
            queryItems.append(URLQueryItem(name: "account_ids", value: accountIDs.map { String($0) }.joined(separator: ",")))
        }
        
        if let transactionIDs = transactionIDs, !transactionIDs.isEmpty {
            queryItems.append(URLQueryItem(name: "transaction_ids", value: transactionIDs.map { String($0) }.joined(separator: ",")))
        }
        
        if let merchantIDs = merchantIDs, !merchantIDs.isEmpty {
            queryItems.append(URLQueryItem(name: "merchant_ids", value: merchantIDs.map { String($0) }.joined(separator: ",")))
        }
        
        if let transactionCategoryIDs = transactionCategoryIDs, !transactionCategoryIDs.isEmpty {
            queryItems.append(URLQueryItem(name: "transaction_category_ids", value: transactionCategoryIDs.map { String($0) }.joined(separator: ",")))
        }
        
        if let searchTerm = searchTerm, searchTerm.count > 0 {
            queryItems.append(URLQueryItem(name: "search_term", value: searchTerm))
        }
        
        if let budgetCategories = budgetCategories, !budgetCategories.isEmpty {
            queryItems.append(URLQueryItem(name: "budget_category", value: (budgetCategories.map { $0.rawValue }).joined(separator: ",")))
        }
        
        if let minAmount = minimumAmount {
            queryItems.append(URLQueryItem(name: "min_amount", value: minAmount))
        }
        
        if let maxAmount = maximumAmount {
            queryItems.append(URLQueryItem(name: "max_amount", value: maxAmount))
        }
        
        if let fromDate = fromDate {
            queryItems.append(URLQueryItem(name: "from_date", value: fromDate))
        }
        
        if let toDate = toDate {
            queryItems.append(URLQueryItem(name: "to_date", value: toDate))
        }
        
        if let baseType = baseType {
            queryItems.append(URLQueryItem(name: "base_type", value: baseType.rawValue))
        }
        
        if let transactionIncluded = transactionIncluded {
            queryItems.append(URLQueryItem(name: "transaction_included", value: transactionIncluded ? "true" : "false"))
        }
        
        if let accountIncluded = accountIncluded {
            queryItems.append(URLQueryItem(name: "account_included", value: accountIncluded ? "true" : "false"))
        }
        
        if let tags = tags, !tags.isEmpty {
            queryItems.append(URLQueryItem(name: "tags", value: tags.joined(separator: ",")))
        }
        
        if let after = after {
            queryItems.append(URLQueryItem(name: "after", value: after))
        }
        
        if !queryItems.isEmpty {
            urlComponents.queryItems = queryItems
        }
        
        return urlComponents.string
        
    }
}
