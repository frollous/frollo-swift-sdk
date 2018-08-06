//
//  AccountTests.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 6/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
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
        
        let accountResponse = APIAccountResponse.testCompleteDate()
        
        let account = Account(context: managedObjectContext)
        account.update(response: accountResponse)
        
        XCTAssertEqual(account.accountID, accountResponse.id)
        XCTAssertEqual(account.providerAccountID, accountResponse.providerAccountID)
        XCTAssertEqual(account.accountHolderName, accountResponse.holderProfile?.name)
        XCTAssertEqual(account.accountName, accountResponse.accountName)
        XCTAssertEqual(account.accountStatus, accountResponse.accountStatus)
        XCTAssertEqual(account.accountSubType, accountResponse.accountType)
        XCTAssertEqual(account.accountType, accountResponse.container)
        XCTAssertEqual(account.amountDue, accountResponse.amountDue?.amount as NSDecimalNumber?)
        XCTAssertEqual(account.amountDueCurrency, accountResponse.amountDue?.currency)
        XCTAssertEqual(account.apr, accountResponse.apr as NSDecimalNumber?)
        XCTAssertEqual(account.availableBalance, accountResponse.availableBalance?.amount as NSDecimalNumber?)
        XCTAssertEqual(account.availableBalanceCurrency, accountResponse.availableBalance?.currency)
        XCTAssertEqual(account.availableCash, accountResponse.availableCash?.amount as NSDecimalNumber?)
        XCTAssertEqual(account.availableCashCurrency, accountResponse.availableCash?.currency)
        XCTAssertEqual(account.availableCredit, accountResponse.availableCredit?.amount as NSDecimalNumber?)
        XCTAssertEqual(account.availableCreditCurrency, accountResponse.availableCredit?.currency)
        XCTAssertEqual(account.balanceDescription, accountResponse.balanceDetails?.currentDescription)
        XCTAssertEqual(account.classification, accountResponse.classification)
        XCTAssertEqual(account.currentBalance, accountResponse.currentBalance?.amount as NSDecimalNumber?)
        XCTAssertEqual(account.currentBalanceCurrency, accountResponse.currentBalance?.currency)
        XCTAssertEqual(account.dueDate, accountResponse.dueDate)
        XCTAssertEqual(account.favourite, accountResponse.favourite)
        XCTAssertEqual(account.hidden, accountResponse.hidden)
        XCTAssertEqual(account.included, accountResponse.included)
        XCTAssertEqual(account.interestRate, accountResponse.interestRate as NSDecimalNumber?)
        XCTAssertEqual(account.lastPaymentAmount, accountResponse.lastPaymentAmount?.amount as NSDecimalNumber?)
        XCTAssertEqual(account.lastPaymentAmountCurrency, accountResponse.lastPaymentAmount?.currency)
        XCTAssertEqual(account.lastPaymentDate, accountResponse.lastPaymentDate)
        XCTAssertEqual(account.lastRefreshed, accountResponse.refreshStatus.lastRefreshed)
        XCTAssertEqual(account.minimumAmountDue, accountResponse.minimumAmountDue?.amount as NSDecimalNumber?)
        XCTAssertEqual(account.minimumAmountDueCurrency, accountResponse.minimumAmountDue?.currency)
        XCTAssertEqual(account.nextRefresh, accountResponse.refreshStatus.nextRefresh)
        XCTAssertEqual(account.nickName, accountResponse.nickName)
        XCTAssertEqual(account.providerName, accountResponse.providerName)
        XCTAssertEqual(account.refreshAdditionalStatus, accountResponse.refreshStatus.additionalStatus)
        XCTAssertEqual(account.refreshStatus, accountResponse.refreshStatus.status)
        XCTAssertEqual(account.refreshSubStatus, accountResponse.refreshStatus.subStatus)
        XCTAssertEqual(account.totalCashLimit, accountResponse.totalCashLimit.amount as NSDecimalNumber?)
        XCTAssertEqual(account.totalCashLimitCurrency, accountResponse.totalCashLimit.currency)
        XCTAssertEqual(account.totalCreditLine, accountResponse.totalCreditLine.amount as NSDecimalNumber?)
        XCTAssertEqual(account.totalCreditLineCurrency, accountResponse.totalCreditLine.currency)
    }
    
}
