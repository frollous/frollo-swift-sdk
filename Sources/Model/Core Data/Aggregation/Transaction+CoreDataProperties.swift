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
