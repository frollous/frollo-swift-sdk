//
//  ReportTransactionCurrent+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 14/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import CoreData
import Foundation
@testable import FrolloSDK

extension ReportTransactionCurrent: TestableCoreData {
    
    internal func populateTestData() {
        amount = NSDecimalNumber(string: "34.67")
        average = NSDecimalNumber(string: "29.50")
        budget = NSDecimalNumber(string: "30.00")
        budgetCategory = Bool.random() ? BudgetCategory.allCases.randomElement() : nil
        day = Int64.random(in: 1...31)
        grouping = ReportGrouping.allCases.randomElement()!
        name = String.randomString(range: 3...30)
        merchantID = Bool.random() ? Int64.random(in: 1...1000000) : -1
        previous = NSDecimalNumber(string: "31.33")
    }
    
}
