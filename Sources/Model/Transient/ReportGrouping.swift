//
//  ReportGrouping.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 11/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation

public enum ReportGrouping: String, Codable, CaseIterable {
    
    case budgetCategory = "by_budget_Category"
    case merchant = "by_merchant"
    case transactionCategory = "by_transaction_category"
    case transactionCategoryGroup = "by_transaction_category_group"
    
}
