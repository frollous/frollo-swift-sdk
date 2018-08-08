//
//  Transaction+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 8/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation
@testable import FrolloSDK

extension Transaction: TestableCoreData {
    
    func populateTestData() {
        transactionID = Int64(arc4random())
        accountID = Int64(arc4random())
        merchantID = Int64(arc4random())
        transactionCategoryID = Int64(arc4random())
        merchantName = UUID().uuidString
        memo = UUID().uuidString
        originalDescription = UUID().uuidString
        simpleDescription = UUID().uuidString
        userDescription = UUID().uuidString
        amount = Decimal(186.99) as NSDecimalNumber
        currency = "AUD"
        included = false
        baseType = .debit
        budgetCategory = .lifestyle
        status = .pending
        postDate = Date(timeIntervalSinceNow: -1000)
        transactionDate = Date(timeIntervalSinceNow: -1000)
    }
    
}
