//
//  APIAccountBalanceReportResponse.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 29/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation

struct APIAccountBalanceReportResponse: Codable {
    
    struct Report: Codable {
        
        struct BalanceReport: Codable {
            
            let currency: String
            let id: Int64
            let value: String
            
        }
        
        let accounts: [BalanceReport]
        let date: String
        let value: String
        
    }
    
    let data: [Report]
    
}
