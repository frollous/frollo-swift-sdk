//
//  APITransactionUpdateRequest.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 9/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

struct APITransactionUpdateRequest: Codable {
    
    enum CodingKeys: String, CodingKey {
        case budgetCategory = "budget_category"
        case categoryID = "category_id"
        case included
        case includeApplyAll = "include_apply_all"
        case memo
        case recategoriseAll = "recategorise_all"
        case userDescription = "user_description"
    }
    
    let budgetCategory: BudgetCategory
    let categoryID: Int64
    let included: Bool
    let memo: String?
    let userDescription: String?
    
    var includeApplyAll: Bool?
    var recategoriseAll: Bool?
    
}
