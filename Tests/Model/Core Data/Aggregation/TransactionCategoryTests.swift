//
//  TransactionCategoryTests.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 7/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import XCTest
@testable import FrolloSDK

class TransactionCategoryTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testUpdatingTransactionCategory() {
        let database = Database(path: tempFolderPath())
        
        let managedObjectContext = database.newBackgroundContext()
        
        managedObjectContext.performAndWait {
            let transactionCategoryResponse = APITransactionCategoryResponse.testCompleteData()
            
            let transactionCategory = TransactionCategory(context: managedObjectContext)
            transactionCategory.update(response: transactionCategoryResponse, context: managedObjectContext)
            
            XCTAssertEqual(transactionCategory.transactionCategoryID, transactionCategoryResponse.id)
            XCTAssertEqual(transactionCategory.name, transactionCategoryResponse.name)
            XCTAssertEqual(transactionCategory.placement, transactionCategoryResponse.placement)
            XCTAssertEqual(transactionCategory.defaultBudgetCategory, transactionCategoryResponse.defaultBudgetCategory)
            XCTAssertEqual(transactionCategory.categoryType, transactionCategoryResponse.categoryType)
            XCTAssertEqual(transactionCategory.userDefined, transactionCategoryResponse.userDefined)
            XCTAssertEqual(transactionCategory.iconURL, URL(string: transactionCategoryResponse.iconURL))
        }
    }
    
}
