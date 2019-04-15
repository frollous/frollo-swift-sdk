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
        
        managedObjectContext.performAndWait {
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
            XCTAssertEqual(transaction.merchantID, transactionResponse.merchant.id)
            XCTAssertEqual(transaction.originalDescription, transactionResponse.description.original)
            XCTAssertEqual(transaction.postDate, Transaction.transactionDateFormatter.date(from: transactionResponse.postDate!))
            XCTAssertEqual(transaction.simpleDescription, transactionResponse.description.simple)
            XCTAssertEqual(transaction.status, transactionResponse.status)
            XCTAssertEqual(transaction.transactionDate, Transaction.transactionDateFormatter.date(from: transactionResponse.transactionDate))
            XCTAssertEqual(transaction.userDescription, transactionResponse.description.user)
        }
    }
    
    func testUpdatingTransactionIncompleteData() {
        let database = Database(path: tempFolderPath())
        
        let managedObjectContext = database.newBackgroundContext()
        
        managedObjectContext.performAndWait {
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
            XCTAssertEqual(transaction.merchantID, transactionResponse.merchant.id)
            XCTAssertEqual(transaction.originalDescription, transactionResponse.description.original)
            XCTAssertEqual(transaction.status, transactionResponse.status)
            XCTAssertEqual(transaction.transactionDate, Transaction.transactionDateFormatter.date(from: transactionResponse.transactionDate))
            XCTAssertNil(transaction.memo)
            XCTAssertNil(transaction.postDate)
            XCTAssertNil(transaction.simpleDescription)
            XCTAssertNil(transaction.userDescription)
        }
    }
    
    func testUpdateTransactionRequest() {
        let database = Database(path: tempFolderPath())
        
        let managedObjectContext = database.newBackgroundContext()
        
        managedObjectContext.performAndWait {
            let transaction = Transaction(context: managedObjectContext)
            transaction.populateTestData()
            
            let updateRequest = transaction.updateRequest()
            
            XCTAssertEqual(transaction.budgetCategory, updateRequest.budgetCategory)
            XCTAssertEqual(transaction.transactionCategoryID, updateRequest.categoryID)
            XCTAssertEqual(transaction.included, updateRequest.included)
            XCTAssertEqual(transaction.memo, updateRequest.memo)
            XCTAssertEqual(transaction.userDescription, updateRequest.userDescription)
        }
    }
    
}
