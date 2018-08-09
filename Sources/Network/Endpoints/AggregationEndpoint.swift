//
//  Aggregation.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 31/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

enum AggregationEndpoint: Endpoint {
    
    enum QueryParameters: String, Codable {
        case fromDate = "from_date"
        case toDate = "to_date"
    }
    
    internal var path: String {
        get {
            return urlPath()
        }
    }
    
    case account(accountID: Int64)
    case accounts
    case merchants
    case provider(providerID: Int64)
    case providers
    case providerAccount(providerAccountID: Int64)
    case providerAccounts
    case transaction(transactionID: Int64)
    case transactions
    case transactionCategories
    
    private func urlPath() -> String {
        switch self {
            case .account(let accountID):
                return "aggregation/accounts/" + String(accountID)
            case .accounts:
                return "aggregation/accounts"
            case .merchants:
                return "aggregation/merchants"
            case .provider(let providerID):
                return "aggregation/providers/" + String(providerID)
            case .providers:
                return "aggregation/providers"
            case .providerAccount(let providerAccountID):
                return "aggregation/provideraccounts/" + String(providerAccountID)
            case .providerAccounts:
                return "aggregation/provideraccounts"
            case .transaction(let transactionID):
                return "aggregation/transactions/" + String(transactionID)
            case .transactions:
                return "aggregation/transactions"
            case .transactionCategories:
                return "aggregation/transactions/categories"
        }
    }
    
}
