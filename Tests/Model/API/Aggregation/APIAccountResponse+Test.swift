//
//  APIAccountResponse+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 6/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation
@testable import FrolloSDK

extension APIAccountResponse {
    
    static func testCompleteDate() -> APIAccountResponse {
        let balanceDetails = BalanceDetails(currentDescription: UUID().uuidString, tiers: [BalanceTier(description: UUID().uuidString, min: Decimal(arc4random()), max: Decimal(arc4random())),
                                                                                           BalanceTier(description: UUID().uuidString, min: Decimal(arc4random()), max: Decimal(arc4random())),
                                                                                           BalanceTier(description: UUID().uuidString, min: Decimal(arc4random()), max: Decimal(arc4random()))])
        
        let holderProfile = HolderProfile(name: "Jacob Frollo")
        
        let refreshStatus = RefreshStatus(status: .needsAction,
                                          additionalStatus: .mfaNeeded,
                                          lastRefreshed: Date(timeIntervalSince1970: 1533183204),
                                          nextRefresh: Date(timeIntervalSince1970: 1533183224),
                                          subStatus: .inputRequired)
        
        return APIAccountResponse(id: 547891,
                                  accountName: UUID().uuidString,
                                  accountStatus: .active,
                                  accountType: .savings,
                                  classification: .personal,
                                  container: .bank,
                                  favourite: true,
                                  hidden: false,
                                  included: true,
                                  providerAccountID: 76251,
                                  providerName: "Detailed Test Provider",
                                  refreshStatus: refreshStatus,
                                  amountDue: Balance(amount: Decimal(arc4random()) / 10, currency: "AUD"),
                                  apr: 18.53,
                                  availableBalance: Balance(amount: Decimal(arc4random()) / 10, currency: "AUD"),
                                  availableCash: Balance(amount: Decimal(arc4random()) / 10, currency: "AUD"),
                                  availableCredit: Balance(amount: Decimal(arc4random()) / 10, currency: "AUD"),
                                  balanceDetails: balanceDetails,
                                  currentBalance: Balance(amount: Decimal(arc4random()) / 10, currency: "AUD"),
                                  dueDate: Date(timeIntervalSinceNow: 10000),
                                  holderProfile: holderProfile,
                                  interestRate: 3.05,
                                  lastPaymentAmount: Balance(amount: Decimal(arc4random()) / 10, currency: "AUD"),
                                  lastPaymentDate: Date(timeIntervalSinceNow: -10000),
                                  minimumAmountDue: Balance(amount: Decimal(arc4random()) / 10, currency: "AUD"),
                                  nickName: "Friendly Name",
                                  totalCashLimit: Balance(amount: Decimal(arc4random()) / 10, currency: "AUD"),
                                  totalCreditLine: Balance(amount: Decimal(arc4random()) / 10, currency: "AUD"))
    }
    
}
