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
        case category
        case description
        case externalID = "external_id"
        case goalID = "goal_id"
        case id
        case included
        case memo
        case merchant
        case postDate = "post_date"
        case status
        case transactionDate = "transaction_date"
        case userTags = "user_tags"
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
    
    struct Merchant: Codable {
        
        struct Location: Codable {
            
            enum CodingKeys: String, CodingKey {
                case country
                case formattedAddress = "formatted_address"
                case latitude
                case line1 = "line_1"
                case line2 = "line_2"
                case line3 = "line_3"
                case longitude
                case postcode
                case state
                case suburb
            }
            
            let country: String?
            let formattedAddress: String?
            let latitude: Double?
            let line1: String?
            let line2: String?
            let line3: String?
            let longitude: Double?
            let postcode: String?
            let state: String?
            let suburb: String?
            
        }
        
        let id: Int64
        let location: Location?
        let name: String
        let phone: String?
        let website: String?
        
    }
    
    struct Category: Codable {
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case imageURL = "image_url"
        }
        
        let id: Int64
        let name: String
        let imageURL: String?
    }
    
    var id: Int64
    let accountID: Int64
    let amount: Amount
    let baseType: Transaction.BaseType
    let billID: Int64?
    let billPaymentID: Int64?
    let budgetCategory: BudgetCategory
    let category: Category
    let description: Description
    let externalID: String?
    let goalID: Int64?
    let included: Bool
    let memo: String?
    let merchant: Merchant
    let postDate: String?
    let status: Transaction.Status
    let transactionDate: String
    let userTags: [String]
    
}
