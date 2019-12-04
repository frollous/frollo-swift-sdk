//
//  Copyright © 2018 Frollo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
// 
//      http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import XCTest
@testable import FrolloSDK

class BudgetTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUpdatingBudget() {
        let database = Database(path: tempFolderPath())
        
        let managedObjectContext = database.newBackgroundContext()
        
        managedObjectContext.performAndWait {
            let budgetResponse = APIBudgetResponse.testCompleteData()
            
            let budget = Budget(context: managedObjectContext)
            budget.update(response: budgetResponse, context: managedObjectContext)
            
            XCTAssertEqual(budgetResponse.id, budget.budgetID)
            XCTAssertEqual(budgetResponse.currentAmount, budget.currentAmount.stringValue)
            XCTAssertEqual(budgetResponse.currency, budget.currency)
            XCTAssertEqual(budgetResponse.estimatedTargetAmount, budget.estimatedTargetAmount?.stringValue)
            XCTAssertEqual(budgetResponse.frequency, budget.frequency)
            XCTAssertEqual(budgetResponse.periodAmount, budget.periodAmount.stringValue)
            XCTAssertEqual(budgetResponse.status, budget.status)
            XCTAssertEqual(budgetResponse.imageURL, budget.imageURLString)
            XCTAssertEqual(budgetResponse.trackingStatus, budget.trackingStatus)
            
            if let responseMetadata = budgetResponse.metadata, let responseSeen = responseMetadata["seen"].bool, let budgetSeen = budget.metadata["seen"].bool {
                XCTAssertEqual(responseSeen, budgetSeen)
            } else {
                XCTFail("No metadata")
            }
        }
    }

}
