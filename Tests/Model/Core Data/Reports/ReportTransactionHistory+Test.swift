//
//  ReportTransactionHistory+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 14/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import CoreData
import Foundation
@testable import FrolloSDK

extension ReportTransactionHistory: TestableCoreData {
    
    func populateTestData() {
        let category = Bool.random()
        
        budget = Bool.random() ? NSDecimalNumber(string: "2100") : nil
        budgetCategory = category ? BudgetCategory.allCases.randomElement() : nil
        linkedID = category ? Int64.random(in: 1...10000000) : -1
        grouping = ReportGrouping.allCases.randomElement()!
        period = Period.allCases.randomElement()!
        value = NSDecimalNumber(string: "1986.31")
        
        switch period {
            case .daily:
                dateString = "2018-03-01"
            case .monthly:
                dateString = "2018-03"
            case .weekly:
                dateString = "2018-26"
        }
    }
    
}
