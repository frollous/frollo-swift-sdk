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

class UserGoalTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUpdatingUserGoal() {
        let database = Database(path: tempFolderPath())
        
        let managedObjectContext = database.newBackgroundContext()
        
        managedObjectContext.performAndWait {
            let userGoalResponse = APIUserGoalResponse.testCompleteData()
            
            let userGoal = UserGoal(context: managedObjectContext)
            userGoal.update(response: userGoalResponse, context: managedObjectContext)
            
            XCTAssertEqual(userGoalResponse.id, userGoal.userGoalID)
            XCTAssertEqual(userGoalResponse.goalID, userGoal.goalID)
            XCTAssertEqual(userGoalResponse.challengeEndDate, userGoal.challengeEndDateString)
            XCTAssertEqual(userGoalResponse.currency, userGoal.currency)
            XCTAssertEqual(userGoalResponse.currentSavedAmount, userGoal.currentSavedAmount.int64Value)
            XCTAssertEqual(userGoalResponse.currentTargetAmount, userGoal.currentTargetAmount.int64Value)
            XCTAssertEqual(userGoalResponse.baseEndDate, userGoal.endDateString)
            XCTAssertEqual(userGoalResponse.estimatedEndDate, userGoal.estimatedEndDateString)
            XCTAssertEqual(userGoalResponse.interestRate, userGoal.interestRate.stringValue)
            XCTAssertEqual(userGoalResponse.monthlySavingAmount, userGoal.monthlySavingAmount.int64Value)
            XCTAssertEqual(userGoalResponse.startAmount, userGoal.startAmount.int64Value)
            XCTAssertEqual(userGoalResponse.startDate, userGoal.startDateString)
            XCTAssertEqual(userGoalResponse.status, userGoal.status)
            XCTAssertEqual(userGoalResponse.targetAmount, userGoal.targetAmount.int64Value)
        }
    }

}
