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

class GoalTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUpdatingGoal() {
        let database = Database(path: tempFolderPath())
        
        let managedObjectContext = database.newBackgroundContext()
        
        managedObjectContext.performAndWait {
            let goalResponse = APIGoalResponse.testCompleteData()
            
            let goal = Goal(context: managedObjectContext)
            goal.update(response: goalResponse, context: managedObjectContext)
            
            XCTAssertEqual(goalResponse.id, goal.goalID)
            XCTAssertEqual(goalResponse.community.activeCount, goal.activeCount)
            XCTAssertEqual(goalResponse.community.averageMonths, goal.averageMonths)
            XCTAssertEqual(goalResponse.community.averageTargetAmount, goal.averageTargetAmount.stringValue)
            XCTAssertEqual(goalResponse.community.completedCount, goal.completedCount)
            XCTAssertEqual(goalResponse.community.startedCount, goal.startedCount)
            XCTAssertEqual(goalResponse.goalType, goal.goalType)
            XCTAssertEqual(goalResponse.largeLogoURL, goal.largeLogoURLString)
            XCTAssertEqual(goalResponse.name, goal.name)
            XCTAssertEqual(goalResponse.smallLogoURL, goal.smallLogoURLString)
            XCTAssertEqual(goalResponse.source, goal.source)
        }
    }

}
