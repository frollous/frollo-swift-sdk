//
//  TransactionTests.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 8/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import XCTest
@testable import FrolloSDK

class TransactionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testUpdatingTransactionCompleteData() {
        let database = Database(path: tempFolderPath())
        
        let managedObjectContext = database.newBackgroundContext()
        
        let transactionResponse = APITransactionResponse.testCompleteData()
        
        let transaction = Transaction(context: managedObjectContext)
        transaction.update(response: transactionResponse, context: managedObjectContext)
        
        XCTAssertEqual(transaction.transactionID, transactionResponse.id)
        XCTAssertEqual(transaction.accountID, transactionResponse.accountID)
        XCTAssertEqual(transaction.amount,  NSDecimalNumber(string:  transactionResponse.amount.amount))
        XCTAssertEqual(transaction.baseType, transactionResponse.baseType)
        XCTAssertEqual(transaction.budgetCategory, transactionResponse.budgetCategory)
        XCTAssertEqual(transaction.currency, transactionResponse.amount.currency)
        XCTAssertEqual(transaction.included, transactionResponse.included)
        XCTAssertEqual(transaction.memo, transactionResponse.memo)
        XCTAssertEqual(transaction.merchantID, transactionResponse.merchantID)
        XCTAssertEqual(transaction.originalDescription, transactionResponse.description.original)
        XCTAssertEqual(transaction.postDate, Transaction.transactionDateFormatter.date(from: transactionResponse.postDate!))
        XCTAssertEqual(transaction.simpleDescription, transactionResponse.description.simple)
        XCTAssertEqual(transaction.status, transactionResponse.status)
        XCTAssertEqual(transaction.transactionDate, Transaction.transactionDateFormatter.date(from: transactionResponse.transactionDate))
        XCTAssertEqual(transaction.userDescription, transactionResponse.description.user)
    }
    
    func testUpdatingTransactionIncompleteData() {
        let database = Database(path: tempFolderPath())
        
        let managedObjectContext = database.newBackgroundContext()
        
        let transactionResponse = APITransactionResponse.testIncompleteData()
        
        let transaction = Transaction(context: managedObjectContext)
        transaction.update(response: transactionResponse, context: managedObjectContext)
        
        XCTAssertEqual(transaction.transactionID, transactionResponse.id)
        XCTAssertEqual(transaction.accountID, transactionResponse.accountID)
        XCTAssertEqual(transaction.amount,  NSDecimalNumber(string:  transactionResponse.amount.amount))
        XCTAssertEqual(transaction.baseType, transactionResponse.baseType)
        XCTAssertEqual(transaction.budgetCategory, transactionResponse.budgetCategory)
        XCTAssertEqual(transaction.currency, transactionResponse.amount.currency)
        XCTAssertEqual(transaction.included, transactionResponse.included)
        XCTAssertEqual(transaction.merchantID, transactionResponse.merchantID)
        XCTAssertEqual(transaction.originalDescription, transactionResponse.description.original)
        XCTAssertEqual(transaction.status, transactionResponse.status)
        XCTAssertEqual(transaction.transactionDate, Transaction.transactionDateFormatter.date(from: transactionResponse.transactionDate))
        XCTAssertNil(transaction.memo)
        XCTAssertNil(transaction.postDate)
        XCTAssertNil(transaction.simpleDescription)
        XCTAssertNil(transaction.userDescription)
    }
    
}
