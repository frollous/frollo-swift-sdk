//
//  ReportGrouping.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 11/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation

/**
 Report Grouping
 
 Represents how a transaction report response should be broken down. E.g. by merchant
 */
public enum ReportGrouping: String, Codable, CaseIterable {
    
    /// Budget category
    case budgetCategory = "by_budget_category"
    
    /// Merchant
    case merchant = "by_merchant"
    
    /// Transaction Category
    case transactionCategory = "by_transaction_category"
    
    /// Transaction Category Parent Group
    case transactionCategoryGroup = "by_transaction_category_group"
    
}
