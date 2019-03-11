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
