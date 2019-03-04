//
//  ReportsEndpoint.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 14/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation

internal enum ReportsEndpoint: Endpoint {
    
    enum QueryParameters: String, Codable {
        case accountID = "account_id"
        case budgetCategory = "budget_category"
        case container
        case fromDate = "from_date"
        case grouping
        case period
        case toDate = "to_date"
    }
    
    internal var path: String {
        return urlPath()
    }
    
    case accountBalance
    case transactionsCurrent
    case transactionsHistory
    
    private func urlPath() -> String {
        switch self {
            case .accountBalance:
                return "reports/accounts/history/balances"
            case .transactionsCurrent:
                return "reports/transactions/current"
            case .transactionsHistory:
                return "reports/transactions/history"
        }
    }
    
}
