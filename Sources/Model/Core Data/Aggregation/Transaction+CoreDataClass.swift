//
// Copyright © 2018 Frollo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//

import CoreData
import Foundation

/**
 Transaction
 
 Core Data representation of a transaction from an account
 */
public class Transaction: NSManagedObject, UniqueManagedObject {
    
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
    
    internal static var primaryKey = #keyPath(Transaction.transactionID)
    
    /// Date formatter to convert from stored date string to user's current locale
    public static let transactionDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    internal var primaryID: Int64 {
        return transactionID
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
            return Status(rawValue: statusRawValue)!
        }
        set {
            statusRawValue = newValue.rawValue
        }
    }
    
    /// Date the transaction occurred, localized
    public var transactionDate: Date {
        get {
            if let date = Transaction.transactionDateFormatter.date(from: transactionDateString) {
                return date
            } else {
                Log.error("Crash occured in \(transactionID) with date \(transactionDateString)")
                fatalError()
            }
        }
        set {
            transactionDateString = Transaction.transactionDateFormatter.string(from: newValue)
        }
    }
    
    /// The names of the tags related to this transaction
    public var userTags: [String] {
        get {
            let tags = userTagsRawValue?.components(separatedBy: "|") ?? []
            return tags.filter { (tag) -> Bool in
                !tag.isEmpty
            }
        }
        set {
            let tagsString = newValue.joined(separator: "|")
            userTagsRawValue = "|" + tagsString + "|"
        }
    }
    
    // MARK: - Updating Object
    
    internal func linkObject(object: NSManagedObject) {
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
        externalID = response.externalID
        included = response.included
        merchantID = response.merchant.id
        memo = response.memo
        originalDescription = response.description.original
        postDateString = response.postDate
        simpleDescription = response.description.simple
        status = response.status
        transactionCategoryID = response.categoryID
        transactionDateString = response.transactionDate
        userDescription = response.description.user
        userTags = response.userTags
        searchAmount = response.amount.amount
        
        // Only update info if present to avoid losing information when fetching on different APIs
        if let merchantPhone = response.merchant.phone {
            phone = merchantPhone
        }
        
        if let merchantWebsite = response.merchant.website {
            website = merchantWebsite
        }
        
        if let location = response.merchant.location {
            addressLine1 = location.line1
            addressLine2 = location.line2
            addressLine3 = location.line3
            country = location.country
            formattedAddress = location.formattedAddress
            latitude = location.latitude ?? Double.nan
            longitude = location.longitude ?? Double.nan
            postcode = location.postcode
            state = location.state
            suburb = location.suburb
        }
    }
    
    internal func updateRequest() -> APITransactionUpdateRequest {
        return APITransactionUpdateRequest(budgetCategory: budgetCategory,
                                           categoryID: transactionCategoryID,
                                           included: included,
                                           memo: memo,
                                           userDescription: userDescription,
                                           budgetApplyAll: nil,
                                           includeApplyAll: nil,
                                           recategoriseAll: nil)
    }
    
}
