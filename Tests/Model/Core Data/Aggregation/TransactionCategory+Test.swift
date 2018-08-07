//
//  TransactionCategory+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 7/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation
@testable import FrolloSDK

extension TransactionCategory: TestableCoreData {
    
    func populateTestData() {
        transactionCategoryID = Int64(arc4random())
        categoryType = .expense
        defaultBudgetCategory = .living
        iconURLString = "https://example.com/category.png"
        name = UUID().uuidString
        userDefined = false
    }
    
}
