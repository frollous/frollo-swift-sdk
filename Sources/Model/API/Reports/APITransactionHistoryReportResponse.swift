//
//  APITransactionHistoryReportResponse.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 14/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation

struct APITransactionHistoryReportsResponse: Codable {
    
    struct Report: Codable {
        
        struct GroupReport: Codable {
            
            let budget: String?
            let id: Int64
            let name: String
            let value: String
            
        }
        
        let groups: [GroupReport]
        let date: String
        let value: String
        
    }
    
    let data: [Report]
    
}
