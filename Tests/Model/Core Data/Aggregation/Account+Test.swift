//
// Copyright © 2018 Frollo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
@testable import FrolloSDK

extension Account: TestableCoreData {
    
    func populateTestData() {
        accountID = Int64.random(in: 1...Int64.max)
        providerAccountID = Int64.random(in: 1...Int64.max)
        externalID = UUID().uuidString
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
        group = .bank
        hidden = false
        included = true
        favourite = true
    }
    
    func populateTestData(withID id: Int64) {
        populateTestData()
        
        accountID = id
    }
    
}
