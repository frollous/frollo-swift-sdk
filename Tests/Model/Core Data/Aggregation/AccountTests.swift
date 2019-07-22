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

import XCTest
@testable import FrolloSDK

class AccountTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testUpdatingAccount() {
        let database = Database(path: tempFolderPath())
        
        let managedObjectContext = database.newBackgroundContext()
        
        managedObjectContext.performAndWait {
            let accountResponse = APIAccountResponse.testCompleteData()
            
            let account = Account(context: managedObjectContext)
            account.update(response: accountResponse, context: managedObjectContext)
            
            XCTAssertEqual(account.accountID, accountResponse.id)
            XCTAssertEqual(account.providerAccountID, accountResponse.providerAccountID)
            XCTAssertEqual(account.accountHolderName, accountResponse.holderProfile?.name)
            XCTAssertEqual(account.accountName, accountResponse.accountName)
            XCTAssertEqual(account.accountStatus, accountResponse.accountStatus)
            XCTAssertEqual(account.accountSubType, accountResponse.accountAttributes.accountType)
            XCTAssertEqual(account.accountType, accountResponse.accountAttributes.container)
            XCTAssertEqual(account.amountDue, NSDecimalNumber(string: accountResponse.amountDue?.amount))
            XCTAssertEqual(account.amountDueCurrency, accountResponse.amountDue?.currency)
            XCTAssertEqual(account.apr, NSDecimalNumber(string: accountResponse.apr))
            XCTAssertEqual(account.availableBalance, NSDecimalNumber(string: accountResponse.availableBalance?.amount))
            XCTAssertEqual(account.availableBalanceCurrency, accountResponse.availableBalance?.currency)
            XCTAssertEqual(account.availableCash, NSDecimalNumber(string: accountResponse.availableCash?.amount))
            XCTAssertEqual(account.availableCashCurrency, accountResponse.availableCash?.currency)
            XCTAssertEqual(account.availableCredit, NSDecimalNumber(string: accountResponse.availableCredit?.amount))
            XCTAssertEqual(account.availableCreditCurrency, accountResponse.availableCredit?.currency)
            XCTAssertEqual(account.balanceDescription, accountResponse.balanceDetails?.currentDescription)
            XCTAssertEqual(account.classification, accountResponse.accountAttributes.classification)
            XCTAssertEqual(account.currentBalance, NSDecimalNumber(string: accountResponse.currentBalance?.amount))
            XCTAssertEqual(account.currentBalanceCurrency, accountResponse.currentBalance?.currency)
            XCTAssertEqual(account.dueDate, accountResponse.dueDate)
            XCTAssertEqual(account.favourite, accountResponse.favourite)
            XCTAssertEqual(account.group, accountResponse.accountAttributes.group)
            XCTAssertEqual(account.hidden, accountResponse.hidden)
            XCTAssertEqual(account.included, accountResponse.included)
            XCTAssertEqual(account.interestRate, NSDecimalNumber(string: accountResponse.interestRate))
            XCTAssertEqual(account.lastPaymentAmount, NSDecimalNumber(string: accountResponse.lastPaymentAmount?.amount))
            XCTAssertEqual(account.lastPaymentAmountCurrency, accountResponse.lastPaymentAmount?.currency)
            XCTAssertEqual(account.lastPaymentDate, accountResponse.lastPaymentDate)
            XCTAssertEqual(account.lastRefreshed, accountResponse.refreshStatus.lastRefreshed)
            XCTAssertEqual(account.minimumAmountDue, NSDecimalNumber(string: accountResponse.minimumAmountDue?.amount))
            XCTAssertEqual(account.minimumAmountDueCurrency, accountResponse.minimumAmountDue?.currency)
            XCTAssertEqual(account.nextRefresh, accountResponse.refreshStatus.nextRefresh)
            XCTAssertEqual(account.nickName, accountResponse.nickName)
            XCTAssertEqual(account.providerName, accountResponse.providerName)
            XCTAssertEqual(account.refreshAdditionalStatus, accountResponse.refreshStatus.additionalStatus)
            XCTAssertEqual(account.refreshStatus, accountResponse.refreshStatus.status)
            XCTAssertEqual(account.refreshSubStatus, accountResponse.refreshStatus.subStatus)
            XCTAssertEqual(account.totalCashLimit, NSDecimalNumber(string: accountResponse.totalCashLimit?.amount))
            XCTAssertEqual(account.totalCashLimitCurrency, accountResponse.totalCashLimit?.currency)
            XCTAssertEqual(account.totalCreditLine, NSDecimalNumber(string: accountResponse.totalCreditLine?.amount))
            XCTAssertEqual(account.totalCreditLineCurrency, accountResponse.totalCreditLine?.currency)
            XCTAssertEqual(account.goalIDs, accountResponse.goalIDs)
            XCTAssertNotNil(account.balanceTiers)
            
            if let accountBalanceTiers = account.balanceTiers {
                XCTAssertEqual(accountBalanceTiers.first?.name, accountResponse.balanceDetails?.tiers.first?.description)
                XCTAssertEqual(accountBalanceTiers.first?.minimum, Decimal((accountResponse.balanceDetails?.tiers.first?.min)!) as NSDecimalNumber)
                XCTAssertEqual(accountBalanceTiers.first?.maximum, Decimal((accountResponse.balanceDetails?.tiers.first?.max)!) as NSDecimalNumber)
            } else {
                XCTFail("No balance tiers found")
            }
        }
    }
    
    func testUpdateAccountRequest() {
        let database = Database(path: tempFolderPath())
        
        let managedObjectContext = database.newBackgroundContext()
        
        managedObjectContext.performAndWait {
            let account = Account(context: managedObjectContext)
            account.populateTestData()
            
            let updateRequest = account.updateRequest()
            
            XCTAssertEqual(account.accountSubType, updateRequest.accountType)
            XCTAssertEqual(account.favourite, updateRequest.favourite)
            XCTAssertEqual(account.included, updateRequest.included)
            XCTAssertEqual(account.hidden, updateRequest.hidden)
            XCTAssertEqual(account.nickName, updateRequest.nickName)
        }
    }
    
}
