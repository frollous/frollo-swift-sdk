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

extension APIAccountResponse {
    
    static func testCompleteData() -> APIAccountResponse {
        let balanceDetails = BalanceDetails(currentDescription: UUID().uuidString, tiers: [BalanceTier(description: UUID().uuidString, min: Int64(arc4random()), max: Int64(arc4random()))])
        
        let holderProfile = HolderProfile(name: "Jacob Frollo")
        
        let refreshStatus = RefreshStatus(status: .needsAction,
                                          additionalStatus: .mfaNeeded,
                                          lastRefreshed: Date(timeIntervalSince1970: 1533183204),
                                          nextRefresh: Date(timeIntervalSince1970: 1533183224),
                                          subStatus: .inputRequired)
        
        let attributes = Attributes(accountType: Account.AccountSubType.allCases.randomElement()!,
                                    classification: Account.Classification.allCases.randomElement(),
                                    container: Account.AccountType.allCases.randomElement()!,
                                    group: Account.Group.allCases.randomElement()!)
        
        return APIAccountResponse(id: 547891,
                                  accountAttributes: attributes,
                                  accountName: UUID().uuidString,
                                  accountStatus: .active,
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
