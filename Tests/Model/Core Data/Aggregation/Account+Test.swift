//
//  Account+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 6/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation
@testable import FrolloSDK

extension Account: TestableCoreData {
    
    func populateTestData() {
        accountID = Int64(arc4random())
        providerAccountID = Int64(arc4random())
        accountName = UUID().uuidString
        nickName = UUID().uuidString
        providerName = UUID().uuidString
        amountDue = (Decimal(arc4random()) / 10) as NSDecimalNumber
        amountDueCurrency = "AUD"
        currentBalance = (Decimal(arc4random()) / 10) as NSDecimalNumber
        currentBalanceCurrency = "AUD"
        availableCash = (Decimal(arc4random()) / 10) as NSDecimalNumber
        availableCashCurrency = "AUD"
        availableCredit = (Decimal(arc4random()) / 10) as NSDecimalNumber
        availableCreditCurrency = "AUD"
        availableBalance = (Decimal(arc4random()) / 10) as NSDecimalNumber
        availableBalanceCurrency = "AUD"
        totalCashLimit = (Decimal(arc4random()) / 10) as NSDecimalNumber
        totalCashLimitCurrency = "AUD"
        totalCreditLine = (Decimal(arc4random()) / 10) as NSDecimalNumber
        totalCreditLineCurrency = "AUD"
        minimumAmountDue = (Decimal(arc4random()) / 10) as NSDecimalNumber
        minimumAmountDueCurrency = "AUD"
        lastPaymentAmount = (Decimal(arc4random()) / 10) as NSDecimalNumber
        lastPaymentAmountCurrency = "AUD"
        accountHolderName = UUID().uuidString
        balanceDescription = UUID().uuidString
        lastPaymentDate = Date(timeIntervalSinceNow: -10000)
        dueDate = Date(timeIntervalSinceNow: 10000)
        nextRefresh = Date(timeIntervalSinceNow: 1000)
        lastRefreshed = Date(timeIntervalSinceNow: -1000)
        refreshStatus = .success
        refreshSubStatus = .success
        interestRate = 3.05
        apr = 18.97
        accountStatus = .active
        accountType = .bank
        accountSubType = .savings
        classification = .personal
        hidden = false
        included = true
        favourite = true
    }
    
}
