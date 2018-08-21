//
//  BudgetCategory.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 7/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

public enum BudgetCategory: String, Codable {
    
    case income
    case lifestyle
    case living
    case oneOff = "one_off"
    case savings = "goals"
    
}
