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
    
    static func testCompleteData() -> APIAccountResponse {
        let balanceDetails = BalanceDetails(currentDescription: UUID().uuidString, tiers: [BalanceTier(description: UUID().uuidString, min: Int64(arc4random()), max: Int64(arc4random()))])
        
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
                                  container: .bank,
                                  favourite: true,
                                  hidden: false,
                                  included: true,
                                  providerAccountID: 76251,
                                  providerName: "Detailed Test Provider",
                                  refreshStatus: refreshStatus,
                                  amountDue: Balance(amount: String(arc4random()), currency: "AUD"),
                                  apr: "18.53",
                                  availableBalance: Balance(amount: String(arc4random()), currency: "AUD"),
                                  availableCash: Balance(amount: String(arc4random()), currency: "AUD"),
                                  availableCredit: Balance(amount: String(arc4random()), currency: "AUD"),
                                  balanceDetails: balanceDetails,
                                  classification: .personal,
                                  currentBalance: Balance(amount: String(arc4random()), currency: "AUD"),
                                  dueDate: Date(timeIntervalSinceNow: 10000),
                                  holderProfile: holderProfile,
                                  interestRate: "3.05",
                                  lastPaymentAmount: Balance(amount: String(arc4random()), currency: "AUD"),
                                  lastPaymentDate: Date(timeIntervalSinceNow: -10000),
                                  minimumAmountDue: Balance(amount: String(arc4random()), currency: "AUD"),
                                  nickName: "Friendly Name",
                                  totalCashLimit: Balance(amount: String(arc4random()), currency: "AUD"),
                                  totalCreditLine: Balance(amount: String(arc4random()), currency: "AUD"))
    }
    
}
