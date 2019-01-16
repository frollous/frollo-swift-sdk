//
//  APITransactionCurrentReportResponse.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 14/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation

struct APITransactionCurrentReportResponse: Codable {
    
    struct Report: Codable {
        
        enum CodingKeys: String, CodingKey {
            
            case averageValue = "average_value"
            case budgetValue = "budget_value"
            case day
            case previousPeriodValue = "previous_period_value"
            case spendValue = "spend_value"
            
        }
        
        let averageValue: String?
        let budgetValue: String?
        let day: Int64
        let previousPeriodValue: String?
        let spendValue: String?
        
    }
    
    struct GroupReport: Codable {
        
        enum CodingKeys: String, CodingKey {
            
            case averageValue = "average_value"
            case budgetValue = "budget_value"
            case days
            case id
            case name
            case previousPeriodValue = "previous_period_value"
            case spendValue = "spend_value"
            
        }
        
        let averageValue: String?
        let budgetValue: String?
        let days: [Report]
        let id: Int64
        let name: String
        let previousPeriodValue: String?
        let spendValue: String?
        
    }
    
    let groups: [GroupReport]
    let days: [Report]
    
}
