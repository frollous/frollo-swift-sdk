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
        XCTAssertEqual(account.classification, accountResponse.classification)
        XCTAssertEqual(account.currentBalance, NSDecimalNumber(string: accountResponse.currentBalance?.amount))
        XCTAssertEqual(account.currentBalanceCurrency, accountResponse.currentBalance?.currency)
        XCTAssertEqual(account.dueDate, accountResponse.dueDate)
        XCTAssertEqual(account.favourite, accountResponse.favourite)
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
    }
    
}
