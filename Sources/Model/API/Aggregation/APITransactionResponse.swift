//
//  APITransactionResponse.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 8/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
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
        case description = "description"
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
