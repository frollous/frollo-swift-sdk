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

import Foundation

struct APITransactionResponse: APIUniqueResponse, Codable {
    
    enum CodingKeys: String, CodingKey {
        case accountID = "account_id"
        case amount
        case baseType = "base_type"
        case billID = "bill_id"
        case billPaymentID = "bill_payment_id"
        case budgetCategory = "budget_category"
        case categoryID = "category_id"
        case description
        case id
        case included
        case memo
        case merchantID = "merchant_id"
        case postDate = "post_date"
        case status
        case transactionDate = "transaction_date"
    }
    
    struct Amount: Codable {
        
        enum CodingKeys: String, CodingKey {
            case amount
            case currency
        }
        
        let amount: String
        let currency: String
        
    }
    
    struct Description: Codable {
        
        enum CodingKeys: String, CodingKey {
            case original
            case simple
            case user
        }
        
        let original: String
        let simple: String?
        let user: String?
        
    }
    
    var id: Int64
    let accountID: Int64
    let amount: Amount
    let baseType: Transaction.BaseType
    let billID: Int64?
    let billPaymentID: Int64?
    let budgetCategory: BudgetCategory
    let categoryID: Int64
    let description: Description
    let included: Bool
    let memo: String?
    let merchantID: Int64
    let postDate: String?
    let status: Transaction.Status
    let transactionDate: String
    
}
