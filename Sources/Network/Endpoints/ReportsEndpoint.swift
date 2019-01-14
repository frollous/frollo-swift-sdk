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
        case budgetCategory = "budget_category"
        case fromDate = "from_date"
        case grouping
        case period
        case toDate = "to_date"
    }
    
    internal var path: String {
        get {
            return urlPath()
        }
    }
    
    case transactionsCurrent
    case transactionsHistory
    
    private func urlPath() -> String {
        switch self {
            case .transactionsCurrent:
                return "reports/transactions/current"
            case .transactionsHistory:
                return "reports/transactions/history"
        }
    }
    
}
