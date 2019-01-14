//
//  BudgetCategory.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 7/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

/**
 Budget Category
 
 Indicates a budget type
 */
public enum BudgetCategory: String, Codable, CaseIterable {
    
    /// Income budget
    case income
    
    /// Lifestyle budget
    case lifestyle
    
    /// Living budget
    case living
    
    /// One offs budget
    case oneOff = "one_off"
    
    /// Savings budget
    case savings = "goals"
    
}
