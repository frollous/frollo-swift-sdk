//
//  Aggregation.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 31/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

enum AggregationEndpoint: Endpoint {
    
    internal var path: String {
        get {
            return urlPath()
        }
    }
    
    case provider(providerID: Int64)
    case providers
    case providerAccount(providerAccountID: Int64)
    case providerAccounts
    
    private func urlPath() -> String {
        switch self {
            case .provider(let providerID):
                return "aggregation/providers/" + String(providerID)
            case .providers:
                return "aggregation/providers"
            case .providerAccount(let providerAccountID):
                return "aggregation/provideraccounts/" + String(providerAccountID)
            case .providerAccounts:
                return "aggregation/provideraccounts"
        }
    }
    
}
