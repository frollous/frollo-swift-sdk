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
    
    // Array of `transactionID` to filter transactions
    public var transactionIDs: [Int64]? = nil
    
    // Array of `accountID` to filter transactions
    public var accountIDs: [Int64]? = nil
    
    // Array of `BudgetCategory` to filter transactions
    public var budgetCategories: [BudgetCategory]? = nil
    
    // Array of `transactionCategoryID` to filter transactions
    public var transactionCategoryIDs: [Int64]? = nil
    
    // Array of `mechantID` to filter transactions
    public var merchantIDs: [Int64]? = nil
    
    // Search term to filter transactions
    public var searchTerm: String? = nil
    
    // Amount to filter tramsactions from (inclusive)
    public var minimumAmount: String? = nil
    
    // Amount to filter transactions to (inclusive)
    public var maximumAmount: String? = nil
    
    // 'BaseType' to filter transactions
    public var baseType: Transaction.BaseType? = nil
    
    // Array of tags to filter transactions
    public var tags: [String]? = nil
    
    // 'Status' to filter transactions
    public var status: Transaction.Status? = nil
    
    // Date to filter transactions from (inclusive)
    public var fromDate: String? = nil
    
    // Date to filter transactions to (inclusive)
    public var toDate: String? = nil
    
    // 'included' status of 'Transaction' to filter by
    public var transactionIncluded: Bool? = nil
    
    // 'included' status of 'Account' to filter by
    public var accountIncluded: Bool? = nil
    
    // after field to get next list in pagination. Format is "<epoch_date>_<transaction_id>"
    public var after: String? = nil
    
    // after field to get previous list in pagination. Format is "<epoch_date>_<transaction_id>"
    public var before: String? = nil
    
    
    internal var filterPredicates: [NSPredicate]{
        
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
        if let transactionIDs = transactionIDs {
            filterPredicates.append(NSPredicate(format: #keyPath(Transaction.transactionID) + " IN %@ ", argumentArray: [transactionIDs]))
        }
        
        // Filter by accountIDs
        if let accountIDs = accountIDs {
            filterPredicates.append(NSPredicate(format: #keyPath(Transaction.accountID) + " IN %@ ", argumentArray: [accountIDs]))
        }
        
        // Filter by transaction categoryIDs
        if let transactionCategoryIDs = transactionCategoryIDs {
            filterPredicates.append(NSPredicate(format: #keyPath(Transaction.transactionCategoryID) + " IN %@ ", argumentArray: [transactionCategoryIDs]))
        }
        
        // Filter by budget categories
        if let budgetCategories = budgetCategories {
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
        
        // Filter by search term
        if let searchTerm = searchTerm, searchTerm.count > 1 {
            var searchTermPredicates: [NSPredicate] = []
            
            searchTermPredicates.append(NSPredicate(format: #keyPath(Transaction.userDescription) + " CONTAINS[cd] %@ ", argumentArray: [searchTerm]))
            
            searchTermPredicates.append(NSPredicate(format: #keyPath(Transaction.simpleDescription) + " CONTAINS[cd] %@ ", argumentArray: [searchTerm]))
            
            searchTermPredicates.append(NSPredicate(format: #keyPath(Transaction.originalDescription) + " CONTAINS[cd] %@ ", argumentArray: [searchTerm]))
            
            searchTermPredicates.append(NSPredicate(format: #keyPath(Transaction.memo) + " CONTAINS[cd] %@ ", argumentArray: [searchTerm]))
            
            filterPredicates.append(NSCompoundPredicate(orPredicateWithSubpredicates: searchTermPredicates))
        }
        
        return filterPredicates
        
    }
    
    
    internal var transactionFilterURLString: String {
        
        var transactionBaseURL = "aggregation/transactions?"
        
        if let accountIDs = accountIDs, accountIDs.count > 0 {
            transactionBaseURL.append("account_ids=")
            transactionBaseURL.append(accountIDs.map { String($0) }.joined(separator: ","))
            transactionBaseURL.append("&")
        }
        
        if let transactionIDs = transactionIDs {
            transactionBaseURL.append("transaction_ids=")
            transactionBaseURL.append(transactionIDs.map { String($0) }.joined(separator: ","))
            transactionBaseURL.append("&")
        }
        
        if let merchantIDs = merchantIDs {
            transactionBaseURL.append("merchant_ids=")
            transactionBaseURL.append(merchantIDs.map { String($0) }.joined(separator: ","))
            transactionBaseURL.append("&")
        }
        
        if let transactionCategoryIDs = transactionCategoryIDs {
            transactionBaseURL.append("transaction_category_ids=")
            transactionBaseURL.append(transactionCategoryIDs.map { String($0) }.joined(separator: ","))
            transactionBaseURL.append("&")
        }
        
        if let searchTerm = searchTerm {
            transactionBaseURL.append("search_term=")
            transactionBaseURL.append(searchTerm)
            transactionBaseURL.append("&")
        }
        
        if let budgetCategories = budgetCategories {
            transactionBaseURL.append("budget_category=")
            transactionBaseURL.append((budgetCategories.map { $0.rawValue }).joined(separator: ","))
            transactionBaseURL.append("&")
        }
        
        if let minAmount = minimumAmount {
            transactionBaseURL.append("min_amount=")
            transactionBaseURL.append(minAmount)
            transactionBaseURL.append("&")
        }
        
        if let maxAmount = maximumAmount {
            transactionBaseURL.append("max_amount=")
            transactionBaseURL.append(maxAmount)
            transactionBaseURL.append("&")
        }
        
        if let fromDate = fromDate {
            transactionBaseURL.append("from_date=")
            transactionBaseURL.append(fromDate)
            transactionBaseURL.append("&")
        }
        
        if let toDate = toDate {
            transactionBaseURL.append("to_date=")
            transactionBaseURL.append(toDate)
            transactionBaseURL.append("&")
        }
        
        if let baseType = baseType {
            transactionBaseURL.append("base_type=")
            transactionBaseURL.append(baseType.rawValue)
            transactionBaseURL.append("&")
        }
        
        if let transactionIncluded = transactionIncluded {
            transactionBaseURL.append("transaction_included=")
            transactionBaseURL.append(transactionIncluded ? "true" : "false")
            transactionBaseURL.append("&")
        }
        
        if let accountIncluded = transactionIncluded {
            transactionBaseURL.append("account_included=")
            transactionBaseURL.append(accountIncluded ? "true" : "false")
            transactionBaseURL.append("&")
        }
        
        if let tags = tags {
            transactionBaseURL.append("tags=")
            transactionBaseURL.append(tags.joined(separator: ","))
            transactionBaseURL.append("&")
        }
        
        if let after = after {
            transactionBaseURL.append("after=")
            transactionBaseURL.append(after)
            transactionBaseURL.append("&")
        }
        
        if transactionBaseURL.last == "&" || transactionBaseURL.last == "?" {
            transactionBaseURL = String(transactionBaseURL.dropLast())
        }
        
        return transactionBaseURL
        
    }
}
