//
//  APITransactionCategoryResponse.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 7/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

struct APITransactionCategoryResponse: APIUniqueResponse, Codable {
    
    enum CodingKeys: String, CodingKey {
        case categoryType = "category_type"
        case defaultBudgetCategory = "default_budget_category"
        case iconURL = "icon_url"
        case id
        case name
        case placement
        case userDefined = "user_defined"
    }
    
    var id: Int64
    let categoryType: TransactionCategory.CategoryType
    let defaultBudgetCategory: BudgetCategory
    let iconURL: String
    let name: String
    let placement: Int64
    let userDefined: Bool
    
}
