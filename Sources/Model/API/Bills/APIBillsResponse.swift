//
//  APIBillsResponse.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 18/12/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

struct APIBillsResponse: Codable {
    
    enum CodingKeys: String, CodingKey {
        case bills
        case budgetPeriod = "budget_period"
    }
    
    struct BudgetPeriod: Codable {
        
        enum CodingKeys: String, CodingKey {
            case amountPaid = "amount_paid"
            case amountRemaining = "amount_remaining"
        }
        
        let amountPaid: Decimal
        let amountRemaining: Decimal
        
    }
    
    let bills: [APIBillResponse]
    let budgetPeriod: BudgetPeriod
    
}
